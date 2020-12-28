//
//  EmulationViewiPad.h
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

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "MainEmulationViewController.h"
#import "IOSKeyboard.h"
#import "InputControllerView.h"

@interface EmulationViewiPad : MainEmulationViewController {

    UIButton *closeButton;
    UIButton *restartButton;
    WKWebView *webView;
}

-(IBAction)toggleControls:(id)sender;
-(IBAction)togglePinstatus:(id)sender;
-(IBAction)enableMenuBar:(id)sender;

@property (readwrite, retain) IBOutlet UIButton *btnKeyboard;
@property (readwrite, retain) IBOutlet UIButton *btnJoypad;
@property (readwrite, retain) IBOutlet UIButton *btnPin;
@property (nonatomic, retain) IBOutlet WKWebView *webView;
@property (nonatomic, retain) IBOutlet UIButton *closeButton;
@property (nonatomic, retain) IBOutlet TouchHandlerViewClassic *mouseHandler;
@property (nonatomic, retain) IBOutlet UIButton *restartButton;
@property (nonatomic, retain) IBOutlet InputControllerView *joyController;
@property (readwrite, retain) IBOutlet UIToolbar *menuBar;
@property (readwrite, retain) IBOutlet UIButton *menuBarEnabler;
@property (retain, nonatomic) IBOutlet UILabel *lblDebug;
@property (retain, nonatomic) IBOutlet UIButton *btnSettings;


@end
