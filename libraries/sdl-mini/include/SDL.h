/*
 *  sdl.h
 *  iAmiga
 *
 *  Created by Stuart Carnie on 5/18/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */
#ifndef _SDL_H
#define _SDL_H

#include "SDL_audio.h"
#include "SDL_stdinc.h"
#include "SDL_error.h"
#include "SDL_events.h"
#include "SDL_mutex.h"
#include "SDL_thread.h"
#include "SDL_timer.h"
#include "SDL_video.h"
#include "SDL_compat.h"

#ifdef __cplusplus
extern "C" {
#endif
	    
#define SDL_INIT_TIMER          0x00000001
#define SDL_INIT_AUDIO          0x00000010
#define SDL_INIT_VIDEO          0x00000020
#define SDL_INIT_JOYSTICK       0x00000200
#define SDL_INIT_HAPTIC         0x00001000
#define SDL_INIT_NOPARACHUTE    0x00100000      /**< Don't catch fatal signals */
#define SDL_INIT_EVENTTHREAD    0x01000000      /**< Not supported on all OS's */
#define SDL_INIT_EVERYTHING     0x0000FFFF

    
extern Uint32 SDL_GetTicks(void);
extern void SDL_UnlockSurface(SDL_Surface*);
extern void SDL_LockSurface(SDL_Surface*);
extern void SDL_FreeSurface(SDL_Surface*);
extern void SDL_FillRect(SDL_Surface*, void*, int);
extern long int SDL_MapRGB(tagFormat*, int, int, int);
extern int SDL_PollEvent(SDL_Event*);
extern void SDL_VideoQuit(void);
extern void SDL_PauseOpenGL(int);

extern int SDL_Init(int);
extern char* SDL_GetError(void);

#define SDL_ENABLE 1
#define SDL_DISABLE 0

// video init
#define SDL_HWSURFACE 0x00000001
#define SDL_DOUBLEBUF 0x40000000

extern int SDL_ShowCursor(int);
	
#import "SDL_events.h"
	
#ifdef __cplusplus
}
#endif

#endif
