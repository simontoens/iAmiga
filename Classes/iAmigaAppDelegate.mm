//
//  iAmigaAppDelegate.m
//  iAmiga
//
//  Created by Stuart Carnie on 2/7/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
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
// You should have received a copy of the GNU General Public License
//along with this program; if not, write to the Free Software
//Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

#import "iAmigaAppDelegate.h"
#import "EmulationViewController.h"
#import <AudioToolbox/AudioServices.h>
#import "UaeDebugger.h"
#import "SDL.h"
#import "UIKitDisplayView.h"

@interface iAmigaAppDelegate()

- (void)screenDidConnect:(NSNotification*)aNotification;
- (void)screenDidDisconnect:(NSNotification*)aNotification;
- (void)configureScreens;

@end

@implementation iAmigaAppDelegate

@synthesize window, mainController=_mainController;

- (void)screenDidConnect:(NSNotification*)aNotification {
	[self configureScreens];
}

- (void)screenDidDisconnect:(NSNotification*)aNotification {
	[self configureScreens];
	
}

- (void)applicationWillResignActive:(UIApplication *)application {
    SDL_PauseOpenGL(1);
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    SDL_PauseOpenGL(0);
}

- (void)configureScreens {
	if ([[UIScreen screens] count] == 1) {
		NSLog(@"Device display");
		// disable extras		
		if (externalWindow) {
			externalWindow.hidden = YES;
		}
		[_emulationView setDisplayViewWindow:nil isExternal:NO];
	} else {
		NSLog(@"External display");
		UIScreen *secondary = [[UIScreen screens] objectAtIndex:1];
		UIScreenMode *bestMode = [secondary.availableModes objectAtIndex:0];
		int modes = (int) [secondary.availableModes count];
		if (modes > 1) {
			UIScreenMode *current;
			for (current in secondary.availableModes) {
				if (current.size.width > bestMode.size.width)
					bestMode = current;
			}
		}
		secondary.currentMode = bestMode;
		if (!externalWindow) {
			externalWindow = [[UIWindow alloc] initWithFrame:secondary.bounds];
			externalWindow.backgroundColor = [UIColor blackColor];
		} else {
			externalWindow.frame = secondary.bounds;
		}

		externalWindow.screen = secondary;
		[_emulationView setDisplayViewWindow:externalWindow isExternal:YES];
		externalWindow.hidden = NO;
	}
}

- (void)dealloc {
    [window release];
    [super dealloc];
}


@end
