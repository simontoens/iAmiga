//
//  TouchHandlerView.m
//  iAmiga
//
//  Created by Stuart Carnie on 1/2/11.
//  Copyright 2011 Manomio LLC. All rights reserved.
//
//
//  TouchHandlerViewClassic.m
//  iAmiga
//
//  Changed by Emufr3ak on 23.04.14.
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



#import "TouchHandlerViewClassic.h"
#import "SDL.h"
#import "SDL_events.h"
#import "SDL_mouse_c.h"
#import "KeyButtonViewHandler.h"

@implementation TouchHandlerViewClassic {
    NSTimer *timer;
    NSTimeInterval durationtouch;
    bool draggingon;
    NSDate *now;
    UILabel *ldraggingon;
    UILabel *ldurationtouch;
    KeyButtonViewHandler *keyButtonViewHandler;
}

@synthesize clickedscreen = _clickedscreen;
    
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code.
		self.multipleTouchEnabled = YES;
    }
    
    timer = [[NSTimer scheduledTimerWithTimeInterval:0.020 target:self
                                            selector:@selector(timerEvent:) userInfo:nil repeats:YES ] retain];
    
    draggingon = FALSE;
    
    ldraggingon = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 10)];
    ldurationtouch = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 100, 10)];
    
    /*[self addSubview:ldraggingon];
    [self addSubview:ldurationtouch];*/
    
    keyButtonViewHandler = [[KeyButtonViewHandler alloc] initWithSuperview:self];
    
    return self;
}

-(void)timerEvent:(NSTimer*)timer
{
    //Press Left Mouse Button down and keep down if tab is pressed for more than one second without moving
    
    /*[ldraggingon setText: (draggingon ? @"YES" : @"NO")];
    [ldurationtouch setText:[NSString stringWithFormat:@"%f", durationtouch]];*/
    
    if(starttimetouch && !didMove && !draggingon)
    {
        now = [NSDate date];
        durationtouch = [now timeIntervalSinceDate:starttimetouch];
    }
    
    if(durationtouch > 1)
    {
        SDL_SendMouseButton(NULL, SDL_PRESSED, SDL_BUTTON_LEFT);
        draggingon = YES;
    }
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.multipleTouchEnabled = YES;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    x_ratio = self.frame.size.width / 320.0f / 2.0f; /* King of Chicago */
    y_ratio = self.frame.size.height / 240.0f / 2.0f; /* King of Chicago */
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *touchtype = [event allTouches];
    int touchCounts = (int) [touchtype count];
    
    UITouch *touch = [touches anyObject];
    
    if (touch.phase == UITouchPhaseBegan)
    {
        if (touchCounts == 2)
        {
            rightTouch = touch;
            SDL_SendMouseButton(NULL, SDL_PRESSED, SDL_BUTTON_RIGHT);
        }
        else
        {
            leadTouch = touch;
            previousMouseLocation = [touch locationInView: self];
            didMove = NO;
            starttimetouch = [[NSDate alloc] init]; //Neccessary for dragging (long touch and then Move = Drag)
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (leadTouch)
    {
        CGPoint locationInView = [leadTouch locationInView:self];
        CGFloat relx = (locationInView.x - previousMouseLocation.x) / x_ratio;
        CGFloat rely = (locationInView.y - previousMouseLocation.y) / y_ratio;
        
        if (fabs(relx) < 1.0f)
            relx = 0.f;
        if (fabs(rely) < 1.0f)
            rely = 0.f;
        
        if (relx != 0.0f || rely != 0.0f)
        {
            SDL_SendMouseMotion(NULL, SDL_MOTIONRELATIVE, relx, rely);
            
            if (relx != 0.0f)
                previousMouseLocation.x = locationInView.x;
            
			if (rely != 0.0f)
                previousMouseLocation.y = locationInView.y;
            
            didMove = YES;
        }
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self touchesEnded:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    _clickedscreen = true;
    
    for (UITouch *touch in touches)
    {
        if (touch.phase == UITouchPhaseEnded)
        {
            if (touch == leadTouch)
            {
                leadTouch = nil;
                //printf("Move End\n");
                
                if(draggingon == NO)
                {
                    if (didMove == NO)
                    {
                        SDL_SendMouseButton(NULL, SDL_PRESSED, SDL_BUTTON_LEFT);
                        //printf("Left press\n");
                        
                        // 50ms after, push up
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 50 * 1000000), dispatch_get_main_queue(), ^{
                            SDL_SendMouseButton(NULL, SDL_RELEASED, SDL_BUTTON_LEFT);
                            //printf("Left release\n");
                        });
                    }
                }
                else
                //Left Mousebutton Down while Moving Mouse on (Allows Drag and Drop among others)
                {
                   SDL_SendMouseButton(NULL, SDL_RELEASED, SDL_BUTTON_LEFT);
                }
                
                draggingon = NO;
                [starttimetouch release];
                starttimetouch = nil;
                durationtouch = 0;
            }
            else if (touch == rightTouch)
            {
                rightTouch = Nil;
                SDL_SendMouseButton(NULL, SDL_RELEASED, SDL_BUTTON_RIGHT);
                //printf("Right release\n");
            }
        }
    }
}

- (void)reloadMouseSettings
{
    [self onMouseActivated];
}

- (void)onMouseActivated
{
    [keyButtonViewHandler addConfiguredKeyButtonViews];
}

- (BOOL)clickedscreen {
    // did the user move the mouse or use key buttons?
    return _clickedscreen || keyButtonViewHandler.anyButtonWasTouched;
}

- (void)setClickedscreen:(BOOL)clickedscreen {
    _clickedscreen = clickedscreen;
    keyButtonViewHandler.anyButtonWasTouched = clickedscreen;
}

- (void)dealloc
{
    [starttimetouch release];
    [ldraggingon release];
    [ldurationtouch release];
    [timer release];
    [keyButtonViewHandler release];
    [super dealloc];
}

@end
