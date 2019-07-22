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

#import "CoreSetting.h"
#import "CoreSettingGroup.h"
#import "DiskDriveService.h"
#import "HardDriveService.h"
#import "MultiDictionary.h"
#import "Settings.h"
#import "constSettings.h"
#import "EMUFileInfo.h"
#import "EMUBrowser.h"

extern unsigned prefs_chipmem_size;
extern unsigned prefs_fastmem_size;

static RomCoreSetting *_romInstance;
static HD0PathCoreSetting *_hdpathInstance;
static CMemCoreSetting *_cmeminstance;
static FMemCoreSetting *_fmeminstance;

@interface CoreSettingsRegistry : NSObject

+ (CoreSettingsRegistry *)sharedRegistry;

// CoreSetting instance -> the current value associated with that setting instance
@property (nonatomic, readonly) NSMutableDictionary *settingToCurrentValue;

// CoreSetting instance -> the CoreSettingGroup instance that setting is associated with
// only has an entry if the CoreSetting conforms to the CoreSettingGroupMember protocol
@property (nonatomic, readonly) NSMutableDictionary *settingToGroup;

// The class name of a CoreSettingGroup -> the single instance of that CoreSettingGroup
@property (nonnull, readonly) NSMutableDictionary *groupClassNameToGroup;

// The CoreSettingGroup instance -> all CoreSetting instances that are part of it
@property (nonnull, readonly) MultiDictionary *groupToSettings;

@end

/**
 * Method names starting with "hook_" are meant to be implemented by subclasses.
 */
@implementation CoreSetting {
    @protected
    CoreSettingsRegistry *_registry;
    NSString *_settingName;
    
    @protected
    Settings *_settings;
}

/**
 * Persists the given setting value.  Subclasses must implement.
 */
- (void)hook_persistValue:(id)value {
    [NSException raise:@"Subclasses must implement" format:@"%@", NSStringFromSelector(_cmd)];
}

/**
 * Returns the current value of this setting as far as the emulator is concerned.  Subclasses must implement.
 */
- (id)hook_getEmulatorValue {
    [NSException raise:@"Subclasses must implement" format:@"%@", NSStringFromSelector(_cmd)];
    return nil;
}

/**
 * The NSString returned here is prepended to the message that describes the configuration change made by
 * changing this CoreSetting's value.  
 *
 * For example: 
 *    [Changing the ROM] requires resetting the emulator to take effect.
 *
 * or:
 *    [Disabling a drive] requires resetting the emulator to take effect.
 *
 * Subclasses must implement.
 */
- (NSString *)hook_getActionDescription {
    [NSException raise:@"Subclasses must implement" format:@"%@", NSStringFromSelector(_cmd)];
    return nil;
}

/**
 * Callback where subclasses can run custom logic when the emulator is reset.  Subclasses may implement.
 *
 * This method is only called if hasUnappliedValue returns YES for this setting instance.
 */
- (void)hook_onReset:(id)value {
    
}

- (instancetype)initWithName:(NSString *)settingName {
    if (self = [super init]) {
        _registry = [CoreSettingsRegistry sharedRegistry];
        _settings = [[Settings alloc] init];
        _settingName = [settingName retain];
        
        if ([[self class] conformsToProtocol:@protocol(CoreSettingGroupMember)]) {
            [self initializeGroup];
        }
    }
    return self;
}

- (void)initializeGroup {
    Class groupClass = [((id<CoreSettingGroupMember>)self) getGroup];
    NSString *groupClassName = NSStringFromClass(groupClass);
    id<CoreSettingGroup> group = [_registry.groupClassNameToGroup objectForKey:groupClassName];
    if (!group) {
        group = [[[groupClass alloc] init] autorelease];
        [_registry.groupClassNameToGroup setObject:group forKey:groupClassName];
    }
    [_registry.settingToGroup setObject:group forKey:self];
    [_registry.groupToSettings setObject:self forKey:group];
}

- (void)setValue:(id)value {
    id currentValue = [self hook_getEmulatorValue];
    id unappliedValue = [self getUnappliedValue];
    BOOL valueIsDifferentFromPreviousValue = NO;
    if ([self eq:currentValue to:value]) {
        [_registry.settingToCurrentValue removeObjectForKey:self];
        valueIsDifferentFromPreviousValue = unappliedValue != nil;
    } else {
        valueIsDifferentFromPreviousValue = YES;
        [_registry.settingToCurrentValue setObject:value ? value : [NSNull null] forKey:self];
    }
    
    if (valueIsDifferentFromPreviousValue) {
        [self hook_persistValue:value];
    }
}

