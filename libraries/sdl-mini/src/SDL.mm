/*
 *  SDL.c
 *  iAmiga
 *
 *  Created by Stuart Carnie on 5/19/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */
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

// #import <Foundation/Foundation.h>
#import "unistd.h"
#include "stdlib.h"
#include "SDL.h"
//#include "AudioQueueManager.h"
#import "sdl_internal.h"
#import <sys/time.h>
#include "joystick/SDL_joystick_c.h"

#if USE_CG_SURFACE
#include "DisplayView.h"
#else
#include "OGLDisplay.h"
#endif

// statics
static Uint32						time_start;
static SDL_Surface					currentVideoSurface;
static tagFormat					currentVideoFormat;

static UIView<DisplayViewSurface>	*view;

#define kBufferWidth		320
#define kBufferHeight		240

Uint32 SDL_GetTicks() {
	timeval tv;
	gettimeofday(&tv, NULL);
	return (int) (tv.tv_sec - time_start) * 1000UL + tv.tv_usec / 1000;
}

void SDL_UnlockSurface(SDL_Surface* a) {
}

void SDL_LockSurface(SDL_Surface* a) {
}

void SDL_FreeSurface(SDL_Surface* a) {
}

void SDL_FillRect(SDL_Surface* a, void* b, int c) {
}

void SDL_UpdateRect(SDL_Surface* s, int a, int b, int c, int d) {
	SDL_Flip(s);
}

void SDL_Delay(Uint32 duration) {
	usleep(duration * 1000);
}

long int SDL_MapRGB(tagFormat* a, int b, int c, int d) {
	return 0;
}

void SDL_VideoQuit() {
}

int SDL_Init(int initFlags) {
	timeval tv;
	gettimeofday(&tv, NULL);
	time_start = (int) tv.tv_sec;
    
    SDL_VideoInit(NULL, initFlags);

    //SDL_JoystickInit();
	
	return 0;
}

SDL_Surface* SDL_SetVideoMode(int width, int height, int bitsPerPixel, int flags) {
	SDL_Surface *s = &currentVideoSurface;
	
	if (view != nil) {
		NSLog(@"ERROR, video mode already set!");
		return s;
	}
	tagFormat *fmt = &currentVideoFormat;

#if USE_CG_SURFACE
	view = CreateCGDisplayView(width, height);
	fmt->Rshift = 10;
	fmt->Gshift = 5;
	fmt->Bshift = 0;
	fmt->Rmask = 0x1f << 10;
	fmt->Gmask = 0x1f << 5;
	fmt->Bmask = 0x1F;
#else
	view = CreateOGLDisplayView(width, height);
	fmt->Rshift = 11;
	fmt->Gshift = 5;
	fmt->Bshift = 0;
	fmt->Rmask = 0x1f << 11;
	fmt->Gmask = 0x3f << 5;
	fmt->Bmask = 0x1F;
#endif
		
	fmt->BytesPerPixel = 2;
	s->format = fmt;
	s->w = width;
	s->h = height;
	s->pitch = width * fmt->BytesPerPixel;
	s->pixels = view.pixels;
	s->userdata = view;
    
    
	return s;
}

SDL_Surface* SDL_GetVideoSurface() {
	return &currentVideoSurface;
}

void SDL_Flip(SDL_Surface* surface) {
#if 0
	static Uint32 startTime = SDL_GetTicks();
	static Uint32 count = 0;
	
	Uint32 now = SDL_GetTicks();
	count++;
	
	if (now - startTime > 1000) {
		startTime = now;
		printf("%d frames per second\n", count);
		count = 0;
	}
#endif
#if USE_CG_SURFACE
	UpdateScreen();
#else
	UpdateOGLScreen();
#endif
}

char* SDL_GetError() {
	return 0;
}

int SDL_ShowCursor(int a) {
	return 0;
}

#pragma mark
#pragma mark Audio Handlers

void SDL_PauseOpenGL(int paused)
{
    if(paused) {
        [view setPaused:true];
    } else {
        [view setPaused:false];
    }
    
}

#if 0

static CAudioQueueManager *g_audioQueue;
static SDL_AudioSpec g_spec;

int SDL_OpenAudio(SDL_AudioSpec* spec,void* data) {
	g_spec = *spec;
	g_audioQueue = new CAudioQueueManager(spec->freq, spec->samples, (SoundChannels)spec->channels);
	//g_audioQueue->setCallbackHandler((soundqueue_callback_t)g_spec.callback);
	g_audioQueue->start(false);
	return 0;
}

void SDL_CloseAudio() {
	g_audioQueue->stop();
}

void SDL_PauseAudio(int paused) {
	if (paused) {
		g_audioQueue->pause();
	} else {
		g_audioQueue->resume();
	}
}
#endif
