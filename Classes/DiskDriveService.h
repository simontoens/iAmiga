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

#import <Foundation/Foundation.h>
#import "DriveState.h"

/**
 * The disk drive service handles interactions with the disk drives.  Also has some rom related logic.
 *
 * Note that this class uses the emulator state as source of truth, it does not/should not read configuration.
 */
@interface DiskDriveService : NSObject

/**
 * Returns the adf path for the specified drive (df[0], df[1] ...), nil if no disk is inserted in the specified drive.
 */
- (NSString *)getInsertedDiskForDrive:(int)driveNumber;

/**
 * Inserts the specified adf into the specified drive (df[0], df[1] ...).
 */
- (void)insertDisk:(NSString *)adfPath intoDrive:(NSUInteger)driveNumber;

/**
 * Inserts the specified adfs into the drives corresponding to the adfs' positions in the array: adf at position 0 -> df0, adf at position 1 -> df1 ...
 */
- (void)insertDisks:(NSArray *)adfPaths;

/**
 * Ejects the disk from the specified drive number.
 */
- (void)ejectDiskFromDrive:(NSUInteger)driveNumber;

/**
 * Returns YES if a disk is currently inserted into the specified drive, NO otherwise.
 */
- (BOOL)diskInsertedIntoDrive:(NSUInteger)driveNumber;

/**
 * Returns YES if the specified is enabled, NO otherwise.
 */
- (BOOL)enabled:(NSUInteger)driveNumber;

/**
 * Enables/disables the specified drive.
 */
- (void)enableDrive:(NSUInteger)driveNumber enable:(BOOL)enable;

/**
 * Returns a DriveState instance that has enabled/disabled information for all drives.
 */
- (DriveState *)getDriveState;

/**
 * Enables/disables drives as specified in the given driveState instance.
 */
- (void)setDriveState:(DriveState *)driveState;

/**
 * Returns the path of the rom file the emulator is currently using.
 */
- (NSString *)getRomPath;

/**
 * Configures the emulator to use the speficied rom.
 */
- (void)configureRom:(NSString *)romPath;

@end
