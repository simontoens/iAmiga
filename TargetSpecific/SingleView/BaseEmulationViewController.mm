//
//  BaseEmulationViewController.m
//  iAmiga
//
//  Created by Stuart Carnie on 6/22/11.
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

#import "BaseEmulationViewController.h"
#import "uae.h"
#import "CocoaUtility.h"
#import "UIKitDisplayView.h"
#import "TouchHandlerView.h"
#import "NSObject+Blocks.h"
#import "iAmigaAppDelegate.h"
#import "Settings.h"

#define kDisplayWidth							640.0f  //mithrendal hires fix before was 320.0f
#define kDisplayHeight							258.0f

extern int mainMenu_stretchscreen;
extern int mainMenu_AddVerticalStretchValue;
@interface BaseEmulationViewController()

@property (nonatomic, retain) UIView<DisplayViewSurface>	*displayView;
@property (nonatomic,retain) UIWindow	*displayViewWindow;
@property (nonatomic, readonly) CGRect currentDisplayFrame;
@property (nonatomic, retain) Settings *settings;

@end

@implementation BaseEmulationViewController

@synthesize displayView, displayViewWindow;
@synthesize integralSize=_integralSize;
@dynamic bundleVersion;

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // self.integralSize = YES;
    
    UIView *view = self.view;
    
    SDL_Init(0);
	SDL_Surface *surface = SDL_SetVideoMode(kDisplayWidth, kDisplayHeight, 16, 0);
	UIView<DisplayViewSurface> *surfaceView = (UIView<DisplayViewSurface>*)surface->userdata;
    surfaceView.contentMode = UIViewContentModeScaleToFill;
	surfaceView.paused = YES;
    //[surfaceView setBackgroundColor:[UIColor redColor]];
    
	self.displayView = surfaceView;
	if (displayViewWindow != nil) {
		[displayViewWindow addSubview:self.displayView];
	} else {
		[view addSubview:self.displayView];
    }
    
    _settings = [[Settings alloc] init];
}

- (void)sendKeys:(SDLKey*)keys count:(size_t)count keyState:(SDL_EventType)keyState afterDelay:(NSTimeInterval)delayInSeconds {
    SDLKey *keyCopy = (SDLKey *)malloc(sizeof(SDLKey) * count);
    memcpy(keyCopy, keys, sizeof(SDLKey) * count);
    
    [self performBlock:^(void) {
        for (int i=0; i < count; i++) {
            SDL_Event evt;
            evt.type = keyState;
            evt.key.keysym.sym = keyCopy[i];
            SDL_PushEvent(&evt);
        }
        free(keyCopy);
    } afterDelay:delayInSeconds];
}

- (NSString *)bundleVersion {
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    return version;
}

- (void) viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[self startEmulator];
    iAmigaAppDelegate *appDelegate = (iAmigaAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate configureScreens];

}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
    
	[self pauseEmulator];
}

- (void)setIntegralSize:(BOOL)value {
	_integralSize = value;
	self.displayView.frame = self.currentDisplayFrame;
}

static CGRect CreateIntegralScaledView(CGRect aFrame, BOOL top) {
	CGSize frameSize = aFrame.size;
	CGFloat scale = frameSize.width < frameSize.height ? floorf(frameSize.width / kDisplayWidth) : floorf(frameSize.height / kDisplayHeight);
	int width = kDisplayWidth * scale, height = kDisplayHeight * scale;
	CGFloat y = top ? 0 : (frameSize.height - height) / 2;
	return CGRectMake((frameSize.width - width) / 2, y, width, height);
}

- (CGFloat)displayTop {
    return _settings.showStatusBar ? [self getStatusBarHeight] : 0;
}

- (CGFloat)getStatusBarHeight {
    CGSize statusBarSize = [[UIApplication sharedApplication] statusBarFrame].size;
    return MIN(statusBarSize.width, statusBarSize.height);
}

- (CGRect)currentDisplayFrame {
    if (_isExternal) {
		if (_integralSize) {
			return CreateIntegralScaledView(displayViewWindow.bounds, NO);
		}
		// assuming external display it's width > height
		return displayViewWindow.bounds;
	} 
    
	CGSize frameSize = self.view.frame.size;
    CGSize tmp = frameSize;
    frameSize.width = tmp.height;
    frameSize.height = tmp.width;
	
	if (_integralSize) {
		CGRect aFrame;
		if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
			aFrame = CGRectMake(0, 0, frameSize.width, frameSize.height);
		} else {
			aFrame = self.view.frame;
		}
		return CreateIntegralScaledView(aFrame, YES);
	}
	
	// full-screen, landscape mode
	if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
		
		
        int height = self.view.frame.size.height - self.displayTop;

        //Stretch or keep 3/4 aspect radio for width
        int width = mainMenu_stretchscreen ? self.view.frame.size.width : height / 3 * 4;
        
        //Center if aspect radio is not stretched
        int xpos = mainMenu_stretchscreen ? 0 : (self.view.frame.size.width - width) / 2;
        
        return CGRectMake(xpos, self.displayTop, width, height);
        
	}
	
	// aspect fill (portrait mode)
	CGFloat xRatio = frameSize.width / kDisplayWidth;
	CGFloat yRatio = frameSize.height / kDisplayHeight;
	CGFloat ratio = MIN(xRatio, yRatio);
    
	return CGRectMake(0, 0, kDisplayWidth * ratio, kDisplayHeight * ratio);
}


- (void)setDisplayViewWindow:(UIWindow*)window isExternal:(BOOL)isExternal {
	_isExternal = isExternal;
	self.displayViewWindow = window;
	if (displayView == nil)
		return;
	if (window) {
		[window addSubview:displayView];
	} else {
		[self.view insertSubview:displayView atIndex:0];
	}
	
	self.displayView.frame = self.currentDisplayFrame;
}

#pragma mark - Emulator Functions

- (void)enableUserInteraction {
	[self.view setUserInteractionEnabled:YES];
}

- (void)startEmulator {
	if (emulatorState == EmulatorPaused) {
		[self resumeEmulator];
	} else if (emulatorState == EmulatorNotStarted) {
		emulationThread = [[NSThread alloc] initWithTarget:self selector:@selector(runEmulator) object:nil];
		[emulationThread start];
		[self performSelector:@selector(enableUserInteraction) withObject:nil afterDelay:0.25];
        displayView.paused = NO;
	}
}

- (void)stopEmulator {
	[emulationThread release];
    emulationThread = nil;
    emulatorState = EmulatorNotStarted;
}

- (void)runEmulator {
	emulatorState = EmulatorRunning;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[NSThread setThreadPriority:0.7];
	g_emulator.real_main();
	[pool release];
}

- (void)pauseEmulator {
	emulatorState = EmulatorPaused;
	g_emulator.uae_pause();
	displayView.paused = YES;
}

- (void)resumeEmulator {
	if (emulatorState != EmulatorPaused)
		return;
	emulatorState = EmulatorRunning;
	g_emulator.uae_resume();
	displayView.paused = NO;
}

-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscape;
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIBarStyleBlackOpaque;
}

- (BOOL)prefersStatusBarHidden {
    return !_settings.showStatusBar;
}

@end
