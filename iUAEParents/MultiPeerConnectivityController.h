//
//  MultiPeerConnectivityController.h
//  iUAE
//  Created by mithendral on 24.02.16.
//
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

#ifndef MultiPeerConnectivityController_h
#define MultiPeerConnectivityController_h

#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "MainEmulationViewController.h"

static NSString *const kVirtualPad = @"VirtualPad";
static NSString *const kiCadePad = @"iCadePad";


@interface MultiPeerConnectivityController : NSObject<MCNearbyServiceAdvertiserDelegate, MCSessionDelegate, MCNearbyServiceBrowserDelegate, MCBrowserViewControllerDelegate> {
 }
    @property (readwrite, retain) MainEmulationViewController *mainEmuViewController;

- (void)configure: (MainEmulationViewController *) mainEmuViewCtrl ;
+ (MultiPeerConnectivityController *)getinstance;
- (void)handleinputdirections:(TouchStickDPadState)hat_state buttontoreleasevertical:(int)buttontoreleasevertical buttontoreleasehorizontal: (int)buttontoreleasehorizontal deviceid:(NSString *)dID;
- (int)handleinputbuttons:(int)buttonid buttonstate:(int)buttonstate deviceid:(NSString *)dID;
- (int) dpadstatetojoypadkey:(NSString *)direction hatstate:(TouchStickDPadState)hat_state;
- (void)enableControllerMode;
- (void)controllerDisconnected:(NSString *)dID;

@end

#endif /* MultiPeerConnectivityController_h */
