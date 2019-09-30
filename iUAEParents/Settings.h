//
//  Settings.h
//  iUAE
//
//  Created by Urs on 08.03.15.
//
//

#import <Foundation/Foundation.h>
#import "DriveState.h"

@protocol protReloadSettings
- (void)settingsChanged;
@end

static NSString *const kJoyStyleOneButton = @"OneButton";
static NSString *const kJoyStyleFourButton = @"FourButton";

/**
 * Abstracts how/where a Setting is persisted.
 */
@protocol SettingHandler <NSObject>

- (id)loadSettingValue;
- (void)saveSettingValue:(id)value;

@end

@interface Settings : NSObject

/**
 * Properties for common settings.
 */
@property (nonatomic, readwrite, assign) BOOL autoloadConfig;
@property (nonatomic, readwrite, assign) NSArray *insertedFloppies;
@property (nonatomic, readwrite, assign) NSString *configurationName;
@property (nonatomic, readwrite, assign) NSArray *configurations;

@property (nonatomic, readwrite, assign) BOOL ntsc;
@property (nonatomic, readwrite, assign) BOOL stretchScreen;
@property (nonatomic, readwrite, assign) BOOL showStatus;
@property (nonatomic, readwrite, assign) BOOL showStatusBar;
@property (nonatomic, readwrite, assign) NSUInteger selectedEffectIndex;
@property (nonatomic, readwrite, assign) float volume;
@property (nonatomic, readwrite, assign) DriveState *driveState;
@property (nonatomic, readwrite, assign) NSString *romPath;
@property (nonatomic, readwrite, assign) NSString *hardfilePath;
@property (nonatomic, readwrite, assign) BOOL hardfileReadOnly;
@property (nonatomic, readwrite, assign) NSString *joypadstyle;
@property (nonatomic, readwrite, assign) NSString *joypadleftorright;
@property (nonatomic, readwrite, assign) BOOL joypadshowbuttontouch;
@property (nonatomic, readwrite, assign) BOOL keyButtonsEnabled;
@property (nonatomic, readwrite, assign) NSArray *keyButtonConfigurations;
@property (nonatomic, readwrite, assign) NSString *dpadTouchOrMotion;
@property (nonatomic, readonly, assign) BOOL DPadModeIsTouch;
@property (nonatomic, readonly, assign) BOOL DPadModeIsMotion;
@property (nonatomic, readwrite, assign) BOOL gyroToggleUpDown;
@property (nonatomic, readwrite, assign) float gyroSensitivity;
@property (nonatomic, readwrite, assign) BOOL LStickAnalogIsMouse;
@property (nonatomic, readwrite, assign) BOOL RStickAnalogIsMouse;
@property (nonatomic, readwrite, assign) BOOL useL2forMouseButton;
@property (nonatomic, readwrite, assign) BOOL useR2forRightMouseButton;
@property (nonatomic, readwrite, assign) NSUInteger controllersnextid;
@property (nonatomic, readwrite, assign) NSArray *controllers;
@property (nonatomic, readwrite, assign) NSInteger keyConfigurationCount;
@property (nonatomic, readwrite, assign) NSInteger CMem;
@property (nonatomic, readwrite, assign) NSInteger FMem;

/**
 * Some settings are written and read using custom logic instead of default device storage.
 * This method clears all registered custom logic handlers.
 */
- (void)clearAllSettingHandlers;

/**
 * Register a settingHandler for the KeyButtons settings.
 */
- (void)registerKeyButtonSettingHandler:(id<SettingHandler>)settingHandler;

- (void)initializespecificsettings;
- (void)setFloppyConfigurations:(NSArray *)adfPaths;
- (void)setFloppyConfiguration:(NSString *)adfPath;
- (void)setKeyconfiguration:(NSString *)configuredkey forController:(int)cNumber Button:(int)button;
- (void)setKeyconfiguration:(NSString *)configuredkey Button:(int)button;
- (void)setKeyconfigurationname:(NSString *)configuredkey forController:(int)cNumber Button:(int)button;
- (void)setKeyconfigurationname:(NSString *)configuredkey Button:(int)button;

- (void)setCNumber:(int)cNumber;

- (void)setBool:(BOOL)value forKey:(NSString *)settingitemname;
- (void)setObject:(id)value forKey:(NSString *)settingitemname;
- (BOOL)boolForKey:(NSString *)settingitemname;
- (NSString *)stringForKey:(NSString *)settingitemname;
- (NSArray *)arrayForKey:(NSString *)settingitemname;
- (void)removeObjectForKey:(NSString *) settingitemname;
- (NSString *)configForDisk:(NSString *)diskName;
- (void)setConfig:(NSString *)configName forDisk:(NSString *)diskName;
- (NSArray *)controllers;
- (void)setControllers:(NSArray *)controllers;
- (NSString *)keyConfigurationNameforButton:(int)bID forController:(int)cNumber;
- (NSString *)keyConfigurationNameforButton:(int)bID;
- (NSString *)keyConfigurationforButton:(int)bID forController:(int)cNumber;
- (NSString *)keyConfigurationforButton:(int)bID;

@end
