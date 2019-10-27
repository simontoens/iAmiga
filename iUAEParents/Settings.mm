//
//  Settings.m
//  iUAE
//
//  Created by Emufr3ak on 08.03.15.
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

#import "sysconfig.h"
#import "sysdeps.h"
#import "JoypadKey.h"

#import "Settings.h"
#import "KeyButtonConfiguration.h"
#import "constSettings.h"

extern int mainMenu_showStatus;
extern int mainMenu_stretchscreen;
extern int joystickselected;

static NSString *_configurationname;
static int _cNumber = 1;

static volatile NSMutableDictionary<NSString *, id<SettingHandler>> *settingNameToHandler;

@implementation Settings {
    NSUserDefaults *defaults;
}

+ (void) initialize {
    if (self == [Settings class]) {
        settingNameToHandler = [[NSMutableDictionary alloc] init];
    }
}

+ (void)registerSettingHandler:(id<SettingHandler>)settingHandler forSettingName:(NSString *)settingName {
    [settingNameToHandler setObject:settingHandler forKey:settingName];
}

+ (void)unregisterSettingHandlerForSettingName:(NSString *)settingName {
    [settingNameToHandler removeObjectForKey:settingName];
}

- (id)init {
    if (self = [super init]) {
        defaults = [[NSUserDefaults standardUserDefaults] retain];
        [self initializeCommonSettings];
        [self initializespecificsettings];
    }
    return self;
}

- (void)initializeCommonSettings {
    
    _configurationname = [[defaults stringForKey:kConfigurationNameKey] retain];
    
    BOOL isFirstInitialization = ![defaults boolForKey:kAppSettingsInitializedKey];
    
    if(isFirstInitialization)
    {
        [defaults setBool:TRUE forKey:kAppSettingsInitializedKey];
        self.autoloadConfig = TRUE;
        self.driveState = [DriveState getAllEnabled];
        [defaults setObject:@"General" forKey:kConfigurationNameKey];
    }
}

- (void)setFloppyConfigurations:(NSArray *)adfPaths {
    for (NSString *adfPath : adfPaths)
    {
        [self setFloppyConfiguration:adfPath];
    }
}

- (void)setFloppyConfiguration:(NSString *)adfPath {
    NSString *settingstring = [NSString stringWithFormat:@"cnf%@", [adfPath lastPathComponent]];
    if ([defaults stringForKey:settingstring] && self.autoloadConfig )
    {
        [_configurationname release];
        _configurationname = [[defaults stringForKey:settingstring] retain];
        [defaults setObject:_configurationname forKey:kConfigurationNameKey];
    }
}

