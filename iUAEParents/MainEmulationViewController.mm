//
//  DOTCEmulationViewController.m
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
// You should have received a copy of the GNU General Public License
//along with this program; if not, write to the Free Software
//Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

#import <WebKit/WebKit.h>

#import "MainEmulationViewController.h"
#import "VirtualKeyboard.h"
#import "IOSKeyboard.h"
#import "uae.h"
#import "sysconfig.h"
#import "sysdeps.h"
#import "options.h"
#import "SDL.h"
#import "UIKitDisplayView.h"
#import "savestate.h"
#import "AudioService.h"
#import "Settings.h"
#import "SettingsGeneralController.h"
#import "CoreSetting.h"
#import "DiskDriveService.h"
#import "HardDriveService.h"
#import <GameController/GameController.h>
#import "MultiPeerConnectivityController.h"
#import "VPadMotionController.h"
#import "cfgfile.h"
#import "MFIControllerReaderView.h"
#import "MPCConnectionStates.h"
#import "Icadereaderview.h"
#import "NSObject+Blocks.h"

extern int mainMenu_ntsc;
extern MPCStateType mainMenu_servermode;
extern void init_joystick();

@interface MainEmulationViewController()
@end

@implementation MainEmulationViewController {
    AudioService *_audioService;
    DiskDriveService *_diskDriveService;
    HardDriveService *_hardDriveService;
    NSTimer *_menuHidingTimer;
    Settings *_settings;
    NSTimer *_checkForPausedTimer;
    NSTimer *_checkForGControllerTimer;
    MFIControllerReaderView *_mfiController;
    iCadeReaderView *_icadeController;
 }

MultiPeerConnectivityController *mpcController = [[MultiPeerConnectivityController alloc] init]; //Needs to be called this early and out of class context to ensure it loads first
RomCoreSetting *romSetting = [[RomCoreSetting alloc] initWithName:@"ROM"];
HD0PathCoreSetting *hdpathSetting = [[HD0PathCoreSetting alloc] initWithName:@"HD0Path"];
CMemCoreSetting *cmemsetting = [[CMemCoreSetting alloc] initWithName:@"Chipmem"];
FMemCoreSetting *fmemsetting = [[FMemCoreSetting alloc] initWithName:@"Fastmem"];

UIButton *btnSettings;
IOSKeyboard *ioskeyboard;

extern void uae_reset();

- (IBAction)restart:(id)sender {
    uae_reset();
}

-(void) webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    NSString *fn = [NSString stringWithFormat:@"setVersion('%@');", self.bundleVersion];
    [webView evaluateJavaScript:fn completionHandler:^(id _Nullable, NSError * _Nullable error) {
        //
    }];
}

- (CGFloat)screenHeight {
    CGRect screenRect = CGRectZero;
    screenRect = [[UIScreen mainScreen] bounds];
    return screenRect.size.height;
}

