//  Created by Simon Toens on 05.10.15
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
#import "KeyButtonConfigurationController.h"
#import "IOSKeyboard.h"

@implementation KeyButtonConfigurationController {
    IOSKeyboard *_keyboard;
    NSMutableDictionary *_viewConfigurationToView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _keyboard = [[IOSKeyboard alloc] initAndCreateDummyFields:self.view];
    _keyboard.delegate = self;
    _viewConfigurationToView = [[NSMutableDictionary alloc] init];
    [self configureButtonViews];
    [self updateUIForSelectedView];
}

- (void)dealloc {
    [_keyboard release];
    [_viewConfigurationToView release];
    [super dealloc];
}

- (void)keyPressed:(int)ascii keyName:(NSString *)keyName {
    [_keyboard toggleKeyboard];
    _selectedButtonViewConfiguration.key = (SDLKey)ascii;
    _selectedButtonViewConfiguration.keyName = keyName;
    [self updateKeyLabelForView:[self getSelectedView] withValue:keyName];
}

- (void)updateButtonViewSizeSlider {
    _buttonViewSizeSlider.value = _selectedButtonViewConfiguration.size.height;
}

- (void)configureButtonViews {
    for (KeyButtonConfiguration *buttonConfiguration in _allButtonConfigurations) {
        [self addViewForButtonConfig:buttonConfiguration];
    }
}

- (CGRect)getFrameForButtonViewConfiguration:(KeyButtonConfiguration *)buttonViewConfiguration {
    return CGRectMake(buttonViewConfiguration.position.x,
                      buttonViewConfiguration.position.y,
                      buttonViewConfiguration.size.width,
                      buttonViewConfiguration.size.height);
}

- (UIView *)addViewForButtonConfig:(KeyButtonConfiguration *)buttonConfig {
    CGRect frame = [self getFrameForButtonViewConfiguration:buttonConfig];
    UIView *view = [[UIView alloc] initWithFrame:frame];
    UIColor *backgroundColor = _selectedButtonViewConfiguration == buttonConfig ? [self getSelectedColor] : [self getDeselectedColor];
    [view setBackgroundColor:backgroundColor];
    [self updateKeyLabelForView:view withValue:buttonConfig.keyName];
    [self.view addSubview:view];
    [view addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)]];
    [view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)]];
    [_viewConfigurationToView setObject:view forKey:buttonConfig];
    return view;
}

- (void)updateKeyLabelForView:(UIView *)view withValue:(NSString *)value {
    if ([view.subviews count] == 0) {
        CGRect labelFrame = CGRectMake(5, 5, view.frame.size.width - 10, 15);
        UILabel *label = [[[UILabel alloc] initWithFrame:labelFrame] autorelease];
        label.text = value;
        label.textColor = [UIColor whiteColor];
        [view addSubview:label];
    } else {
        UILabel *label = [view.subviews firstObject];
        label.text = value;
    }
}

- (IBAction)onNewButton {
    KeyButtonConfiguration *newButtonConfig = [_selectedButtonViewConfiguration clone];
    [_allButtonConfigurations addObject:newButtonConfig];
    newButtonConfig.position = CGPointMake(newButtonConfig.position.x + 5, newButtonConfig.position.y + 5);
    UIView *newView = [self addViewForButtonConfig:newButtonConfig];
    [self updateSelectedViewTo:newView];
}

- (IBAction)onAssignKey {
    [_keyboard toggleKeyboard];
}

- (IBAction)onButtonViewSlider {
    CGSize newSize = CGSizeMake(_buttonViewSizeSlider.value, _buttonViewSizeSlider.value);
    _selectedButtonViewConfiguration.size = newSize;
    UIView *view = [self getSelectedView];
    view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, newSize.width, newSize.height);
}

- (IBAction)onDoneButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)handleTap:(UIPanGestureRecognizer *)recognizer {
    [self updateSelectedViewTo:recognizer.view];
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self updateSelectedViewTo:recognizer.view];
    }
    
    CGPoint translation = [recognizer translationInView:self.view];
    recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x, recognizer.view.center.y + translation.y);
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        _selectedButtonViewConfiguration.position = recognizer.view.frame.origin;
    }
}

- (void)updateSelectedViewTo:(UIView *)view {
    UIView *currentlySelectedView = [self getSelectedView];
    if (currentlySelectedView != view) {
        currentlySelectedView.backgroundColor = [self getDeselectedColor];
        view.backgroundColor = [self getSelectedColor];
        _selectedButtonViewConfiguration = [self configForView:view];
        [self updateUIForSelectedView];
    }
}

- (void)updateUIForSelectedView {
    [self updateButtonViewSizeSlider];
}

- (KeyButtonConfiguration *)configForView:(UIView *)view {
    for (KeyButtonConfiguration *config in _viewConfigurationToView) {
        UIView *mappedView = [_viewConfigurationToView objectForKey:config];
        if (view == mappedView) {
            return config;
        }
    }
    NSAssert(NO, @"Did not find config for view %@", view);
    return nil;
}

- (UIView *)getSelectedView {
    UIView *selectedView = [_viewConfigurationToView objectForKey:_selectedButtonViewConfiguration];
    NSAssert(selectedView != nil, @"No mapping for view configuration %@", _selectedButtonViewConfiguration);
    return selectedView;
}

- (UIColor *)getSelectedColor {
    return [UIColor redColor];
}

- (UIColor *)getDeselectedColor {
    return [UIColor grayColor];
}

@end