- (void)initializespecificsettings {
    if(![self boolForKey:kInitializeKey])
    {
        self.showStatus = mainMenu_showStatus;
        [self setBool:TRUE forKey:kInitializeKey];
    }
    else
    {
        mainMenu_stretchscreen = self.stretchScreen;
        mainMenu_showStatus = self.showStatus;
    }
    
    //Set Default values for settings if key does not exist
    
    self.showStatusBar =            [self keyExists:kShowStatusBarKey]          ? self.showStatusBar        :   YES;
    self.selectedEffectIndex =      [self keyExists:kSelectedEffectIndexKey]    ? self.selectedEffectIndex  :   0;
    self.joypadstyle =              [self keyExists:kJoypadStyleKey]            ? self.joypadstyle          :   @"FourButton";
    self.joypadleftorright =        [self keyExists:kJoypadLeftOrRightKey]      ? self.joypadleftorright    :   @"Right";
    self.joypadshowbuttontouch =    [self keyExists:kJoypadShowButtonTouchKey]  ? self.joypadshowbuttontouch :  YES;
    self.dpadTouchOrMotion =        [self keyExists:kDPadTouchOrMotion]         ? self.dpadTouchOrMotion : @"Touch";
    self.gyroToggleUpDown =         [self keyExists:kGyroToggleUpDown]          ? self.gyroToggleUpDown : NO;
    self.gyroSensitivity =          [self keyExists:kGyroSensitivity]           ? self.gyroSensitivity : 0.1;
    self.controllersnextid =        [self keyExists:kControllersNextIDKey]      ? self.controllersnextid : 1;
    self.controllers =              [self keyExists:kControllersKey]            ? self.controllers : [NSArray arrayWithObjects:@1, nil];
    self.LStickAnalogIsMouse =      [self keyExists:kLstickmouseFlag]           ? self.LStickAnalogIsMouse : NO;
    self.RStickAnalogIsMouse =      [self keyExists:kRstickmouseFlag]           ? self.RStickAnalogIsMouse : NO;
    self.useL2forMouseButton =      [self keyExists:kL2mouseFlag]               ? self.useL2forMouseButton : NO;
    self.useR2forRightMouseButton = [self keyExists:kR2mouseFlag]               ? self.useR2forRightMouseButton : NO;
    self.CMem =                     [self keyExists:kCmem]                      ? self.CMem : 1024;
    self.FMem =                     [self keyExists:kFmem]                      ? self.FMem : 0;
    
    for(int i=1;i<=8;i++)
    {
        if(![self keyConfigurationforButton:BTN_A forController:i])
        {
            [self initializekeysforController:i];
        }
        
        if(![self keyConfigurationforButton:PORT forController:i])
        {
            [self setKeyconfiguration:@"1" forController:i Button:PORT];
        }
        
        if(![self keyConfigurationforButton:VSWITCH forController:i])
        {
            [self setKeyconfiguration:@"NO" forController:i Button:VSWITCH];
        }
    }
    _keyConfigurationCount = 8;
}

- (void)initializekeysforController:(int)cNumber {
    [self setKeyconfiguration:@"Joypad" forController:cNumber Button:BTN_A];
    [self setKeyconfiguration:@"Joypad" forController:cNumber Button:BTN_B];
    [self setKeyconfiguration:@"Joypad" forController:cNumber Button:BTN_X];
    [self setKeyconfiguration:@"Joypad" forController:cNumber Button:BTN_Y];
    [self setKeyconfiguration:@"Joypad" forController:cNumber Button:BTN_L1];
    [self setKeyconfiguration:@"Joypad" forController:cNumber Button:BTN_L2];
    [self setKeyconfiguration:@"Joypad" forController:cNumber Button:BTN_R1];
    [self setKeyconfiguration:@"Joypad" forController:cNumber Button:BTN_R2];
    [self setKeyconfiguration:@"Joypad" forController:cNumber Button:BTN_UP];
    [self setKeyconfiguration:@"Joypad" forController:cNumber Button:BTN_DOWN];
    [self setKeyconfiguration:@"Joypad" forController:cNumber Button:BTN_LEFT];
    [self setKeyconfiguration:@"Joypad" forController:cNumber Button:BTN_RIGHT];
    
    [self setKeyconfigurationname:@"Joypad" forController:cNumber Button:BTN_A];
    [self setKeyconfigurationname:@"Joypad" forController:cNumber Button:BTN_B];
    [self setKeyconfigurationname:@"Joypad" forController:cNumber Button:BTN_X];
    [self setKeyconfigurationname:@"Joypad" forController:cNumber Button:BTN_Y];
    [self setKeyconfigurationname:@"Joypad" forController:cNumber Button:BTN_L1];
    [self setKeyconfigurationname:@"Joypad" forController:cNumber Button:BTN_L2];
    [self setKeyconfigurationname:@"Joypad" forController:cNumber Button:BTN_R1];
    [self setKeyconfigurationname:@"Joypad" forController:cNumber Button:BTN_R2];
    [self setKeyconfigurationname:@"Joypad" forController:cNumber Button:BTN_UP];
    [self setKeyconfigurationname:@"Joypad" forController:cNumber Button:BTN_DOWN];
    [self setKeyconfigurationname:@"Joypad" forController:cNumber Button:BTN_LEFT];
    [self setKeyconfigurationname:@"Joypad" forController:cNumber Button:BTN_RIGHT];
}

