//
//  SDL_UIKitVideo.m
//  Flashback
//
//  Created by Stuart Carnie on 7/31/11.
//  Copyright 2011 Manomio LLC. All rights reserved.
//

#include "SDL_config.h"

#include "SDL_video.h"
#include "SDL_mouse.h"
#include "../SDL_sysvideo.h"
#include "../../events/SDL_events_c.h"

#include "SDL_UIKitVideo.h"
#include "SDL_UIKitEvents.h"

#define UIKITVID_DRIVER_NAME "uikit"

/* Initialization/Query functions */
//static int UIKit_VideoInit(_THIS);
//static void UIKit_VideoQuit(_THIS);

BOOL SDL_UIKit_supports_multiple_displays = NO;

/* DUMMY driver bootstrap functions */

static int
UIKit_Available(void)
{
	return (1);
}

static void UIKit_DeleteDevice(SDL_VideoDevice * device)
{
    SDL_free(device);
}

static SDL_VideoDevice *
UIKit_CreateDevice(int devindex)
{
    SDL_VideoDevice *device;
    
    /* Initialize all variables that we clean on shutdown */
    device = (SDL_VideoDevice *) SDL_calloc(1, sizeof(SDL_VideoDevice));
    if (!device) {
        SDL_OutOfMemory();
        if (device) {
            SDL_free(device);
        }
        return (0);
    }
    
    /* Set the function pointers */
    //device->VideoInit = UIKit_VideoInit;
    //device->VideoQuit = UIKit_VideoQuit;
    device->PumpEvents = UIKit_PumpEvents;
    device->free = UIKit_DeleteDevice;
	
    return device;
}

VideoBootStrap UIKIT_bootstrap = {
    UIKITVID_DRIVER_NAME, "SDL UIKit video driver",
    UIKit_Available, UIKit_CreateDevice
};

