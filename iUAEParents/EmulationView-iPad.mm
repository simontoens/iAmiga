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

#import "EmulationView-iPad.h"
#import "SettingsGeneralController.h"

@implementation EmulationViewiPad
//@synthesize menuView;
@synthesize webView;
//@synthesize menuButton;
@synthesize closeButton;
@synthesize restartButton;

@dynamic btnKeyboard, btnJoypad, btnPin, mouseHandler, joyController, menuBar, menuBarEnabler, btnSettings;

#pragma mark - View lifecycle

bool keyboardactive;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [webView setBackgroundColor:[UIColor clearColor]];
    [webView setOpaque:NO];
    webView.delegate = self;
    
    [super initializeKeyboard];
    
    //Uncomment for debug mode
    //[_lblDebug setHidden:true];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    if ([segue.identifier isEqualToString:@"OpenSettings"]) {
        UITabBarController *tabBar = segue.destinationViewController;
        SettingsGeneralController *settingsController = [tabBar.viewControllers objectAtIndex:0];
        settingsController.emulatorScreenshot = [self captureScreenshot];
    }
}

-(IBAction)toggleControls:(id)sender {
    [super toggleControls:sender];
}

-(IBAction)togglePinstatus:(id)sender {
    [super togglePinstatus:sender];
}

-(IBAction)enableMenuBar:(id)sender {
    [super enableMenuBar:sender];
}

-(void)checkForPaused:(NSTimer*)timer {
    [super checkForPaused:timer];
    //[_lblDebug setText:[NSString stringWithFormat:@"%i", paused]];
}

- (UIImage *)captureScreenshot {
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, 0.0f);
    [displayView drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:NO];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)dealloc {
    [closeButton release];
    [webView release];
    [restartButton release];
    [super dealloc];
}

- (void)viewDidUnload {
    [self setCloseButton:nil];
    [self setMouseHandler:nil];
    [self setWebView:nil];
    [self setRestartButton:nil];
    [super viewDidUnload];
}

- (IBAction)keyboardDidHide:(id)sender {
    //Simulate Button press in Fullscreenpanel if Keyboard was closed by Keyboardclosebutton in Keyboard
    if (keyboardactive) {
        [self.btnKeyboard sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
}

@end
