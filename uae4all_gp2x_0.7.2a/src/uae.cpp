/*
  * UAE - The Un*x Amiga Emulator
  *
  * Main program
  *
  * Copyright 1995 Ed Hanway
  * Copyright 1995, 1996, 1997 Bernd Schmidt
  */

#include "sysconfig.h"
#include "sysdeps.h"
#include <assert.h>

#include "config.h"
#include "uae.h"
#include "options.h"
#include "thread.h"
#include "debug_uae4all.h"
#include "gensound.h"
#include "events.h"
#include "memory.h"
#include "audio.h"
#include "sound.h"
#include "custom.h"
#include "m68k/m68k_intrf.h"
#include "disk.h"
#include "xwin.h"
#include "keybuf.h"
#include "gui.h"
#include "zfile.h"
#include "autoconf.h"
#include "drawing.h"

#ifdef USE_SDL
#include "SDL.h"
#endif
#ifdef IPHONE
#include "iphone_main.h"
#endif

uae g_emulator;

uae::uae() {
	quit_program = RunStateNotStarted;
	paused = false;
    running = false;
}

int cloanto_rom = 0;

struct gui_info gui_data;

//extern int timeslice_mode;

void uae::default_prefs () {
#ifdef NO_SOUND
    produce_sound = 0;
#else
    produce_sound = 2;
#endif

    // prefs_gfx_framerate = 2;
	prefs_gfx_framerate = -1; // auto frame skip

	//strcpy (prefs_df[0], get_df_path(0));
	//strcpy (prefs_df[1], get_df_path(1));
    //strcpy (prefs_df[0], ROM_PATH_PREFIX "df0.adf");
    //strcpy (prefs_df[1], ROM_PATH_PREFIX "df1.adf");

#if defined(DREAMCAST)
    strcpy (romfile, ROM_PATH_PREFIX "kick.rom");
#elif defined(IPHONE)
    
    
	strcpy(romfile, get_rom_path());
    strcpy(romkeyfile, get_key_path());
#else
    strcpy (romfile, "kick.rom");
#endif
    
    prefs_chipmem_size = get_chipmem_size();
    prefs_fastmem_size = get_fastmem_size();
    
    //prefs_chipmem_size=0x00200000;
	//prefs_chipmem_size=0x00080000;		// 512kb
	
	// emu bias -> system clock | sync threshold
	// X O O O O -> 100 | 50
	// O X O O O -> 83 | 100
	// O O X O O -> 83 | 50
	// O O O X O -> 75 | 50
	// O O O O X -> 75 | 25
	// o "System clock" (m68k_speed), which allows you to underclock the whole system to improve emulation performance, but breaks sound pitch. 
	// o "Sync threshold" (timeslice_mode), which allows to reduce amount of synchronization between 68k and other chips to also improve performance. 
	// Set both to 100 for best compatibility
	
	// 0 = 100%
	// 1 = 75%
	// 2 = 50%
	// 3 = 25%
	//timeslice_mode = 0;
	
	// 0 = 100%
	// 2 = 83%
	// 4 = 75%
	m68k_speed = 0;
}

void uae::uae_reset (void) {
    gui_purge_events();
    black_screen_now();
    quit_program = RunStateReset;
    set_special (SPCFLAG_BRK);
}

void uae_reset() {
	g_emulator.uae_reset();
}

void uae::uae_quit (void) {
    if (quit_program != RunStateSpecialQuit)
		quit_program = RunStateSpecialQuit;
}

void uae::uae_pause(void) {
	paused = true;
}

void uae::uae_resume(void) {
	paused = false;
}

void uae::reset_all_systems (void) {
    init_eventtab ();
    memory_reset ();
    filesys_reset();
    filesys_start_threads();
}

/* Okay, this stuff looks strange, but it is here to encourage people who
 * port UAE to re-use as much of this code as possible. Functions that you
 * should be using are do_start_program() and do_leave_program(), as well
 * as real_main(). Some OSes don't call main() (which is braindamaged IMHO,
 * but unfortunately very common), so you need to call real_main() from
 * whatever entry point you have. You may want to write your own versions
 * of start_program() and leave_program() if you need to do anything special.
 * Add #ifdefs around these as appropriate.
 */

void uae::do_start_program (void) {
	quit_program = RunStateReset;
	reset_frameskip();
	m68k_go (1);
}

void uae::do_leave_program (void) {
    graphics_leave ();
    close_sound ();
    dump_counts ();
    zfile_exit ();
#ifdef USE_SDL
    SDL_Quit ();
#endif
    memory_cleanup ();
}

void uae::start_program (void) {
    do_start_program ();
}

void uae::leave_program (void) {
    do_leave_program ();
}

void uae::real_main () {
#ifdef USE_SDL
	//    SDL_Init (SDL_INIT_EVERYTHING | SDL_INIT_NOPARACHUTE);
    SDL_Init (SDL_INIT_VIDEO | SDL_INIT_JOYSTICK 
#if !defined(NO_SOUND) && !defined(GP2X)
			  | SDL_INIT_AUDIO
#endif
			  );
#endif
	
    default_prefs ();
    
    if (! graphics_setup ()) {
		exit (1);
    }
	
    rtarea_init ();
    
    hardfile_install();
    
    if (! setup_sound ()) {
		write_log ("Sound driver unavailable: Sound output disabled\n");
		produce_sound = 0;
    }
	
	int err = gui_init ();
	if (err == -1) {
	    write_log ("Failed to initialize the GUI\n");
	} else if (err == -2) {
	    exit (0);
	}
    if (sound_available && produce_sound > 1 && !init_audio ()) {
		write_log ("Sound driver unavailable: Sound output disabled\n");
		produce_sound = 0;
    }
	
    /* Install resident module to get 8MB chipmem, if requested */
    rtarea_setup ();
	
    keybuf_init (); /* Must come after init_joystick */
    
#ifdef USE_AUTOCONFIG
    expansion_init ();
#endif
	
    memory_init ();
    
    filesys_install();
	
    custom_init (); /* Must come after memory_init */
    DISK_init ();
	
    m68k_init(0);
    gui_update ();
	
    if (graphics_init ()) {
		start_program ();
	}
    leave_program ();
}

void uae::set_joystickactive(void)
{
    //set_joystickactive();
}