- (id)getValue {
    id value = [self getUnappliedValue];
    if (value) {
        return value == [NSNull null] ? nil : value;
    }
    return [self hook_getEmulatorValue];
}

- (BOOL)hasUnappliedValue {
    return [self getUnappliedValue] != nil;
}

- (NSString *)getModificationDescription {
    return [NSString stringWithFormat:@"%@ requires resetting the emulator to take effect", [self hook_getActionDescription]];
}

- (id)copyWithZone:(nullable NSZone *)zone {
    return [self retain];
}

- (NSString *)description {
    return _settingName;
}

- (BOOL)eq:(id)thing1 to:(id)thing2 {
    if (thing1 == thing2) return YES;
    if (!thing1 && thing2 == [NSNull null]) return YES;
    if (thing1 == [NSNull null] && !thing2) return YES;
    return [thing1 isEqual:thing2];
}

- (NSString *)getUnappliedValue {
    [NSException raise:@"Subclasses must implement" format:@"%@", NSStringFromSelector(_cmd)];
    return nil;
}

- (void)dealloc {
    [_settingName release];
    [_settings release];
    [super dealloc];
}

@end

@implementation DriveServiceBasedCoreSetting {
    @protected
    DiskDriveService *_diskDriveService;
}

- (instancetype)initWithName:(NSString *)settingName {
    if ([super initWithName:settingName]) {
        _diskDriveService = [[DiskDriveService alloc] init];
    }
    return self;
}

- (void)dealloc {
    [_diskDriveService release];
    [super dealloc];
}

@end

@implementation RomCoreSetting

+ (RomCoreSetting *)getInstance {
    return _romInstance;
}

- (instancetype)initWithName:(NSString *)settingName {
    self = [super initWithName:settingName];
    
    [self initromPath];
    _romInstance = self;
    return self;
}

- (void)initromPath {
    Settings *settings = [[[Settings alloc] init] autorelease];
    EMUBrowser *browser = [[[EMUBrowser alloc] init] autorelease];
    NSString *romPath = settings.romPath;
    if (romPath) {
        if (![[NSFileManager defaultManager] fileExistsAtPath:romPath]) {
            EMUFileInfo *fileInfo = [browser getFileInfoForFileName:[romPath lastPathComponent]];
            romPath = fileInfo ? fileInfo.path : nil;
        }
    }
    if (!romPath) {
        NSArray *romNameFilters = @[@"kick.rom", @"kick13.rom"];
        for (NSString *romNameFilter in romNameFilters) {
            EMUFileInfo *fileInfo = [browser getFileInfoForFileName:romNameFilter];
            if (fileInfo) {
                romPath = fileInfo.path;
                break;
            }
        }
    }
    
    settings.romPath = romPath;
}

- (NSString *)hook_getActionDescription {
    return @"Change";
}

- (void)hook_persistValue:(NSString *)romPath {
    _settings.romPath = romPath;
}

- (void)hook_onReset:(NSString *)romPath {
    [_diskDriveService configureRom:romPath];
}

- (NSString *)hook_getEmulatorValue {
    if ([_diskDriveService getRomPath]) {
        NSString *romPath = [[NSString alloc] initWithString:[_diskDriveService getRomPath]];
        return romPath;
    }
    else {
        return nil;
    }
}

- (NSString *)getUnappliedValue {
    if(!_settings.romPath) [self initromPath];
    NSString *curRompath = _settings.romPath;
    NSString *actRompath = [self hook_getEmulatorValue];
    NSString *curRomfile = [[curRompath lastPathComponent] stringByDeletingPathExtension];
    NSString *actRomfile = [[actRompath lastPathComponent] stringByDeletingPathExtension];
    if ([curRomfile isEqualToString:actRomfile] || !(curRomfile)) {
        return nil;
    } else {
        [self initromPath];
        NSString *fixedPath = [[NSString alloc] initWithString:_settings.romPath];
        return fixedPath;
    }
}

@end

@implementation CMemCoreSetting {
    NSInteger _actcmem;
}

+ (CMemCoreSetting *)getInstance {
    return _cmeminstance;
}

- (instancetype)initWithName:(NSString *)settingName {
    self = [super initWithName:settingName];
    
    _cmeminstance = self;
    _actcmem = _settings.CMem;
    
    return self;
}

- (NSString *)hook_getActionDescription {
    return @"Change";
}

