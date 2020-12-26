//
//  SDL_compat.h
//  Flashback
//
//  Created by Stuart Carnie on 7/24/11.
//  Copyright 2011 Manomio LLC. All rights reserved.
//

#ifndef _SDL_compat_h
#define _SDL_compat_h

/* Set up for C function definitions, even when using C++ */
#ifdef __cplusplus
/* *INDENT-OFF* */
extern "C" {
    /* *INDENT-ON* */
#endif

extern SDL_Surface* SDL_SetVideoMode(int, int, int, int);
extern SDL_Surface* SDL_GetVideoSurface(void);
extern void SDL_UpdateRect(SDL_Surface*, int, int, int, int);
extern void SDL_Flip(SDL_Surface*);

/* Ends C function definitions when using C++ */
#ifdef __cplusplus
    /* *INDENT-OFF* */
}
/* *INDENT-ON* */
#endif

#endif