- (BOOL)keyExists: (NSString *) key {
    return [[[defaults dictionaryRepresentation] allKeys] containsObject:[self getInternalSettingKey: key]];
}

- (BOOL)autoloadConfig {
    return [self boolForKey:kAutoloadConfigKey];
}

- (void)setAutoloadConfig:(BOOL)autoloadConfig {
    [self setBool:autoloadConfig forKey:kAutoloadConfigKey];
}

- (NSArray *)insertedFloppies {
    return [self arrayForKey:kInsertedFloppiesKey];
}

- (void)setInsertedFloppies:(NSArray *)insertedFloppies {
    [self setObject:insertedFloppies forKey:kInsertedFloppiesKey];
}

- (BOOL)ntsc {
    return [self boolForKey:kNtscKey];
}

- (void)setNtsc:(BOOL)ntsc {
    [self setBool:ntsc forKey:kNtscKey];
}

- (BOOL)stretchScreen {
    return [self boolForKey:kStretchScreenKey];
}

- (void)setStretchScreen:(BOOL)stretchScreen {
    [self setBool:stretchScreen forKey:kStretchScreenKey];
}

- (NSInteger)CMem {
    return [self integerForKey:kCmem];
}

- (void)setCMem:(NSInteger)cmem {
    [self setInteger:cmem forKey:kCmem];
}

- (NSInteger)FMem {
    return [self integerForKey:kFmem];
}

- (void)setFMem:(NSInteger)cmem {
    [self setInteger:cmem forKey:kFmem];
}

- (BOOL)showStatus {
    return [self boolForKey:kShowStatusKey];
}

- (void)setShowStatus:(BOOL)showStatus {
    [self setBool:showStatus forKey:kShowStatusKey];
}

- (void)setVolume:(float)volume {
    [self setObject:[NSNumber numberWithFloat:volume] forKey:kVolume];
}

- (float)volume {
    NSNumber *volume = [self objectForKey:kVolume];
    return volume ? [volume floatValue] : /* was never saved, default to max: */ 1;
}

- (NSString *)joypadstyle {
    return [self stringForKey:kJoypadStyleKey];
}

- (void)setJoypadstyle:(NSString *)joypadstyle {
    [self setObject:joypadstyle forKey:kJoypadStyleKey];
}

- (NSString *)joypadleftorright {
    return [self stringForKey:kJoypadLeftOrRightKey];
}

- (void)setJoypadleftorright:(NSString *)joypadleftorright {
    [self setObject:joypadleftorright forKey:kJoypadLeftOrRightKey];
}

- (BOOL)joypadshowbuttontouch {
    return [self boolForKey:kJoypadShowButtonTouchKey];
}

- (void)setJoypadshowbuttontouch:(BOOL)joypadshowbuttontouch {
    [self setBool:joypadshowbuttontouch forKey:kJoypadShowButtonTouchKey];
}

- (NSString *)dpadTouchOrMotion {
    return [self stringForKey:kDPadTouchOrMotion];
}

- (void)setDpadTouchOrMotion:(NSString *)dpadTouchOrMotion {
    [self setObject:dpadTouchOrMotion forKey:kDPadTouchOrMotion];
}

- (BOOL)DPadModeIsTouch {
    return [[self stringForKey:kDPadTouchOrMotion] isEqualToString: @"Touch"];
}

- (BOOL)DPadModeIsMotion {
    return [[self stringForKey:kDPadTouchOrMotion]  isEqualToString: @"Motion"];
}

- (BOOL)gyroToggleUpDown {
    return [self boolForKey:kGyroToggleUpDown];
}

- (void)setGyroToggleUpDown:(BOOL)gyroToggleUpDown {
    [self setBool:gyroToggleUpDown forKey:kGyroToggleUpDown];
}

- (float)gyroSensitivity {
    return [self floatForKey:kGyroSensitivity];
}