- (void)hook_persistValue:(NSNumber *)cmem {
    //Round to multiple of 512
    
    _settings.CMem = [cmem integerValue];
}

- (void)hook_onReset:(NSNumber *)cmem {
    prefs_chipmem_size = (unsigned int)(_settings.CMem * 1024);
    _actcmem = _settings.CMem;
}

- (NSNumber *)hook_getEmulatorValue {
    return [NSNumber numberWithInteger:_actcmem];
}

- (NSString *)getUnappliedValue {

    NSInteger curcmem = _settings.CMem;
    NSInteger actcmem = [[self hook_getEmulatorValue] integerValue];
    
    if (curcmem == actcmem) {
        return nil;
    }
    else {
        return [NSString stringWithFormat:@"%li", (long)curcmem];
    }
    
}

@end

@implementation FMemCoreSetting {
    NSInteger _actfmem;
}

+ (FMemCoreSetting *)getInstance {
    return _fmeminstance;
}

- (instancetype)initWithName:(NSString *)settingName {
    
    self = [super initWithName:settingName];
    _actfmem = _settings.FMem;
    
    _fmeminstance = self;
    
    return self;
}

- (NSString *)hook_getActionDescription {
    return @"Change";
}

- (void)hook_persistValue:(NSNumber *)fmem {
    _settings.FMem = [fmem integerValue];
}

- (void)hook_onReset:(NSNumber *)cmem {
    prefs_fastmem_size = (unsigned int)_settings.FMem * 1024 * 1024;
    _actfmem = _settings.FMem;
}

- (NSNumber *)hook_getEmulatorValue {
    return [NSNumber numberWithInteger:_actfmem];
}

- (NSString *)getUnappliedValue {
    
    NSInteger curfmem = _settings.FMem;
    NSInteger actfmem = [[self hook_getEmulatorValue] integerValue];
    
    if (curfmem == actfmem) {
        return nil;
    } else {
        NSString *scurfmem = [NSString stringWithFormat:@"%li", (long)curfmem];
        return scurfmem;
    }    
}

@end

@implementation DiskDriveEnabledCoreSetting

- (NSString *)hook_getActionDescription {
    BOOL enabled = [[self getValue] boolValue];
    return enabled ? @"Enabling" : @"Disabling";
}

- (void)hook_persistValue:(NSNumber *)enabled {
    DriveState *driveState = _settings.driveState;
    [self hook_setEnabled:[enabled boolValue] onDriveState:driveState];
    _settings.driveState = driveState;
}

- (NSNumber *)hook_getEmulatorValue {
    DriveState *driveState = [_diskDriveService getDriveState];
    return [NSNumber numberWithBool:[self hook_getEnabledFromDriveState:driveState]];
}

- (BOOL)hook_getEnabledFromDriveState:(DriveState *)driveState {
    [NSException raise:@"Subclasses must implement" format:@"%@", NSStringFromSelector(_cmd)];
    return NO;
}

- (void)hook_setEnabled:(BOOL)enabled onDriveState:(DriveState *)driveState {
    [NSException raise:@"Subclasses must implement" format:@"%@", NSStringFromSelector(_cmd)];
}

- (NSString *)getUnappliedValue {
    return [_registry.settingToCurrentValue objectForKey:self];
}

@end

@implementation DF1EnabledCoreSetting

- (BOOL)hook_getEnabledFromDriveState:(DriveState *)driveState {
    return driveState.df1Enabled;
}

- (void)hook_setEnabled:(BOOL)enabled onDriveState:(DriveState *)driveState {
    [driveState setDf1Enabled:enabled];
}

- (NSString *)getUnappliedValue {
    return [_registry.settingToCurrentValue objectForKey:self];
}

@end

@implementation DF2EnabledCoreSetting

- (BOOL)hook_getEnabledFromDriveState:(DriveState *)driveState {
    return driveState.df2Enabled;
}

- (void)hook_setEnabled:(BOOL)enabled onDriveState:(DriveState *)driveState {
    [driveState setDf2Enabled:enabled];
}

- (NSString *)getUnappliedValue {
    return [_registry.settingToCurrentValue objectForKey:self];
}

@end

@implementation DF3EnabledCoreSetting

- (BOOL)hook_getEnabledFromDriveState:(DriveState *)driveState {
    return driveState.df3Enabled;
}

- (void)hook_setEnabled:(BOOL)enabled onDriveState:(DriveState *)driveState {
    [driveState setDf3Enabled:enabled];
}