- (CGFloat)screenWidth {
    CGRect screenRect = CGRectZero;
    screenRect = [[UIScreen mainScreen] bounds];
    return screenRect.size.width;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _audioService = [[AudioService alloc] init];
    _diskDriveService = [[DiskDriveService alloc] init];
    _hardDriveService = [[HardDriveService alloc] init];
    _settings = [[Settings alloc] init];
    
    [self.view setMultipleTouchEnabled:TRUE];
    
    [_btnJoypad setImage:[UIImage imageNamed:@"controller_selected.png"] forState:UIControlStateSelected];
    [_btnSettings setImage:[UIImage imageNamed:@"gear_selected.png"] forState: UIControlStateHighlighted];
    [_btnKeyboard setImage:[UIImage imageNamed:@"keyboard_selected.png"] forState:UIControlStateHighlighted];
    [_btnPin setImage:[UIImage imageNamed:@"sticky_selected.png"] forState:UIControlStateSelected];
    
    mainMenu_ntsc = _settings.ntsc;
    
    [self initMenuBarHidingTimer];
    [self initCheckForPausedTimer];
    
    [self initVolumeTimer:_settings.volume];
    
    [self initHardDriveMountInfo]; // Initialized early so that a hard file can be mounted below if autoload is enabled
    
    if (_settings.autoloadConfig)
    {
        // enabling things here uses timers because the the emulator isn't initialized yet right here;
        // we need to delay some tasks by a little bit
        [self initDriveSetupTimer:_settings.driveState];
        [self initDiskInsertTimer:_settings.insertedFloppies];
        [self mountHardfile:_settings.hardfilePath asReadOnly:_settings.hardfileReadOnly];
    }
    
    [self initializeControls];
    paused = 0;
    
     _mfiController = [[MFIControllerReaderView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    [self initIcade];
    
    [_mouseHandler onMouseActivated];

}

- (void)initIcade {
    
    _icadeController = [[iCadeReaderView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    
    SDL_Surface *surface = SDL_GetVideoSurface();
    UIView *display = (UIView *)surface->userdata;
    
    [display performBlock:^(void) {
        // main thread
        [display addSubview:_icadeController];
        [_icadeController becomeFirstResponder];
        
    } afterDelay:0.0f];

    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self applyConfiguredEffect];
    
    [_mouseHandler reloadMouseSettings];
    [_joyController reloadJoypadSettings];
    
    
    _icadeController.active = YES;
    [_icadeController becomeFirstResponder];
    
    if (joyactive && _settings.DPadModeIsMotion){
        [VPadMotionController setActive];
    }
    
    [mpcController configure: self];
}

- (void)viewDidDisappear:(BOOL)animated {
    [VPadMotionController disable];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    UITabBarController *tabBarController = segue.destinationViewController;
    SettingsGeneralController *settingsController = [tabBarController.viewControllers objectAtIndex:0];
    settingsController.resetDelegate = self;
}

- (void)didSelectReset:(DriveState *)driveState {
    uae_reset();
    [self initDriveSetupTimer:driveState];
}

- (void)applyConfiguredEffect {
    SDL_Surface *video = SDL_GetVideoSurface();
    id<DisplayViewSurface> display = (id<DisplayViewSurface>)video->userdata;
    display.displayEffect = (DisplayEffect)_settings.selectedEffectIndex;
}

- (void)initializeJoypad:(InputControllerView *)joyController {
    /* Check if function is still needed */
    _joyController.hidden = TRUE;
    joyactive = FALSE;
    [VPadMotionController disable];
}

- (void)initializeControls {
    joyactive = FALSE;
    _mouseHandler.hidden = FALSE;
    _joyController.hidden = TRUE;
    [VPadMotionController disable];
}

extern  void mousehack_setdontcare_iuae ();
extern  void mousehack_setfollow_iuae ();
extern void togglemouse (void);
- (IBAction)toggleControls:(UIButton *)button {
    
    bool keyboardactiveonstart = keyboardactive;
    
    keyboardactive = (button == _btnKeyboard) ? !keyboardactive : FALSE;
    joyactive = (button == _btnJoypad) ? !joyactive : FALSE;
    
    _btnKeyboard.selected = (button == _btnKeyboard) ? !_btnKeyboard.selected : FALSE;
    _btnJoypad.selected = (button == _btnJoypad) ? !_btnJoypad.selected : FALSE;
    
    //_btnJoypad.tintColor = _btnJoypad.selected ? [UIColor blueColor] : [UIColor blackColor];
    
    _joyController.hidden = !joyactive;

    
    if (joyactive && _settings.DPadModeIsMotion){
        [VPadMotionController setActive];
    }
    else{
        [VPadMotionController disable];
    }
    
    _mouseHandler.hidden = joyactive;

    if (joyactive)
    {
        [_joyController onJoypadActivated];
         mousehack_setdontcare_iuae();
    }
    else
    {
        [_mouseHandler onMouseActivated];
         mousehack_setfollow_iuae();
    }
    
    if (keyboardactive != keyboardactiveonstart)
    {
        [ioskeyboard toggleKeyboard];
    }
    
    if(!keyboardactive)
    {
        [_icadeController setActive:YES];
        [_icadeController becomeFirstResponder];
    }
}

- (IBAction)togglePinstatus:(id)sender {
    
    _btnPin.selected = !_btnPin.selected;
    //_btnPin.tintColor = _btnPin.selected ? [UIColor blueColor] : [UIColor blackColor];
    
    _mouseHandler.clickedscreen = false;
    _joyController.clickedscreen = false;
}

- (void)initializeKeyboard {
    
    keyboardactive = FALSE;
    
    ioskeyboard = [[IOSKeyboard alloc] initAndCreateDummyFields:self.view];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
}

- (IBAction)keyboardDidHide:(id)sender {
    //
}

-(IBAction)enableMenuBar:(id)sender {
    _menuBar.hidden = false;
    _menuBarEnabler.hidden = true;
    _mouseHandler.clickedscreen = false;
    _joyController.clickedscreen = false;
    [self initMenuBarHidingTimer];
}

-(void)checkForMenuBarHiding:(NSTimer*)timer {
    if((_mouseHandler || _joyController) && !_btnPin.selected && _menuBar.hidden == false)
    {
        if(_mouseHandler.clickedscreen || _joyController.clickedscreen)
        {
            _mouseHandler.clickedscreen = false;
            _joyController.clickedscreen = false;
            _menuBar.hidden = true;
            _menuBarEnabler.hidden = false;

            [_menuHidingTimer invalidate];
            [_menuHidingTimer release];
            _menuHidingTimer = nil;
        }
    }
}

-(void)checkForPaused:(NSTimer *)timer {
    
    if(mainMenu_servermode == kServeAsController)
    {
        uae_reset();
        [self pauseEmulator];
    }
}

- (void)initDriveSetupTimer:(DriveState *)driveState {
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(setupDrives:) userInfo:driveState repeats:NO];
}

- (void)initDiskInsertTimer:(NSArray *)insertedFloppies {
    [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(insertConfiguredDisks:) userInfo:insertedFloppies repeats:NO];
}

- (void)initMenuBarHidingTimer {
    if (_menuHidingTimer) {
        [_menuHidingTimer release];
    }
    _menuHidingTimer = [[NSTimer scheduledTimerWithTimeInterval:0.020 target:self
                                                       selector:@selector(checkForMenuBarHiding:) userInfo:nil repeats:YES] retain];
    _menuHidingTimer.tolerance = 0.0020;

}

- (void)initCheckForPausedTimer {
    if (_checkForPausedTimer) {
        [_checkForPausedTimer release];
    }
    
    _checkForPausedTimer = [[NSTimer scheduledTimerWithTimeInterval:0.020 target:self
                                                           selector:@selector(checkForPaused:) userInfo:nil repeats:YES] retain];
    
    _checkForPausedTimer.tolerance = 0.0020;
}

- (void)initHardDriveMountInfo {
    init_mountinfo();
}

- (void)insertConfiguredDisks:(NSTimer *)timer {
    NSArray *insertedFloppies = timer.userInfo;
    if ([insertedFloppies count] > 0)
    {
        [_diskDriveService insertDisks:insertedFloppies];
        [_settings setFloppyConfigurations:insertedFloppies];
    }
}

- (void)setupDrives:(NSTimer *)timer {
    DriveState *driveState = timer.userInfo;
    [_diskDriveService setDriveState:driveState];
}

- (void)mountHardfile:(NSString *)hardfilePath asReadOnly:(BOOL)readOnly {
    if (hardfilePath)
    {
        [_hardDriveService mountHardfile:hardfilePath asReadOnly:readOnly];
    }    
}

- (void)initVolumeTimer:(float)volume {
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(initVolume:) userInfo:[NSNumber numberWithFloat:volume] repeats:NO];
}

- (void)initVolume:(NSTimer *)timer {
    NSNumber *volume = timer.userInfo;
    [_audioService setVolume:[volume floatValue]];
}

- (void)dealloc
{
    [_audioService release];
    [_btnJoypad release];
    [_btnKeyboard release];
    [_btnPin release];
    [_diskDriveService release];
    [_hardDriveService release];
    [_mouseHandler release];
    [_menuBar release];
    [_menuBarEnabler release];
    [_menuHidingTimer invalidate];
    [_menuHidingTimer release];
    [_settings release];
    [super dealloc];
}

@end