- (void)setGyroSensitivity:(float)gyroSensitivity {
    [self setFloat:gyroSensitivity forKey:kGyroSensitivity];
}

- (BOOL)RStickAnalogIsMouse {
    return [self boolForKey:kRstickmouseFlag];
}

- (BOOL)LStickAnalogIsMouse {
    return [self boolForKey:kLstickmouseFlag];
}

- (BOOL) useL2forMouseButton {
    return [self boolForKey:kL2mouseFlag];
}

- (BOOL) useR2forRightMouseButton {
    return [self boolForKey:kR2mouseFlag];
}

- (void) setUseL2forMouseButton:(BOOL)L2mouseFlag {
    [self setBool:L2mouseFlag forKey:kL2mouseFlag];
}

- (void) setUseR2forRightMouseButton:(BOOL)R2mouseFlag {
    [self setBool:R2mouseFlag forKey:kR2mouseFlag];
}

- (void)setRStickAnalogIsMouse:(BOOL)rstickmouseFlag
{
    [self setBool:rstickmouseFlag forKey:kRstickmouseFlag];
}

- (void)setLStickAnalogIsMouse:(BOOL)lstickmouseFlag
{
    [self setBool:lstickmouseFlag forKey:kLstickmouseFlag];
}

-(NSString *)keyConfigurationforButton:(int)bID forController:(int)cNumber
{
    if(cNumber == 1)
        return [self stringForKey:[NSString stringWithFormat:@"_BTN_%d", bID]];
    else
        return [self stringForKey:[NSString stringWithFormat:@"_BTN_%d_%d", cNumber, bID]];
}

-(NSString *)keyConfigurationforButton:(int)bID
{
    return [self keyConfigurationforButton:bID forController:_cNumber];
}

-(void)setKeyconfiguration:(NSString *)configuredkey forController:(int)cNumber Button:(int)button {
    
    NSString *sKey = (cNumber == 1) ? [NSString stringWithFormat:@"_BTN_%d", button] : [NSString stringWithFormat:@"_BTN_%d_%d", cNumber, button];
    
    if(![self keyExists:sKey]) _keyConfigurationCount = cNumber;
    [self setObject:configuredkey forKey:sKey];
    
}

-(void)setKeyconfiguration:(NSString *)configuredkey Button:(int)button {
    [self setKeyconfiguration:configuredkey forController:_cNumber Button:button];
}

-(void)setCNumber:(int)cNumber {
    _cNumber = cNumber;
}

-(NSString *)keyConfigurationNameforButton:(int)bID {
    return [self keyConfigurationNameforButton:bID forController:_cNumber];
}

- (NSString *)keyConfigurationNameforButton:(int)bID forController:(int)cNumber {
    if(cNumber == 1)
        return [self stringForKey:[NSString stringWithFormat:@"_BTNN_%d", bID]];
    else
        return [self stringForKey:[NSString stringWithFormat:@"_BTNN_%d_%d", cNumber, bID]];
}

-(void)setKeyconfigurationname:(NSString *)configuredkey forController:(int)cNumber  Button:(int)button {
    
    if(cNumber == 1)
        [self setObject:configuredkey forKey:[NSString stringWithFormat:@"_BTNN_%d", button]];
    else
        [self setObject:configuredkey forKey:[NSString stringWithFormat:@"_BTNN_%d_%d", cNumber, button]];
}

-(void)setKeyconfigurationname:(NSString *)configuredkey Button:(int)button {
    [self setKeyconfigurationname:configuredkey forController:_cNumber Button:button];
}

- (BOOL)showStatusBar {
    return [self boolForKey:kShowStatusBarKey];
}

- (void)setShowStatusBar:(BOOL)showStatusBar {
    [self setBool:showStatusBar forKey:kShowStatusBarKey];
}

- (NSUInteger)selectedEffectIndex {
    return [self integerForKey:kSelectedEffectIndexKey];
}

- (void)setSelectedEffectIndex:(NSUInteger)selectedEffectIndex {
    return [self setInteger:selectedEffectIndex forKey:kSelectedEffectIndexKey];
}