- (NSString *)getUnappliedValue {
    return [_registry.settingToCurrentValue objectForKey:self];
}

@end

@implementation HardDriveBasedCoreSetting {
    @protected
    HardDriveService *_hardDriveService;
}

- (instancetype)initWithName:(NSString *)settingName {
    if ([super initWithName:settingName]) {
        _hardDriveService = [[HardDriveService alloc] init];
    }
    return self;
}

- (void)dealloc {
    [_hardDriveService release];
    [super dealloc];
}

@end

@implementation HD0PathCoreSetting

+ (HD0PathCoreSetting *)getInstance {
    return _hdpathInstance;
}

- (instancetype)initWithName:(NSString *)settingName {
    self = [super initWithName:settingName];
    
    [self initHD0Path];
    _hdpathInstance = self;
    return self;
}

- (void)initHD0Path {
    Settings *settings = [[[Settings alloc] init] autorelease];
    EMUBrowser *browser = [[[EMUBrowser alloc] init] autorelease];
    NSString *hdPath = settings.hardfilePath;
    if (hdPath) {
        if (![[NSFileManager defaultManager] fileExistsAtPath:hdPath]) {
            EMUFileInfo *fileInfo = [browser getFileInfoForFileName:[hdPath lastPathComponent]];
            hdPath = fileInfo ? fileInfo.path : nil;
        }
    }
    
    settings.hardfilePath = hdPath;
    [_hardDriveService unmountHardfile];
}

- (void)hook_persistValue:(NSString *)hd0Path {
    _settings.hardfilePath = hd0Path;
}

- (NSString *)hook_getEmulatorValue {
    return [_hardDriveService getMountedHardfilePath];
}

- (NSString *)hook_getActionDescription {
    NSString *hdfpath = [self getValue];
    return hdfpath ? @"Mounting" : @"Unmounting";
}

- (NSString *)getUnappliedValue {
    
    NSString *curHD0Path = _settings.hardfilePath;
    NSString *actHD0path = [self hook_getEmulatorValue];
    
    if([curHD0Path isEqualToString:actHD0path]) {
        return nil;
    }
    else {
        [self initHD0Path];
        curHD0Path = _settings.hardfilePath;
        return curHD0Path;
    }
    
}

- (Class)getGroup {
    return HD0SettingGroup.self;
}

@end

@implementation HD0ReadOnlyCoreSetting

- (void)hook_persistValue:(NSNumber *)hd0ReadOnly {
    _settings.hardfileReadOnly = [hd0ReadOnly boolValue];
}

- (NSNumber *)hook_getEmulatorValue {
    BOOL readOnly = [_hardDriveService readOnly];
    return [NSNumber numberWithBool:readOnly];
}

- (NSString *)hook_getActionDescription {
    BOOL readOnly = [[self getValue] boolValue];
    return [NSString stringWithFormat:@"Mounting as %@", readOnly ? @"read-only" : @"read-write"];
}

- (NSString *)getUnappliedValue {
    
    //No HD File Selected means this setting is irrelevant
    if(![_hdpathInstance getValue])
    {
        return nil;
    }
    
    BOOL bcurValue = _settings.hardfileReadOnly;
    NSNumber *nactValue = [self hook_getEmulatorValue];
    BOOL bactValue = [nactValue boolValue];
    
    if(bcurValue == bactValue) {
        return nil;
    }
    else {
        NSString *scurValue = [NSString stringWithFormat:@"%i", bcurValue];
        return scurValue;
    }
    
    return [_registry.settingToCurrentValue objectForKey:self];
}

- (Class)getGroup {
    return HD0SettingGroup.self;
}

@end

@implementation HD0SettingGroup {
    @private
    HardDriveService *_hardDriveService;
}

- (instancetype)init {
    if (self = [super init]) {
        _hardDriveService = [[HardDriveService alloc] init];
    }
    return self;
}

- (void)dealloc {
    [_hardDriveService release];
    [super dealloc];
}

- (void)onResetAfterMembers:(NSSet *)groupMembers {
    NSString *hd0Path = [[HD0PathCoreSetting getInstance] getValue];
    if ([_hardDriveService mounted]) {
        [_hardDriveService unmountHardfile];
    }
    if (hd0Path) {
        BOOL readOnly = [[[CoreSettings hd0ReadOnlyCoreSetting] getValue] boolValue];
        [_hardDriveService mountHardfile:hd0Path asReadOnly:readOnly];
    }
}

