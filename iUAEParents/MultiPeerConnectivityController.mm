 //
//  MultiPeerConnectivityController.m
//  iUAE
//
//  Created by mithrendil on 24.02.2016.
//
//

#import "MultiPeerConnectivityController.h"
#import "MPCConnectionStates.h"
#import "SVProgressHUD.h"
#import "JoypadKey.h"
#import "Settings.h"

static MultiPeerConnectivityController *_instance;
extern CJoyStick g_touchStick;
@implementation MultiPeerConnectivityController {
    Settings *_settings;
    double _lasttime;
    NSMutableArray *_dMap;
}

extern MPCStateType mainMenu_servermode;
extern unsigned int mainMenu_joy0dir;
extern int mainMenu_joy0button;
extern unsigned int mainMenu_joy1dir;
extern int mainMenu_joy1button;
static NSString * const XXServiceType = @"svc-iuae";
CJoyStick *theJoystick = &g_touchStick;
MCPeerID *localPeerID = nil;
MCSession *session = nil;
MCNearbyServiceBrowser *browser = nil;
MCBrowserViewController *browserViewController = nil;
MPCStateType lastServerMode=kConnectionIsOff;
bool bConnectionToServerJustEstablished = false;

+ (MultiPeerConnectivityController *)getinstance
{
    return _instance;
}

- (id) init
{
    [super init];
    
    _instance = self;
    
    _dMap = [[NSMutableArray alloc] initWithObjects:[NSNull null],[NSNull null],[NSNull null],[NSNull null], [NSNull null], [NSNull null],[NSNull null],[NSNull null],[NSNull null],[NSNull null], nil];
    
    return self;
}

- (void)enableControllerMode {
    
    if(mainMenu_servermode == kConnectionIsOff)
    {
        mainMenu_servermode = kServeAsController;
    }
}

- (void)configure: (MainEmulationViewController *) mainEmuViewCtrl {
    
    _mainEmuViewController = mainEmuViewCtrl;
    _instance = self;
    _settings = [[Settings alloc] init];
    
    
    if(mainMenu_servermode == kConnectionIsOff)
    {
        [self showMessage:@"Use device as Remote Controller" withMessage:@"Tab screen to use device as remote controller"];
        
//        dispatch_time_t waittime = dispatch_time(DISPATCH_TIME_NOW, 6.00 * NSEC_PER_SEC);
        
//        dispatch_after(waittime, dispatch_get_main_queue(),
//                       ^void{
//                           [self configureContinue:mainEmuViewCtrl];
//                       });
    }
}


-(void)configureContinue:(MainEmulationViewController *) mainEmuViewCtrl {
/*Continue Configuration after Waiting time */
    
    mainMenu_servermode = mainMenu_servermode == kConnectionIsOff ? kServeAsHostForIncomingJoypadSignals : mainMenu_servermode;
    
    if(mainMenu_servermode == kServeAsHostForIncomingJoypadSignals)
    {
        
        if(lastServerMode == kServeAsController)
        {
            [session disconnect]; // close client session
            session = nil;
        }
        
        if(advertiser == nil)
        {
            [self startServer];
            
            //the device should NOT go to sleep after some idle time
            [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
        }
    }
    else if(mainMenu_servermode == kServeAsController)
    {
        if(lastServerMode == kServeAsHostForIncomingJoypadSignals)
        {
            if(advertiser!=nil)
            {
                [self stopServer];
            }
        }
        
        if(session == nil|| session.connectedPeers.count == 0)
        {
            bConnectionToServerJustEstablished = true;
            [self startClient];
            
            //the device should go to sleep after some idle time
            [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
        }
        else
        {
            if(!bConnectionToServerJustEstablished)
            {
                if( mainMenu_servermode == kServeAsController)
                    [self showMessage: @"use existing connection" withMessage: @"use existing connection for device controller"];
            }
            bConnectionToServerJustEstablished = false;
            [self activateJoyPad];
        }
    }
    
    lastServerMode = mainMenu_servermode;
}

- (void)activateJoyPad {
    if(_mainEmuViewController.btnJoypad.selected == FALSE)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_mainEmuViewController toggleControls:_mainEmuViewController.btnJoypad];

        });
    }
}