- (NSString *)configurationName {
    return [self stringForKey:kConfigurationNameKey];
}

- (void)setConfigurationName:(NSString *)configurationName {
    [self setObject:configurationName forKey:kConfigurationNameKey];
    [self initializeCommonSettings];
    [self initializespecificsettings];
}

- (NSArray *)configurations {
    return [self arrayForKey:kConfigurationsKey];
}

- (void)setConfigurations:(NSArray *)configurations {
    [self setObject:configurations forKey:kConfigurationsKey];
}

- (NSArray *)controllers {
    return [self arrayForKey:kControllersKey];
}

- (void)setControllers:(NSArray *)controllers {
    [self setObject:controllers forKey:kControllersKey];
}

- (NSString *)romPath {
    return [self stringForKey:kRomPath];
}

- (void)setRomPath:(NSString *)romPath {
    [self setObject:romPath forKey:kRomPath];
}

- (DriveState *)driveState {
    DriveState *driveState = [[[DriveState alloc] init] autorelease];
    driveState.df1Enabled = [self boolForKey:kDf1EnabledKey];
    driveState.df2Enabled = [self boolForKey:kDf2EnabledKey];
    driveState.df3Enabled = [self boolForKey:kDf3EnabledKey];
    return driveState;
}

- (void)setDriveState:(DriveState *)driveState {
    [self setBool:driveState.df1Enabled forKey:kDf1EnabledKey];
    [self setBool:driveState.df2Enabled forKey:kDf2EnabledKey];
    [self setBool:driveState.df3Enabled forKey:kDf3EnabledKey];
}

- (NSString *)hardfilePath {
    return [self stringForKey:kHardfilePath];
}

- (void)setHardfilePath:(NSString *)hardfilePath {
    [self setObject:hardfilePath forKey:kHardfilePath];
}

- (BOOL)hardfileReadOnly {
    return [self boolForKey:kHardfileReadOnly];
}

- (void)setHardfileReadOnly:(BOOL)hardfileReadOnly {
    [self setBool:hardfileReadOnly forKey:kHardfileReadOnly];
}

- (BOOL)keyButtonsEnabled {
    return [self boolForKey:kKeyButtonsEnabledKey];
}

- (void)setKeyButtonsEnabled:(BOOL)keyButtonsEnabled {
    [self setBool:keyButtonsEnabled forKey:kKeyButtonsEnabledKey];
}

- (NSArray *)keyButtonConfigurations {
    NSString *json = [self stringForKey:kKeyButtonConfigurationsKey];
    return [KeyButtonConfiguration deserializeFromJSON:json];
}

- (void)setKeyButtonConfigurations:(NSArray *)keyButtonConfigurations {
    NSString *json = [KeyButtonConfiguration serializeToJSON:keyButtonConfigurations];
    [self setObject:json forKey:kKeyButtonConfigurationsKey];
}

- (void)registerKeyButtonSettingHandler:(id<SettingHandler>)settingHandler {
    NSString *key = [self getInternalSettingKey:kKeyButtonConfigurationsKey];
    [settingNameToHandler setObject:settingHandler forKey:key];
}

- (void)unregisterKeyButtonSettingHandler {
    NSString *key = [self getInternalSettingKey:kKeyButtonConfigurationsKey];
    [settingNameToHandler removeObjectForKey:key];
}

- (BOOL)hasSettingHandlers {
    return [settingNameToHandler count] > 0;
}

- (BOOL)boolForKey:(NSString *)settingName {
    NSString *key = [self getInternalSettingKey:settingName];
    id<SettingHandler> handler = [settingNameToHandler objectForKey:key];
    if (handler) {
        NSNumber *n = [handler loadSettingValue];
        return [n boolValue];
    } else {
        return [defaults boolForKey:key];
    }
}

