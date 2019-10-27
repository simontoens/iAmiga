//  Created by Simon Toens on 19.06.15
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
//  You should have received a copy of the GNU General Public License
//  along with this program; if not, write to the Free Software
//  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

#import "uae.h"
#import "sysconfig.h"
#import "sysdeps.h"
#import "options.h"
#import "memory.h"
#import "zfile.h"
#import "DiskDriveService.h"

@implementation DiskDriveService

- (NSString *)getInsertedDiskForDrive:(int)driveNumber {
    if (driveNumber < NUM_DRIVES)
    {
        
        NSString *adfPath = [NSString stringWithCString:changed_df[driveNumber] encoding:[NSString defaultCStringEncoding]];
        return [adfPath length] == 0 ? nil : adfPath;
    }
    return nil;
}

- (void)insertDisk:(NSString *)adfPath intoDrive:(NSUInteger)driveNumber {
    if (driveNumber < NUM_DRIVES)
    {
        [adfPath getCString:changed_df[driveNumber] maxLength:256 encoding:[NSString defaultCStringEncoding]];
        real_changed_df[driveNumber] = 1;
    }
}

- (void)insertDisks:(NSArray *)adfPaths {
    for (int driveNumber = 0; driveNumber < [adfPaths count]; driveNumber++)
    {
        if (driveNumber < NUM_DRIVES)
        {
            NSString *adfPath = [adfPaths objectAtIndex:driveNumber];
            if ([adfPath length] == 0) {
                continue; // placeholder item
            }
            if ([[NSFileManager defaultManager] fileExistsAtPath:adfPath isDirectory:NULL]) {
                [self insertDisk:adfPath intoDrive:driveNumber];
            } else {
                // it is possible that the stored adf path is no longer valid - this often happens
                // during debugging.  If that's the case, don't even attempt to insert the floppy
                NSLog(@"adf does not exist: %@", adfPath);
            }
        }
        else
        {
            break;
        }
    }
}

- (void)ejectDiskFromDrive:(NSUInteger)driveNumber {
    if (driveNumber < NUM_DRIVES)
    {
        changed_df[driveNumber][0] = 0;
        real_changed_df[driveNumber] = 1;
    }
}

- (BOOL)diskInsertedIntoDrive:(NSUInteger)driveNumber {
    if (driveNumber < NUM_DRIVES)
    {
        return changed_df[driveNumber][0] != 0;
    }
    return NO;
}

- (BOOL)enabled:(NSUInteger)driveNumber {
    if (driveNumber < NUM_DRIVES)
    {
        return (disabled & (1 << driveNumber)) == 0;
    }
    return NO;
}

- (void)enableDrive:(NSUInteger)driveNumber enable:(BOOL)enable {
    if (driveNumber < NUM_DRIVES) {
        if (enable && ![self enabled:driveNumber])
        {
            disabled -= (1 << driveNumber);
        } else if (!enable && [self enabled:driveNumber])
        {
            disabled += (1 << driveNumber);
        }
    }
}

- (DriveState *)getDriveState {
    DriveState *driveState = [[[DriveState alloc] init] autorelease];
    driveState.df1Enabled = [self enabled:1];
    driveState.df2Enabled = [self enabled:2];
    driveState.df3Enabled = [self enabled:3];
    return driveState;
}

- (void)setDriveState:(DriveState *)driveState {
    if (NUM_DRIVES > 1) {
        [self enableDrive:1 enable:driveState.df1Enabled];
    }
    if (NUM_DRIVES > 2) {
        [self enableDrive:2 enable:driveState.df2Enabled];
    }
    if (NUM_DRIVES > 3) {
        [self enableDrive:3 enable:driveState.df3Enabled];
    }
}

- (NSString *)getRomPath {
    NSString *romPath = [NSString stringWithCString:romfile encoding:[NSString defaultCStringEncoding]];
    return [romPath length] == 0 ? nil : romPath;
}

- (void)configureRom:(NSString *)romPath {
    [romPath getCString:romfile maxLength:sizeof(romfile) encoding:[NSString defaultCStringEncoding]];
    bReloadKickstart = 1;
    uae4all_rom_reinit();
}

@end