/*  CLIENT part */
- (void)startClient {
    if(localPeerID == nil)
    {
        localPeerID = [[MCPeerID alloc] initWithDisplayName:[[UIDevice currentDevice] name]];
    }
    session = [[MCSession alloc] initWithPeer:localPeerID
                             securityIdentity:nil
                         encryptionPreference:MCEncryptionNone];
    
    browser = [[MCNearbyServiceBrowser alloc] initWithPeer:localPeerID serviceType:XXServiceType];
    browser.delegate = self;
    browserViewController = [[MCBrowserViewController alloc] initWithBrowser:browser
                                                                     session:session];
    browserViewController.delegate = self;
    [_mainEmuViewController presentViewController:browserViewController
                       animated:YES
                     completion:
     ^{
         [browser startBrowsingForPeers];
     }];
}

- (void)browser:(MCNearbyServiceBrowser *)browser
      foundPeer:(MCPeerID *)peerID
withDiscoveryInfo:(NSDictionary<NSString *,
                   NSString *> *)info
{
    NSLog(@"found peer");
    if(![peerID isEqual:localPeerID])
        [browser invitePeer:peerID toSession:session withContext:nil timeout:30];
    
}
- (void)browser:(MCNearbyServiceBrowser *)browser
       lostPeer:(MCPeerID *)peerID
{}

- (void)controllerDisconnected:(NSString *)dID {
    NSInteger index = -1;
    index = [_dMap indexOfObject:dID];
    
    if(index>=0) {
        [[_dMap objectAtIndex:index] release];
        _dMap[index] = [NSNull null];
    }
}

- (void)setkeymapfordeviceID:(NSString *)dID {
    
    NSUInteger kmNumber = [_dMap indexOfObject:dID];
    
    if([dID isEqualToString:kVirtualPad])
    {
//        for(kmNumber = 1;kmNumber <= [_dMap count];kmNumber++)
//        {
            if([[_settings keyConfigurationforButton:VSWITCH forController:(int)kmNumber] isEqualToString:@"YES"])
            {
                //Mapping reserved for OnScreenJoypad found load this setting an return
                [_settings setCNumber:(int) kmNumber];
                return;
            }
            
            //No Mapping found for OnScreenJoypad. Use first Keymap
            [_settings setCNumber:1];
            return;
//        }
        
    }
    
    if
        (kmNumber == NSNotFound)
    {
        
        for(kmNumber= 0;kmNumber <= [_dMap count] -1; kmNumber++)
        {
            if(_dMap[kmNumber] == [NSNull null])
            {
                _dMap[kmNumber] = [[NSString stringWithString:dID] retain];
                [self showMessage:@"New Controller Mapped" withMessage:[NSString stringWithFormat:@"Using Keymap %ld for this device", (long) kmNumber+1]];
                break;
            }
        }
    }
    
    kmNumber++;
    [_settings setCNumber:(int) kmNumber];
}

- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController
{
    [_mainEmuViewController  dismissViewControllerAnimated:YES completion:nil];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if( mainMenu_servermode == kServeAsController)
            [self showMessage: @"new connection established" withMessage: @"use idevice as controller"];
        
         [self activateJoyPad];
    });
}

- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController
{
    [_mainEmuViewController dismissViewControllerAnimated:YES completion:nil];
    mainMenu_servermode=kServeAsHostForIncomingJoypadSignals; //disable client mode
    [self showMessage: @"Controller Mode Cancelled" withMessage: @"Controller Mode Cancelled. Device will not be used as remote controller"];
}

