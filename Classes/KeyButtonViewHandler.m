//  Created by Simon Toens on 1.10.16
//
//  iUAE is free software: you may copy, redistribute
//  and/or modify it under the terms of the GNU General Public License as
//  published by the Free Software Foundation, either version 2 of the
//  License, or (at your option) any later version.
//
//  This file is distributed in the hope that it will be useful, but
//  WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
//  General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program; if not, write to the Free Software
//  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

#import "KeyButtonConfiguration.h"
#import "KeyButtonViewHandler.h"
#import "Settings.h"

@interface TouchNotifier : NSObject

@property (nonatomic) BOOL buttonWasTouched;

@end

@implementation TouchNotifier
@end

@interface KeyButtonView : UIView {
    @private
    SDLKey _key;
    NSString *_keyName;
    TouchNotifier *_touchNotifier;
}

- (instancetype)initWithFrame:(CGRect)frame
                       forKey:(SDLKey)key
                  withKeyName:(NSString *)keyName
                touchNofifier:(TouchNotifier *)touchNotifier;
@end

/**
 * When touched, simulates the pressing of a configurable key.
 */
@implementation KeyButtonView

- (instancetype)initWithFrame:(CGRect)frame
                       forKey:(SDLKey)key
                  withKeyName:(NSString *)keyName
                touchNofifier:(TouchNotifier *)touchNotifier
{
    if (self = [super initWithFrame:frame]) {
        _key = key;
        _keyName = [keyName retain];
        _touchNotifier = [touchNotifier retain];
    }
    return self;
}

- (void)highlightBorder {
    UIColor *color = [self getOutlineColor];
    self.layer.borderColor = color.CGColor;
    self.layer.borderWidth = .5;
}

- (void)addKeyLabelOnLeftSide:(BOOL)onLeftSide {
    static int labelWidth = 70;
    static int offset = 5;
    static int labelHeight = 15;
    CGRect frame = onLeftSide ? CGRectMake(offset, offset, labelWidth, labelHeight) : CGRectMake(self.frame.size.width - labelWidth - offset, offset, labelWidth, labelHeight);
    UILabel *label = [[[UILabel alloc] initWithFrame:frame] autorelease];
    label.text = _keyName;
    label.textColor = [self getOutlineColor];
    [self addSubview:label];
}

- (UIColor *)getOutlineColor {
    return [UIColor redColor];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    SDL_Event ed = { SDL_KEYDOWN };
    ed.key.keysym.sym = _key;
    SDL_PushEvent(&ed);
    _touchNotifier.buttonWasTouched = YES;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    SDL_Event eu = { SDL_KEYUP };
    eu.key.keysym.sym = _key;
    SDL_PushEvent(&eu);
}

- (void)dealloc {
    [_keyName release];
    [_touchNotifier release];
    [super dealloc];
}

@end

@implementation KeyButtonViewHandler {
    @private
    NSMutableArray *_keyButtonViews;
    Settings *_settings;
    UIView *_superview;
    TouchNotifier *_touchNotifier;
}

- (instancetype)initWithSuperview:(UIView *)superview {
    if (self = [super init]) {
        _keyButtonViews = [[NSMutableArray alloc] init];
        _settings = [[Settings alloc] init];
        _superview = [superview retain];
        _touchNotifier = [[TouchNotifier alloc] init];
    }
    return self;
}

- (BOOL)anyButtonWasTouched {
    return _touchNotifier.buttonWasTouched;
}

- (void)setAnyButtonWasTouched:(BOOL)anyButtonWasTouched {
    _touchNotifier.buttonWasTouched = anyButtonWasTouched;
}

- (void)addConfiguredKeyButtonViews {
    [self removeExistingKeyButtonViews];
    if (!_settings.keyButtonsEnabled) {
        return;
    }
    for (KeyButtonConfiguration *button in _settings.keyButtonConfigurations) {
        if (!button.enabled) {
            continue;
        }
        if (!button.hasConfiguredKey) {
            continue;
        }
        CGRect frame = CGRectMake(button.position.x, button.position.y, button.size.width, button.size.height);
        KeyButtonView *buttonView = [[[KeyButtonView alloc] initWithFrame:frame
                                                                   forKey:button.key
                                                              withKeyName:button.keyName
                                                            touchNofifier:_touchNotifier] autorelease];
        if (button.showOutline) {
            [buttonView highlightBorder];
            [buttonView addKeyLabelOnLeftSide:YES];
        }
        [_superview addSubview:buttonView];
        [_keyButtonViews addObject:buttonView];
    }
    [self bringAllButtonViewsToFront];
}

- (void)bringAllButtonViewsToFront {
    for (UIView *keyButtonView in _keyButtonViews) {
        [_superview bringSubviewToFront:keyButtonView];
    }
}

- (void)removeExistingKeyButtonViews {
    for (UIView *view in _keyButtonViews) {
        if([view isKindOfClass:[KeyButtonView class]]){
            [view removeFromSuperview];
        }
    }
    [_keyButtonViews removeAllObjects];
}

- (void)dealloc {
    [_keyButtonViews release];
    [_settings release];
    [_superview release];
    [_touchNotifier release];
    [super dealloc];
}

@end
