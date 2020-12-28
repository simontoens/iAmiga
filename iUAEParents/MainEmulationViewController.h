//
//  DOTCEmulationViewController.h
//  iAmiga
//
//  Created by Stuart Carnie on 7/11/11.
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

#import "BaseEmulationViewController.h"
#import "AnimatedImageSequenceView.h"
#import "DynamicLandscapeControls.h"
#import "TouchHandlerViewClassic.h"
#import "InputControllerView.h"
#import "SettingsGeneralController.h"

#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import <WebKit/WebKit.h>

@class VirtualKeyboard;

@interface MainEmulationViewController : BaseEmulationViewController<ResetDelegate, WKNavigationDelegate, UINavigationControllerDelegate> {
    VirtualKeyboard	*vKeyboard;
    bool keyboardactive;
    bool joyactive;
    int paused;
}

@property (readonly) CGFloat screenHeight;
@property (readonly) CGFloat screenWidth;
@property (readwrite, retain) UIButton *btnKeyboard;
@property (readwrite, retain) UIButton *menuBarEnabler;
@property (readwrite, retain) UIButton *btnJoypad;
@property (readwrite, retain) UIButton *btnPin;
@property (readwrite, retain) UIToolbar *menuBar;
@property (nonatomic, retain) InputControllerView *joyController;
@property (nonatomic, retain) IBOutlet TouchHandlerViewClassic *mouseHandler;
@property (retain, nonatomic) IBOutlet UIButton *btnSettings;

-(IBAction)toggleControls:(id)sender;
-(IBAction)enableMenuBar:(id)sender;
-(IBAction)togglePinstatus:(id)sender;
- (IBAction)restart:(id)sender;
- (void)initializeKeyboard;
- (void)initializeJoypad:(InputControllerView *)joyController;
- (void)checkForPaused:(NSTimer*)timer;
@end