- (void)sendJoystickDataForDirection:(int)direction buttontoreleasehorizontal:(int)buttontoreleasehorizontal buttontoreleasevertical:(int)buttontoreleasevertical
{
    if(session == nil || session.connectedPeers.count == 0)
    {
    }
    else
    {
        
        int aints[6]= {  (unsigned int)direction, (unsigned int)0, BTN_INVALID, buttontoreleasehorizontal, buttontoreleasevertical};
        
        NSData *data = [NSData dataWithBytes: &aints length: sizeof(aints)];
        
        
        NSError *error = nil;
        if (![session sendData:data
                       toPeers:session.connectedPeers
                      withMode:MCSessionSendDataReliable
                         error:&error]) {
            NSLog(@"[Error] %@", error);
        }
    }
}

- (void)sendJoystickDataForButtonID:(int)buttonid buttonstate:(int)buttonstate {
 
    if(session == nil || session.connectedPeers.count == 0)
    {
    }
    else
    {
        
        int aints[5]= { (unsigned int) 0, (unsigned int)buttonstate, (unsigned int) buttonid, (unsigned int) 0, (unsigned int) 0};
        
        NSData *data = [NSData dataWithBytes: &aints length: sizeof(aints)];
        
        NSError *error = nil;
        if (![session sendData:data
                       toPeers:session.connectedPeers
                      withMode:MCSessionSendDataReliable
                         error:&error]) {
            NSLog(@"[Error] %@", error);
        }
    }

}
- (void)showMessage: (NSString *)sTitel withMessage:(NSString *)sMessage
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD setInfoImage:nil];
        [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:220.0/255.0 green:220.0/255.0 blue:220.0/255.0 alpha:1]];
        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"%@\n\n%@", sTitel, sMessage]];
    });
    
}

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    
    if(state == MCSessionStateNotConnected) {
        [self showMessage: peerID.displayName withMessage: @"not connected"];
        [self controllerDisconnected:peerID.displayName];
    }
    
}

/* server part */
MCNearbyServiceAdvertiser *advertiser=nil;

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    
    unsigned int aJoyData[5];
    [data getBytes: &aJoyData length: sizeof(aJoyData)];
    
    TouchStickDPadState joydir = (TouchStickDPadState)aJoyData[0];
    int joybtnstat = (int) aJoyData[1];
    int joybtn = (int) aJoyData[2];
    int btntoreleasehor = (int) aJoyData[3];
    int btntoreleasever = (int) aJoyData[4];
    
    if(joybtn != BTN_INVALID)
    {

        if(CACurrentMediaTime() - _lasttime < (double) 0.02)
        {
            dispatch_time_t waittime = dispatch_time(DISPATCH_TIME_NOW, 0.02 * NSEC_PER_SEC);
            
            dispatch_after(waittime, dispatch_get_main_queue(),
            ^void{
                [self handleinputbuttons:joybtn buttonstate:joybtnstat deviceid:[peerID displayName]];
            });
        }
        else
        {
             [self handleinputbuttons:joybtn buttonstate:joybtnstat deviceid:[peerID displayName]];
        }
        
        _lasttime = CACurrentMediaTime();
    }
    else
    {
        [self handleinputdirections:joydir buttontoreleasevertical:btntoreleasever buttontoreleasehorizontal:btntoreleasehor deviceid:[peerID displayName]];
    }
}


- (void) startServer {
    if(localPeerID == nil)
    {
        localPeerID = [[MCPeerID alloc] initWithDisplayName:[[UIDevice currentDevice] name]];
    }
    
    advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:localPeerID
                                      discoveryInfo:nil
                                        serviceType:XXServiceType];
    advertiser.delegate = self;
    [advertiser startAdvertisingPeer];
    [self showMessage: @"server" withMessage: @"started on this device"];
}


- (void) stopServer {
    
    [advertiser stopAdvertisingPeer];
    [session disconnect];
    session = nil;
    advertiser = nil;
    //[self showMessage: @"server" withMessage: @"stopped on this device"];
    
}

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser
didReceiveInvitationFromPeer:(MCPeerID *)peerID
       withContext:(NSData *)context
 invitationHandler:(void(^)(BOOL accept, MCSession *session))invitationHandler
{
    session = [[MCSession alloc] initWithPeer:localPeerID
                             securityIdentity:nil
                         encryptionPreference:MCEncryptionNone];
    session.delegate = self;
    
    invitationHandler(YES, session);
}

- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName
       fromPeer:(MCPeerID *)peerID
{
    NSLog(@"Received data over stream with name %@ from peer %@", streamName, peerID.displayName);
}

- (void)handleinputdirections:(TouchStickDPadState)hat_state buttontoreleasevertical:(int)buttontoreleasevertical buttontoreleasehorizontal: (int)buttontoreleasehorizontal deviceid:(NSString *)dID
{
    
    if(mainMenu_servermode == kServeAsController)
    {
        [self sendJoystickDataForDirection:hat_state buttontoreleasehorizontal: buttontoreleasehorizontal buttontoreleasevertical:buttontoreleasevertical];
        
        return;
    }
    
    [self setkeymapfordeviceID:dID];
    NSInteger pNumber = [[_settings keyConfigurationforButton:PORT] integerValue];
    
    NSString *configuredkeyhorizontal = NULL;
    NSString *configuredkeyvertical = NULL;
    int asciicodehorizontal = NULL;
    int asciicodevertical = NULL;
    NSString *configuredkeytoreleasehorizontal = NULL;
    int asciicodekeytoreleasehorizontal = NULL;
    NSString *configuredkeytoreleasevertical = NULL;
    int asciicodekeytoreleasevertical = NULL;
    
    int horButton = [self dpadstatetojoypadkey: @"horizontal" hatstate:hat_state];
    if(horButton)
    {
        configuredkeyhorizontal = [_settings keyConfigurationforButton:horButton];
        asciicodehorizontal = [[configuredkeyhorizontal stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"KEY_"]] intValue];
    }
    
    int vertButton = [self dpadstatetojoypadkey: @"vertical" hatstate:hat_state];
    if(vertButton)
    {
        configuredkeyvertical = [_settings keyConfigurationforButton:vertButton];
        asciicodevertical = [[configuredkeyvertical stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"KEY_"]] intValue];
    }
    
    if(buttontoreleasehorizontal)
    {
        configuredkeytoreleasehorizontal = [_settings keyConfigurationforButton:buttontoreleasehorizontal];
        asciicodekeytoreleasehorizontal = [[configuredkeytoreleasehorizontal stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"KEY_"]] intValue];
    }
    
    if(buttontoreleasevertical)
    {
        
        configuredkeytoreleasevertical = [_settings keyConfigurationforButton:buttontoreleasevertical];
        asciicodekeytoreleasevertical = [[configuredkeytoreleasevertical stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"KEY_"]] intValue];
    }
    
    if(asciicodekeytoreleasehorizontal)
    {
        SDL_Event ed = { SDL_KEYUP };
        ed.key.keysym.sym = (SDLKey) asciicodekeytoreleasehorizontal;
        SDL_PushEvent(&ed);
    }
    
    if(asciicodekeytoreleasevertical)
    {
        SDL_Event ed = { SDL_KEYUP };
        ed.key.keysym.sym = (SDLKey) asciicodekeytoreleasevertical;
        SDL_PushEvent(&ed);
    }
    
    if(hat_state == DPadCenter)
    {
        if(pNumber == 0) theJoystick->setDPadStateP0(hat_state);
        else theJoystick->setDPadStateP1(hat_state);
        return;
    }
    
    if([configuredkeyhorizontal  isEqual: @"Joypad"] && [configuredkeyvertical isEqual:@"joypad"])
    {
        if(pNumber == 0) theJoystick->setDPadStateP0(hat_state);
        else theJoystick->setDPadStateP1(hat_state);
        return;
    }
    
    if([configuredkeyhorizontal isEqual: @"Joypad"])
    {
        if(pNumber == 0) theJoystick->setDPadStateP0(hat_state);
        else theJoystick->setDPadStateP1(hat_state);
    }
    else if(configuredkeyhorizontal)
    {
        SDL_Event ed = { SDL_KEYDOWN };
        ed.key.keysym.sym = (SDLKey) asciicodehorizontal;
        SDL_PushEvent(&ed);
    }
    
    
    if([configuredkeyvertical isEqual: @"Joypad"])
    {
        if(pNumber == 0) theJoystick->setDPadStateP0(hat_state);
        else theJoystick->setDPadStateP1(hat_state);
    }
    else if (configuredkeyvertical)
    {
        SDL_Event ed = { SDL_KEYDOWN };
        ed.key.keysym.sym = (SDLKey) asciicodevertical;
        SDL_PushEvent(&ed);
    }
}


