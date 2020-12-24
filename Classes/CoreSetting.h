//  Created by Simon Toens on 11.05.16
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
#import "CoreSettingGroup.h"

//Wrapper Methods for C++ calls
/**
 * A special setting (property/switch/toggle) that requires an emulator reset to take effect.  For example, the rom being used.
 *
 * This is an abstract class.
 */
@interface CoreSetting : NSObject <NSCopying>

/**
 * Setting instances are singletons - access them using the CoreSettings class methods.
 */
- (instancetype)initWithName:(NSString *)settingName;

/**
 * Updates this setting to the specified value.
 */
- (void)setValue:(id)value;
/**
 * Returns the current value of this setting:
 *   - if an unapplied value exists, returns that
 *   - otherwise returns the 'applied' current value
 */
- (id)getValue;

/**
 * Returns YES if the setting has a new value, but a reset has not happened yet (ie the value has not taken effect).
 */
- (BOOL)hasUnappliedValue;

/**
 * Returns the message to show when this setting has been modified.
 */
- (NSString *)getModificationDescription;

@end

@interface DriveServiceBasedCoreSetting : CoreSetting @end // abstract
@interface DiskDriveEnabledCoreSetting : DriveServiceBasedCoreSetting @end // abstract

@interface RomCoreSetting : DriveServiceBasedCoreSetting
+ (RomCoreSetting *)getInstance;
@end

@interface DF1EnabledCoreSetting : DiskDriveEnabledCoreSetting @end
@interface DF2EnabledCoreSetting : DiskDriveEnabledCoreSetting @end
@interface DF3EnabledCoreSetting : DiskDriveEnabledCoreSetting @end
@interface HardDriveBasedCoreSetting : CoreSetting @end // abstract
@interface HD0PathCoreSetting : HardDriveBasedCoreSetting <CoreSettingGroupMember>
+ (HD0PathCoreSetting *)getInstance;
@end
@interface HD0ReadOnlyCoreSetting : HardDriveBasedCoreSetting <CoreSettingGroupMember> @end
@interface HD0SettingGroup : NSObject <CoreSettingGroup> @end
@interface NTSCEnabledCoreSetting : CoreSetting @end
@interface CMemCoreSetting : CoreSetting
+ (CMemCoreSetting *) getInstance;
@end
@interface FMemCoreSetting : CoreSetting
+ (FMemCoreSetting *) getInstance;
@end

/**
 * Exposes all CoreSetting singletons, and is the entry point for the reset flow.
 */
@interface CoreSettings : NSObject

/**
 * Notifies that the emulator has been reset.
 */
+ (void)onReset;

/**
 * Available CoreSetting instances:
 */
+ (DF1EnabledCoreSetting *)df1EnabledCoreSetting;
+ (DF2EnabledCoreSetting *)df2EnabledCoreSetting;
+ (DF3EnabledCoreSetting *)df3EnabledCoreSetting;
+ (HD0ReadOnlyCoreSetting *)hd0ReadOnlyCoreSetting;
+ (NTSCEnabledCoreSetting *)ntscEnabledCoreSetting;

@end


