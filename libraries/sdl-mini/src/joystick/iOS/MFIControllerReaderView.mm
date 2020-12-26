//  Created by Emufr3ak on 29.05.14.
//  Changed By Emufr3ak on 21.08.16
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

#import "MFIControllerReaderView.h"
#import <UIKit/UIKit.h>
#import "debug.h"
#import "touchstick.h"
#import "JoypadKey.h"
#import "Settings.h"
#import "SDL_events.h"
#import "MultiPeerConnectivityController.h"

extern "C" {
    #import "SDL_events.h"
    #import "SDL_mouse_c.h"
}
    
#import <ExternalAccessory/ExternalAccessory.h>

#define MOUSESPEED 3.00

#define DIGSTICK 1
#define LANSTICK 2
#define RANSTICK 3

//static NSString *const kdigStick = @"digStick";
//static NSString *const klanalogStick = @"lanalogStick";
//static NSString *const kranalogStick = @"ranalogStick";


@implementation MFIControllerReaderView {
    int _button[9];
    TouchStickDPadState _hat_statelast;
    TouchStickDPadState _hat_state;

    TouchStickDPadState _mlastHatstate;
    TouchStickDPadState _mHatstate;
    
    MultiPeerConnectivityController *mpcController;
    int _buttontoreleasehorizontal;
    int _buttontoreleasevertical;
    int _mrelvertButton;
    int _mrelhorButton;
    int _devCount;
    Settings *_settings;
    int _mouseX;
    int _mouseY;
    NSTimer *_mouseTimer;
}



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    _devCount = 0;
    _hat_state = DPadCenter;
    _buttonapressed = false;
    _hat_statelast = DPadCenter;
    mpcController = [MultiPeerConnectivityController getinstance];
    
    for(int i=0;i<=7;i++)
        _button[i] = 0;
    
    [self initNotifications];
    //[self initControllers];
    
    _settings = [[Settings alloc] init];

    if(_settings.LStickAnalogIsMouse || _settings.RStickAnalogIsMouse) {
        if (_mouseTimer) {
            [_mouseTimer release];
        }
        _mouseTimer = [[NSTimer scheduledTimerWithTimeInterval:0.020 target:self
                                                       selector:@selector(moveMouse:) userInfo:nil repeats:YES] retain];
        _mouseTimer.tolerance = 0.0020;
    }
    
    return self;
    
}

- (void)initNotifications {
    
    [[EAAccessoryManager sharedAccessoryManager] registerForLocalNotifications];
    [GCController startWirelessControllerDiscoveryWithCompletionHandler:nil];
    
    /*[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceDisconnected:)
                                                 name:EAAccessoryDidDisconnectNotification
                                               object:nil];*/
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(controllerDiscovered:)
                                                 name:GCControllerDidConnectNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(controllerDisconnected:)
                                                 name:GCControllerDidDisconnectNotification
                                               object:nil];
}

-(void)moveMouse:(NSTimer *)timer {
    SDL_SendMouseMotion(NULL, SDL_MOTIONRELATIVE, _mouseX, _mouseY);
}

- (void)handleinputbuttons:(int)buttonid forDeviceid:(NSString *)devID
{

    if((buttonid == BTN_L2 && _settings.useL2forMouseButton == true) ||
       (buttonid == BTN_R2 && _settings.useR2forRightMouseButton == true))
        [self handleminputbuttons:(int)buttonid];
    else
        _button[buttonid] = [mpcController handleinputbuttons:buttonid buttonstate:_button[buttonid] deviceid:devID];
}

- (void)handleminputbuttons:(int)buttonid {
    _button[buttonid] = !_button[buttonid];
    
    int mbtnID = buttonid == BTN_L2 ? SDL_BUTTON_LEFT : SDL_BUTTON_RIGHT;
    
    if(_button[buttonid]) SDL_SendMouseButton(NULL, SDL_PRESSED, mbtnID);
    else SDL_SendMouseButton(NULL, SDL_RELEASED, mbtnID);
}   

- (void) handlehatstate:(float)xAxis yAxis:(float)yAxis forDeviceid:(NSString *)devID forStick:(int)stickType; {
    
   
    
    if((stickType == LANSTICK && _settings.LStickAnalogIsMouse) ||
       (stickType == RANSTICK && _settings.RStickAnalogIsMouse)) {
        [self handlemhatstate:xAxis yAxis:yAxis];
    }
    else {
        if(xAxis < 0) {
            if(yAxis > 0)                       [self handlejhatstate:DPadUpLeft forDeviceid:devID];
            else if(yAxis < 0)                  [self handlejhatstate:DPadDownLeft forDeviceid:devID];
            else                                [self handlejhatstate:DPadLeft forDeviceid:devID ];
        }
        else if(xAxis > 0)
        {
            if(yAxis > 0)                       [self handlejhatstate:DPadUpRight forDeviceid:devID];
            else if(yAxis < 0)                  [self handlejhatstate:DPadDownRight forDeviceid:devID];
            else                                [self handlejhatstate:DPadRight forDeviceid:devID];
        }
        else if(yAxis > 0)                      [self handlejhatstate:DPadUp forDeviceid:devID];
        else if(yAxis < 0)                      [self handlejhatstate:DPadDown forDeviceid:devID];
    }
}