- (int)handleinputbuttons:(int)buttonid buttonstate:(int)buttonstate deviceid:(NSString *)dID {
    
    if(mainMenu_servermode == kServeAsController)
    {
        [self sendJoystickDataForButtonID:buttonid buttonstate:buttonstate];
        return !buttonstate;
    }
    buttonstate = !buttonstate;
    
    [self setkeymapfordeviceID:dID];
    NSInteger pNumber = [[_settings keyConfigurationforButton:PORT] integerValue];
    
    NSString *configuredkey = [_settings keyConfigurationforButton:buttonid];
    if([configuredkey  isEqual: @"Joypad"])
    {
        if(buttonstate) {
            if(pNumber == 0) theJoystick->setButtonOneStateP0(FireButtonDown);
            else theJoystick->setButtonOneStateP1(FireButtonDown);
        }
        else {
            if(pNumber == 0) theJoystick->setButtonOneStateP0(FireButtonUp);
             else theJoystick->setButtonOneStateP1(FireButtonUp);
        }
    }
    else
    {
        int asciicode = [[configuredkey stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"KEY_"]] intValue];
        
        if(buttonstate)
        {
            SDL_Event ed = { SDL_KEYDOWN };
            ed.key.keysym.sym = (SDLKey) asciicode;
            SDL_PushEvent(&ed);
        }
        else
        {
            SDL_Event eu = { SDL_KEYUP };
            eu.key.keysym.sym = (SDLKey) asciicode;
            SDL_PushEvent(&eu);
        }
    }
    
    return buttonstate;
    
}


- (int) dpadstatetojoypadkey:(NSString *)direction hatstate:(TouchStickDPadState)hat_state
{
    if(hat_state == DPadUp)
    {
        if([direction isEqual:@"vertical"])
            return BTN_UP;
        else
            return NULL;
    }
    else if(hat_state == DPadUpLeft)
    {
        if([direction isEqual:@"vertical"])
            return BTN_UP;
        else
            return BTN_LEFT;
    }
    else if(hat_state == DPadUpRight)
    {
        if([direction isEqual:@"vertical"])

            return BTN_UP;
        else
            return BTN_RIGHT;
    }
    else if(hat_state == DPadDown)
    {
        if([direction isEqual:@"vertical"])
            return BTN_DOWN;
        else
            return NULL;
    }
    else if (hat_state == DPadDownLeft)
    {
        if([direction isEqual:@"vertical"])
            return BTN_DOWN;
        else
            return BTN_LEFT;
    }
    else if (hat_state == DPadDownRight)
    {
        if([direction isEqual:@"vertical"])
            return BTN_DOWN;
        else
            return BTN_RIGHT;
    }
    else if (hat_state == DPadLeft)
    {
        if([direction isEqual:@"vertical"])
            return NULL;
        else
            return BTN_LEFT;
    }
    else if (hat_state == DPadRight)
    {
        if([direction isEqual:@"vertical"])
            return NULL;
        else
            return BTN_RIGHT;
    }
    return NULL;
}


// Start receiving a resource from remote peer.
- (void)                    session:(MCSession *)session
  didStartReceivingResourceWithName:(NSString *)resourceName
                           fromPeer:(MCPeerID *)peerID
                       withProgress:(NSProgress *)progress
{}

// Finished receiving a resource from remote peer and saved the content
// in a temporary location - the app is responsible for moving the file
// to a permanent location within its sandbox.
- (void)                    session:(MCSession *)session
 didFinishReceivingResourceWithName:(NSString *)resourceName
                           fromPeer:(MCPeerID *)peerID
                              atURL:(NSURL *)localURL
                          withError:(nullable NSError *)error
{}


@end
