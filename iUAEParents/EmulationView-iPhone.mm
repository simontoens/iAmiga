//
//  EmulationViewiPad.m
//  iAmiga
//
//  Created by Stuart Carnie on 6/23/11.
//  Copyright 2011 Manomio LLC. All rights reserved.
//
//  Changed by Emufr3ak on 29.05.14.
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

#import "EmulationView-iPhone.h"

@implementation EmulationViewiPhone
//@synthesize menuView;
@synthesize webView;
//@synthesize menuButton;
@synthesize closeButton;
@synthesize mouseHandler;
@synthesize restartButton;
@synthesize joyController;

@dynamic btnKeyboard;

#pragma mark - View lifecycle

- (CGFloat) XposFloatPanel {
    
    CGRect screenRect = CGRectZero;
    screenRect = [[UIScreen mainScreen] bounds];
    //CGFloat screenHeight = screenRect.size.height;
    
    CGFloat result = (self.screenHeight / 2) - 240;
    
    return result;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initializeJoypad:joyController];
    
    [webView setBackgroundColor:[UIColor clearColor]];
    [webView setOpaque:NO];
//    webView.navigationDelegate = self;
//    webView.uiDelegate = self;
    
    [super initializeKeyboard];
}

- (void)dealloc {
    //[menuButton release];
    [closeButton release];
    //[menuView release];
    [mouseHandler release];
    [webView release];
    [restartButton release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    //[self setMenuButton:nil];
    [self setCloseButton:nil];
    //[self setMenuView:nil];
    [self setMouseHandler:nil];
    [self setWebView:nil];
    [self setRestartButton:nil];
    [super didReceiveMemoryWarning];
}

- (IBAction)keyboardDidHide:(id)sender
//Keyboards dismissed by other Means than Fullscreenpanel
{
    //Simulate Button press in Fullscreenpanel if Keyboard was closed by Keyboardclosebutton in Keyboard
    if(keyboardactive == TRUE //Keyboard was closed by regular button in Fullscreenpanel
       && dummy_textfield.isFirstResponder == FALSE //Fkeypanel was deactivated this triggered the event
       && dummy_textfield_f.isFirstResponder == FALSE //Fkeypanel was activated this triggered the event
       && dummy_textfield_s.isFirstResponder == FALSE //Special Keyboard view was activated this triggered the event
       )
    {
        [self.btnKeyboard sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
}


@end
