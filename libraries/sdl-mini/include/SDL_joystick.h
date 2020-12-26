//
//  SDL_joystick.h
//  iAmiga
//
//  Created by Stuart Carnie on 6/5/11.
//  Copyright 2011 Manomio LLC. All rights reserved.
//

#ifndef _SDL_joystick_h
#define _SDL_joystick_h

#include "SDL_stdinc.h"
#include "SDL_error.h"

/* Set up for C function definitions, even when using C++ */
#ifdef __cplusplus
/* *INDENT-OFF* */
extern "C" {
    /* *INDENT-ON* */
#endif


//typedef struct SDL_Joystick {	
//} SDL_Joystick;

struct _SDL_Joystick;
typedef struct _SDL_Joystick SDL_Joystick;

extern int SDL_NumJoysticks(void);
extern const char * SDL_JoystickName(int device_index);
extern SDL_Joystick* SDL_JoystickOpen(int);
extern int SDL_JoystickNumButtons(SDL_Joystick*);
extern void SDL_JoystickUpdate(void);
extern void SDL_JoystickSetActive(SDL_Joystick * joystick);
    
/**
 *  Enable/disable joystick event polling.
 *  
 *  If joystick events are disabled, you must call SDL_JoystickUpdate()
 *  yourself and check the state of the joystick when you want joystick
 *  information.
 *  
 *  The state can be one of ::SDL_QUERY, ::SDL_ENABLE or ::SDL_IGNORE.
 */
extern DECLSPEC int SDLCALL SDL_JoystickEventState(int state);

/**
 *  Get the current state of an axis control on a joystick.
 *  
 *  The state is a value ranging from -32768 to 32767.
 *  
 *  The axis indices start at index 0.
 */
extern Sint16 SDL_JoystickGetAxis(SDL_Joystick*, int);

/*
 * Get the current state of a POV hat on a joystick
 * The return value is one of the following positions:
 */
    
#define SDL_HAT_CENTERED	0x00
#define SDL_HAT_UP			0x01
#define SDL_HAT_RIGHT		0x02
#define SDL_HAT_DOWN		0x04
#define SDL_HAT_LEFT		0x08
#define SDL_HAT_RIGHTUP		(SDL_HAT_RIGHT|SDL_HAT_UP)
#define SDL_HAT_RIGHTDOWN	(SDL_HAT_RIGHT|SDL_HAT_DOWN)
#define SDL_HAT_LEFTUP		(SDL_HAT_LEFT|SDL_HAT_UP)
#define SDL_HAT_LEFTDOWN	(SDL_HAT_LEFT|SDL_HAT_DOWN)

extern Uint8 SDL_JoystickGetHat(SDL_Joystick * joystick, int hat);
extern Uint8 SDL_JoystickGetButton(SDL_Joystick*, int);
extern void SDL_JoystickClose(SDL_Joystick*);
extern int SDL_JoystickGetPaused(SDL_Joystick*);

/* Ends C function definitions when using C++ */
#ifdef __cplusplus
/* *INDENT-OFF* */
}
/* *INDENT-ON* */
#endif

#endif