- (id)copyWithZone:(nullable NSZone *)zone {
    return self;
}

@end

extern int mainMenu_ntsc;

@implementation NTSCEnabledCoreSetting

- (NSString *)hook_getActionDescription {
    BOOL enabled = [[self getValue] boolValue];
    return [NSString stringWithFormat:@"%@ NTSC", enabled ? @"Enabling" : @"Disabling"];
}

- (void)hook_persistValue:(NSNumber *)enabled {
    _settings.ntsc = [enabled boolValue];
}

- (void)hook_onReset:(NSNumber *)enabled {
    mainMenu_ntsc = [enabled intValue];
}

- (NSNumber *)hook_getEmulatorValue {
    return [NSNumber numberWithInt:mainMenu_ntsc];
}

- (NSString *)getUnappliedValue {
    
    BOOL bcurNtsc = _settings.ntsc;
    NSNumber *ncurNtsc = [self hook_getEmulatorValue];
    BOOL bactNtsc = [ncurNtsc boolValue];
    
    if(bcurNtsc == bactNtsc) {
        return nil;
    }
    else {
        NSString *scurNTSC = [NSString stringWithFormat:@"%i", bcurNtsc];
        return scurNTSC;
    }
   
}

@end

@implementation CoreSettingsRegistry

+ (CoreSettingsRegistry *)sharedRegistry {
    static CoreSettingsRegistry *registry = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        registry = [[CoreSettingsRegistry alloc] init];
    });
    return registry;
}

- (instancetype)init {
    if (self = [super init]) {
        _settingToCurrentValue = [[NSMutableDictionary alloc] init];
        _settingToGroup = [[NSMutableDictionary alloc] init];
        _groupClassNameToGroup = [[NSMutableDictionary alloc] init];
        _groupToSettings = [[MultiDictionary alloc] init];
    }
    return self;
}

@end

@implementation CoreSettings

+ (void)onReset {
    CoreSettingsRegistry *reg = [CoreSettingsRegistry sharedRegistry];
    NSMutableDictionary *sToV = reg.settingToCurrentValue;
    NSMutableSet *settingsBeingReset = [NSMutableSet setWithCapacity:[sToV count]];
    for (CoreSetting *setting in sToV.keyEnumerator) {
        id unappliedValue = [sToV objectForKey:setting];
        if (unappliedValue) {
            [setting hook_onReset:unappliedValue == [NSNull null] ? nil : unappliedValue];
        }
        [settingsBeingReset addObject:setting];
    }
    
    NSMutableSet *handledGroups = [[[NSMutableSet alloc] init] autorelease];    
    for (CoreSetting *setting in sToV.keyEnumerator) {
        id<CoreSettingGroup> group = [reg.settingToGroup objectForKey:setting];
        if (group && ![handledGroups containsObject:group]) {
            [handledGroups addObject:group];
            NSMutableSet *groupedSettings = [NSMutableSet setWithSet:[reg.groupToSettings objectsForKey:group]];
            [groupedSettings intersectSet:settingsBeingReset];
            [group onResetAfterMembers:groupedSettings];
        }
    }

    [sToV removeAllObjects];
}

+ (DF1EnabledCoreSetting *)df1EnabledCoreSetting {
    static DF1EnabledCoreSetting *setting = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        setting = [[DF1EnabledCoreSetting alloc] initWithName:@"DF1Enabled"];
    });
    return setting;
}

+ (DF2EnabledCoreSetting *)df2EnabledCoreSetting {
    static DF2EnabledCoreSetting *setting = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        setting = [[DF2EnabledCoreSetting alloc] initWithName:@"DF2Enabled"];
    });
    return setting;
}

+ (DF3EnabledCoreSetting *)df3EnabledCoreSetting {
    static DF3EnabledCoreSetting *setting = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        setting = [[DF3EnabledCoreSetting alloc] initWithName:@"DF3Enabled"];
    });
    return setting;
}

+ (HD0ReadOnlyCoreSetting *)hd0ReadOnlyCoreSetting {
    static HD0ReadOnlyCoreSetting *setting = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        setting = [[HD0ReadOnlyCoreSetting alloc] initWithName:@"HD0ReadOnlyWrite"];
    });
    return setting;
}

+ (NTSCEnabledCoreSetting *)ntscEnabledCoreSetting {
    static NTSCEnabledCoreSetting *setting = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        setting = [[NTSCEnabledCoreSetting alloc] initWithName:@"NTSCEnabled"];
    });
    return setting;
}

@end