- (void) handlejhatstate:(TouchStickDPadState)hatState forDeviceid:(NSString *)devID {
    
    _hat_state = hatState;
    
    if (_hat_state != _hat_statelast) {
        _hat_statelast = _hat_state;
        
        int buttonvertical = [mpcController dpadstatetojoypadkey:@"vertical" hatstate:_hat_state];
        int buttonhorizontal = [mpcController dpadstatetojoypadkey:@"horizontal" hatstate: _hat_state];
        
        [mpcController handleinputdirections:_hat_state buttontoreleasevertical:_buttontoreleasevertical buttontoreleasehorizontal: _buttontoreleasehorizontal deviceid:devID];
        
        _buttontoreleasehorizontal = buttonhorizontal;
        _buttontoreleasevertical = buttonvertical;
    }

}

- (void) handlemhatstate:(float)xAxis yAxis:(float)yAxis {
    
    _mouseX = (int) (xAxis * MOUSESPEED);
    _mouseY = (int) (yAxis * MOUSESPEED) * -1;

}

- (void)controllerDisconnected:(NSNotification *) btDevice {
    
    int devCount = (int) [[GCController controllers] count];
    if(devCount >= _devCount) return;

    NSString *devID = [NSString stringWithFormat:@"%p", btDevice];
    [mpcController controllerDisconnected:devID];
}

- (void)controllerDiscovered:(NSNotification *)connectedNotification {
    
    int devCount = (int) [[GCController controllers] count];
    _devCount = devCount;
     
    GCController *controller = GCController.controllers[_devCount-1];
    NSString *devID = [NSString stringWithFormat:@"%p", controller];
    //NSString *devID = @"test";
    
    controller.extendedGamepad.valueChangedHandler = ^(GCExtendedGamepad *gamepad, GCControllerElement
                                               *element)
    {
        
        if(gamepad.buttonA.isPressed != _button[BTN_A])
            [self handleinputbuttons: BTN_A forDeviceid:devID];
        else if(gamepad.buttonB.isPressed != _button[BTN_B])
               [self handleinputbuttons: BTN_B forDeviceid:devID];
        else if(gamepad.buttonX.isPressed!= _button[BTN_X])
               [self handleinputbuttons: BTN_X forDeviceid:devID];
        else if(gamepad.buttonY.isPressed != _button[BTN_Y])
               [self handleinputbuttons: BTN_Y forDeviceid:devID];
        else if(gamepad.rightShoulder.isPressed != _button[BTN_R1])
               [self handleinputbuttons: BTN_R1 forDeviceid:devID];
        else if(gamepad.leftShoulder.isPressed != _button[BTN_L1])
                [self handleinputbuttons: BTN_L1 forDeviceid:devID];
        else if(gamepad.controller.extendedGamepad.rightTrigger.isPressed != _button[BTN_R2])
                [self handleinputbuttons: BTN_R2 forDeviceid:devID];
        else if(gamepad.controller.extendedGamepad.leftTrigger.isPressed !=     _button[BTN_L2])
              [self handleinputbuttons: BTN_L2 forDeviceid:devID];
        
        float dxValue = gamepad.dpad.xAxis.value;
        float dyValue = gamepad.dpad.yAxis.value;
        float alxValue = gamepad.controller.extendedGamepad.leftThumbstick.xAxis.value;
        float alyValue = gamepad.controller.extendedGamepad.leftThumbstick.yAxis.value;
        float arxValue = gamepad.controller.extendedGamepad.rightThumbstick.xAxis.value;
        float aryValue = gamepad.controller.extendedGamepad.rightThumbstick.yAxis.value;
        
        if(dxValue != 0 || dyValue != 0)
            [self handlehatstate:dxValue yAxis:dyValue forDeviceid:devID forStick:DIGSTICK];
        else if(alxValue != 0 || alyValue != 0)
            [self handlehatstate:alxValue yAxis:alyValue forDeviceid:devID forStick:LANSTICK];
        else if(arxValue != 0 || aryValue != 0)
            [self handlehatstate:arxValue yAxis:aryValue forDeviceid:devID forStick:RANSTICK];
        else {
            [self handlejhatstate:DPadCenter forDeviceid:devID];
            [self handlemhatstate:0.00 yAxis:0.00];
        }
    };
    
    GCControllerDirectionPad *dpad = controller.extendedGamepad.dpad;
    dpad.valueChangedHandler = ^ (GCControllerDirectionPad *directionpad,
                                  float xValue, float yValue) {
        NSLog(@"Changed xValue on dPad = %f yValue = %f" ,xValue, yValue);
    };
    
    dpad.xAxis.valueChangedHandler = ^(GCControllerAxisInput *xAxis,float value) {
        NSLog(@"X Axis changed value %f",value);
    };
    
}

-(void)dealloc
{
    if (_mouseTimer) {
        [_mouseTimer release];
    }
    
    [super dealloc];
}

@end

