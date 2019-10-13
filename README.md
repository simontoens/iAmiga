## Project setup

This project uses git submodules.  Before building for the first time, and if building fails because of missing files, you must run:

```
git submodule init
git submodule update
```

## ROMs
Use iTunes to copy rom file(s) to your device, or add the roms to the Xcode project when building iUAE.  When the emulator starts up for the first time, it will look for a rom called "kick.rom" or "kick13.rom".  If your rom file has a differnet name or if you want to switch roms, you can use the rom selector in settings.

You can use Cloanto Amiga Forever Roms. For them to work you need to copy Cloanto Amiga Forever file (rom.key) using iTunes or iFile. This file is required to decrypt the roms.

## Disk drives

df[0]-3 are supported.  Drives read .adf files - the easiest way to get them onto your device is to use iTunes to copy them.  Alternatively you can also add adf files to the Xcode project when building iUAE, however they will be read-only.  Swipe on a drive row to eject an inserted adf.

## Hard drives

Hard drive support is currently limited:  only a single hard drive file (.hdf) can be mounted.  Swipe on the HD0 row to unmount.
To create a hard drive file, you can use xdftool from the excellent [amitools](https://github.com/cnvogelg/amitools), for example:

```
xdftool new.hdf create size=10Mi
```

Use iTunes to copy the .hdf file to your device.  Alternatively you can also add the hdf file to the Xcode project when building iUAE, however it will be read-only.
Note that you need to have kickstart 1.3 or higher for hard drives to work correctly.

## Emulator States

Emulator states are the preferred way persisting state and configuration. Swipe on a state to delete it.

## CPU load optimization

To optimize emulation performance and to reduce CPU load make sure that the build you install on your device was compiled with *-O3* or *-Os* setting.  
You find this in the project's Xcode build settings, specifically in the *Apple LLVM - Code Generation*->*Optimization Level* section.

See this link for more information: [Issue39](https://github.com/emufreak/iAmiga/issues/39)
