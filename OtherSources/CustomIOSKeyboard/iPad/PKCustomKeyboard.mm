//
//  PKCustomKeyboard.m
//  PunjabiKeyboard
//
//  Created by Kulpreet Chilana on 7/19/12.
//  Copyright (c) 2012 Kulpreet Chilana. All rights reserved.
//

#import "PKCustomKeyboard.h"

@interface PKCustomKeyboard ()

@property (nonatomic, assign, getter=isShifted) BOOL shifted;

@end

@implementation PKCustomKeyboard {
    IBOutlet UIButton *bDown;
    IBOutlet UIButton *bUp;
    IBOutlet UIButton *bLeft;
    IBOutlet UIButton *bRight;
    IBOutlet UIButton *b0;
    IBOutlet UIButton *b1;
    IBOutlet UIButton *b2;
    IBOutlet UIButton *b3;
    IBOutlet UIButton *b4;
    IBOutlet UIButton *b5;
    IBOutlet UIButton *b6;
    IBOutlet UIButton *b7;
    IBOutlet UIButton *b8;
    IBOutlet UIButton *b9;
    IBOutlet UIButton *bBracketleft;
    IBOutlet UIButton *bBracketright;
    IBOutlet UIButton *bDivide;
    IBOutlet UIButton *bMultiply;
    IBOutlet UIButton *bMinus;
    IBOutlet UIButton *bPlus;
    IBOutlet UIButton *bShiftfleft;
    IBOutlet UIButton *bShiftright;
    IBOutlet UIButton *bAltLeft;
    IBOutlet UIButton *bAltRight;
    IBOutlet UIButton *bCtrl;
    IBOutlet UIButton *bEnter;
    IBOutlet UIButton *bAright;
    IBOutlet UIButton *bAleft;
    IBOutlet UIButton *bPeriod;
    IBOutlet UIButton *bSpace;
}

@synthesize textView = _textView;

-(void)viewDidLoad {
    bLeft.tag = SDLK_LEFT;
    bRight.tag = SDLK_RIGHT;
    bDown.tag = SDLK_DOWN;
    bUp.tag = SDLK_UP;
    b0.tag = SDLK_KP0;
    b1.tag = SDLK_KP1;
    b2.tag = SDLK_KP2;
    b3.tag = SDLK_KP3;
    b4.tag = SDLK_KP4;
    b5.tag = SDLK_KP5;
    b6.tag = SDLK_KP6;
    b7.tag = SDLK_KP7;
    b8.tag = SDLK_KP8;
    b9.tag = SDLK_KP9;
    bBracketleft.tag = SDLK_HOME; //Pseudo Maping SDL Library doesn't know Key with Bracket on Number Block. But Amiga does not have Home Key
    bBracketright.tag = SDLK_END; //Pseudo Maping SDL Library doesn't know Key with Bracket on Number Block. But Amiga does not have END Key
    bDivide.tag = SDLK_KP_DIVIDE;
    bMultiply.tag = SDLK_KP_MULTIPLY;
    bMinus.tag = SDLK_KP_MINUS;
    bPlus.tag = SDLK_KP_PLUS;
    bShiftfleft.tag = SDLK_LSHIFT;
    bShiftright.tag = SDLK_RSHIFT;
    bAltLeft.tag = SDLK_LALT;
    bAltRight.tag = SDLK_RALT;
    bCtrl.tag = SDLK_LCTRL;
    bEnter.tag = SDLK_KP_ENTER;
    bAright.tag = SDLK_RMETA; //Pseudo Maping SDL Library doesn't know Amiga Left. But Amiga does not have RMETA Key
    bAleft.tag = SDLK_LMETA; //Pseudo Maping SDL Library doesn't know Key Amiga Right. But Amiga does not have LMETA Key
    bPeriod.tag = SDLK_KP_PERIOD;
    bSpace.tag = SDLK_SPACE;
}

-(void)setTextView:(id<UITextInput>)textView {
	
	if ([textView isKindOfClass:[UITextView class]])
        [(UITextView *)textView setInputView:self.view];
    else if ([textView isKindOfClass:[UITextField class]])
        [(UITextField *)textView setInputView:self.view];
    
    _textView = textView;
}

-(id<UITextInput>)textView {
	return _textView;
}

- (IBAction)keyDown:(id)sender {
    [[UIDevice currentDevice] playInputClick];
	UIButton *button = (UIButton *)sender;
    
    
    NSString *character = [NSString stringWithFormat:@"D%ld", (long) button.tag];
    [self.textView insertText:character];
}

- (IBAction)keyUp:(id)sender {
    [[UIDevice currentDevice] playInputClick];
	UIButton *button = (UIButton *)sender;
    
    
    NSString *character = [NSString stringWithFormat:@"U%ld", (long) button.tag];
    [self.textView insertText:character];
}

- (void) dealloc {
    [super dealloc];
    
    [bDown dealloc];
    [bUp dealloc];
    [bLeft dealloc];
    [bRight dealloc];
    [b0 dealloc];
    [b1 dealloc];
    [b2 dealloc];
    [b3 dealloc];
    [b4 dealloc];
    [b5 dealloc];
    [b6 dealloc];
    [b7 dealloc];
    [b8 dealloc];
    [b9 dealloc];
    [bBracketleft dealloc];
    [bBracketright dealloc];
    [bDivide dealloc];
    [bMultiply dealloc];
    [bMinus dealloc];
    [bPlus dealloc];
    [bShiftfleft dealloc];
    [bShiftright dealloc];
    [bAltLeft dealloc];
    [bAltRight dealloc];
    [bCtrl dealloc];
    [bSpace dealloc];
    [bAright dealloc];
    [bAleft dealloc];
    [bEnter dealloc];
}

@end