- (void)setBool:(BOOL)value forKey:(NSString *)settingName {
    NSString *key = [self getInternalSettingKey:settingName];
    id<SettingHandler> handler = [settingNameToHandler objectForKey:key];
    if (handler) {
        [handler saveSettingValue:[NSNumber numberWithBool:value]];
    } else {
        [defaults setBool:value forKey:key];
    }
}

- (id)objectForKey:(NSString *)settingName {
    NSString *key = [self getInternalSettingKey:settingName];
    id<SettingHandler> handler = [settingNameToHandler objectForKey:key];
    if (handler) {
        return [handler loadSettingValue];
    } else {
        return [defaults objectForKey:key];
    }
}

- (void)setObject:(id)value forKey:(NSString *)settingName {
    NSString *key = [self getInternalSettingKey:settingName];
    id<SettingHandler> handler = [settingNameToHandler objectForKey:key];
    if (handler) {
        [handler saveSettingValue:value];
    } else {
        [defaults setObject:value forKey:key];
    }
}

- (NSInteger)integerForKey:(NSString *)settingName {
    NSString *key = [self getInternalSettingKey:settingName];
    id<SettingHandler> handler = [settingNameToHandler objectForKey:key];
    if (handler) {
        NSNumber *n = [handler loadSettingValue];
        return [n integerValue];
    } else {
        return [defaults integerForKey:key];
    }
}

- (void)setInteger:(NSInteger)value forKey:(NSString *)settingName {
    NSString *key = [self getInternalSettingKey:settingName];
    id<SettingHandler> handler = [settingNameToHandler objectForKey:key];
    if (handler) {
        [handler saveSettingValue:[NSNumber numberWithInteger:value]];
    } else {
        [defaults setInteger:value forKey:key];
    }
}

- (float)floatForKey:(NSString *)settingName {
    NSString *key = [self getInternalSettingKey:settingName];
    id<SettingHandler> handler = [settingNameToHandler objectForKey:key];
    if (handler) {
        NSNumber *n = [handler loadSettingValue];
        return [n floatValue];
    } else {
        return [defaults floatForKey:key];
    }
}

- (void)setFloat:(float)value forKey:(NSString *)settingName {
    NSString *key = [self getInternalSettingKey:settingName];
    id<SettingHandler> handler = [settingNameToHandler objectForKey:key];
    if (handler) {
        [handler saveSettingValue:[NSNumber numberWithFloat:value]];
    } else {
        [defaults setFloat:value forKey:key];
    }
}

- (NSString *)stringForKey:(NSString *)settingName {
    NSString *key = [self getInternalSettingKey:settingName];
    id<SettingHandler> handler = [settingNameToHandler objectForKey:key];
    if (handler) {
        return [handler loadSettingValue];
    }
    return [defaults stringForKey:key];
}

- (NSArray *)arrayForKey:(NSString *)settingitemname {
    return [defaults arrayForKey:[self getInternalSettingKey:settingitemname]];
}

- (void)removeObjectForKey:(NSString *) settingitemname {
    [defaults removeObjectForKey:[self getInternalSettingKey:settingitemname]];
}

- (NSString *)getInternalSettingKey:(NSString *)name {
    // if name starts with '_', the setting is stored in its own configuration
    return [name hasPrefix:@"_"] ? [NSString stringWithFormat:@"%@%@", _configurationname, name] : name;
}

- (NSString *)configForDisk:(NSString *)diskName {
    NSString *settingstring = [NSString stringWithFormat:@"cnf%@", diskName];
    return [defaults stringForKey:settingstring];
}

- (void)setConfig:(NSString *)configName forDisk:(NSString *)diskName {
    NSString *configstring = [NSString stringWithFormat:@"cnf%@", diskName];
    if ([configName isEqual:@"None"]) {
        if ([self configForDisk:diskName]) {
            [defaults setObject:nil forKey:configstring];
        }
    }
    else {
        [defaults setObject:configName forKey:configstring];
    }
}

- (void)clearAllSettingHandlers {
    [settingNameToHandler removeAllObjects];
}

- (void)dealloc {
    [defaults release];
    defaults = nil;
    [super dealloc];
}
         
@end
