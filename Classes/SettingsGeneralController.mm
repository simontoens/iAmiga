//
//  SettingsGeneralController.m
//  iUAE
//
//  Created by Emufr3ak on 29.12.14.
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
// along with this program; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

#import "CoreSetting.h"
#import "DiskDriveService.h"
#import "SettingsGeneralController.h"
#import "Settings.h"
#import "StateManagementController.h"
#import "UnappliedSettingLabelHandler.h"
#import "AudioService.h"

static NSString *const kNoDiskLabel = @"Empty";
static NSString *const kNoDiskAdfPath = @"";

static NSString *const kSelectFileSegue = @"SelectFile";
static NSString *const kAssignDiskfilesSegue = @"AssignDiskfiles";
static NSString *const kLoadConfigurationSegue = @"LoadConfiguration";
static NSString *const kKeyButtonsSegue = @"KeyButtons";
static NSString *const kStateManagementSegue = @"StateManagement";

static const NSUInteger kRomSection = 0;
static const NSUInteger kDiskDrivesSection = 1;
static const NSUInteger kConfigSection = 2;
static const NSUInteger kMiscSection = 3;
static const NSUInteger kHardDrivesSection = 4;

@protocol FileSelectionContext <NSObject>
@property (nonatomic, readonly) NSArray *extensions;
@end

@interface AdfSelectionContext : NSObject <FileSelectionContext>
@property (nonatomic, assign) NSInteger driveNumber;
@end
@implementation AdfSelectionContext : NSObject
- (NSArray *)extensions {
    return @[@"ADF", @"adf"];
}
@end

@interface RomSelectionContext : NSObject <FileSelectionContext>
@end
@implementation RomSelectionContext : NSObject
- (NSArray *)extensions {
    return @[@"rom", @"ROM"];
}
@end

@interface HdfSelectionContext : NSObject <FileSelectionContext>
@end
@implementation HdfSelectionContext : NSObject
- (NSArray *)extensions {
    return @[@"hdf", @"HDF"];
}
@end

@implementation SettingsGeneralController {
    @private
    DiskDriveService *_diskDriveService;
    Settings *_settings;
    UnappliedSettingLabelHandler *_settingLabelHandler;
    
    DF1EnabledCoreSetting *_df1EnabledSetting;
    DF2EnabledCoreSetting *_df2EnabledSetting;
    DF3EnabledCoreSetting *_df3EnabledSetting;
    HD0PathCoreSetting *_hd0PathSetting;
    HD0ReadOnlyCoreSetting *_hd0ReadOnlySetting;
    RomCoreSetting *_romSetting;
    NTSCEnabledCoreSetting *_ntscEnabledSetting;
    CMemCoreSetting *_cmemSetting;
    FMemCoreSetting *_fmemSetting;
    AudioService *_audioService;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _diskDriveService = [[DiskDriveService alloc] init];
    _settings = [[Settings alloc] init];
    _settingLabelHandler = [[UnappliedSettingLabelHandler alloc] init];

    _df1EnabledSetting = [[CoreSettings df1EnabledCoreSetting] retain];
    _df2EnabledSetting = [[CoreSettings df2EnabledCoreSetting] retain];
    _df3EnabledSetting = [[CoreSettings df3EnabledCoreSetting] retain];
    _hd0PathSetting = [HD0PathCoreSetting getInstance];
    _hd0ReadOnlySetting = [[CoreSettings hd0ReadOnlyCoreSetting] retain];
    _romSetting = [RomCoreSetting getInstance];
    _ntscEnabledSetting = [[CoreSettings ntscEnabledCoreSetting] retain];
    _audioService = [[AudioService alloc] init];
    _cmemSetting = [CMemCoreSetting getInstance];
    _fmemSetting = [FMemCoreSetting getInstance];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [_settingLabelHandler layoutLabels];
}

- (void)viewWillAppear:(BOOL)animated {
    [self setupUIState];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)setupUIState {
    [self setupRomLabel];
    [self setupDriveLabels];
    [self setupAutoloadConfigSwitch];
    [self setupConfigurationName];
    [self setupDriveEnabledSwitches];
    [self setupDriveReadOnlySwitches];
    [self setupWarningLabels];
}

- (void)setupDriveEnabledSwitches {
    [_df1Switch setOn:[[_df1EnabledSetting getValue] boolValue]];
    [_df2Switch setOn:[[_df2EnabledSetting getValue] boolValue]];
    [_df3Switch setOn:[[_df3EnabledSetting getValue] boolValue]];
}

- (void)setupDriveLabels {
    NSString *adfPath = [_diskDriveService getInsertedDiskForDrive:0];
    [_df0PathLabel setText:adfPath ? [adfPath lastPathComponent] : kNoDiskLabel];
    
    adfPath = [_diskDriveService getInsertedDiskForDrive:1];
    [_df1PathLabel setText:adfPath ? [adfPath lastPathComponent] : kNoDiskLabel];
    
    adfPath = [_diskDriveService getInsertedDiskForDrive:2];
    [_df2PathLabel setText:adfPath ? [adfPath lastPathComponent] : kNoDiskLabel];
    
    adfPath = [_diskDriveService getInsertedDiskForDrive:3];
    [_df3PathLabel setText:adfPath ? [adfPath lastPathComponent] : kNoDiskLabel];
    
    NSString *hdfPath = [_hd0PathSetting getValue];
    [_hd0PathLabel setText:hdfPath ? [hdfPath lastPathComponent] : @""];
}

- (void)setupDriveReadOnlySwitches {
    NSUInteger selectedSegment = [[_hd0ReadOnlySetting getValue] boolValue] ? 0 : 1;
    [_hd0ReadOnlySegmentedControl setSelectedSegmentIndex:selectedSegment];
    _hd0ReadOnlySegmentedControl.userInteractionEnabled = [_hd0PathSetting getValue] != nil;
}

- (void)setupWarningLabels {
    [_settingLabelHandler updateLabelStates];
}

- (void)setupRomLabel {
    NSString *romPath = [_romSetting getValue];
    [_romPathLabel setText:romPath ? [romPath lastPathComponent] : @""];
}

- (void)setupConfigurationName {
    if(_settings.configurationName)
    {
        [_configNameLabel setText:_settings.configurationName];
    }
}

- (void)setupAutoloadConfigSwitch {
    [_configAutoloadSwitch setOn:_settings.autoloadConfig];
}

- (IBAction)toggleAutoloadconfig {
    _settings.autoloadConfig = !_settings.autoloadConfig;
}

- (IBAction)toggleDF1Enabled {
    [_df1EnabledSetting setValue:[NSNumber numberWithBool:_df1Switch.on]];
    [self setupWarningLabels];
}

- (IBAction)toogleDF2Enabled {
    [_df2EnabledSetting setValue:[NSNumber numberWithBool:_df2Switch.on]];
    [self setupWarningLabels];
}

- (IBAction)toggleDF3Enabled {
    [_df3EnabledSetting setValue:[NSNumber numberWithBool:_df3Switch.on]];
    [self setupWarningLabels];
}

- (IBAction)toggleHD0ReadOnly {
    [_hd0ReadOnlySetting setValue:[NSNumber numberWithBool:_hd0ReadOnlySegmentedControl.selectedSegmentIndex == 0 ? YES : NO]];
    [self setupWarningLabels];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kDiskDrivesSection)
    {
        return [_diskDriveService diskInsertedIntoDrive:indexPath.row];
    }
    else if (indexPath.section == kHardDrivesSection)
    {
        return [_hd0PathSetting getValue] != nil;
    }
    return NO;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == kDiskDrivesSection ? @"Eject" : @"Unmount";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:self.tableView cellForRowAtIndexPath:indexPath];
    NSArray *settings = [self getSettingsForIndexPath:indexPath];
    [_settingLabelHandler addResetWarningLabelForCell:cell forSettings:settings];
    return cell;
}

- (NSArray *)getSettingsForIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kRomSection)
    {
        return @[_romSetting];
    }
    else if (indexPath.section == kDiskDrivesSection)
    {
        NSInteger driveNumber = indexPath.row;
        if (driveNumber == 1)
        {
            return @[_df1EnabledSetting];
        }
        else if (driveNumber == 2)
        {
            return @[_df2EnabledSetting];
        }
        else if (driveNumber == 3)
        {
            return @[_df3EnabledSetting];
        }

    }
    else if (indexPath.section == kHardDrivesSection)
    {
        return @[_hd0PathSetting, _hd0ReadOnlySetting];
    }
    return @[];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        if (indexPath.section == kDiskDrivesSection)
        {
            NSInteger driveNumber = indexPath.row;
            [self onAdfChanged:kNoDiskAdfPath drive:driveNumber];
            [_diskDriveService ejectDiskFromDrive:driveNumber];
        }
        else
        {
            [_hd0PathSetting setValue:nil];
            [_hd0ReadOnlySetting setValue:[NSNumber numberWithBool:YES]];
            [self setupDriveReadOnlySwitches];
        }
        [self.tableView setEditing:NO animated:YES];
        [self setupDriveLabels];
        [self setupWarningLabels];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == kRomSection || indexPath.section == kDiskDrivesSection || indexPath.section == kHardDrivesSection)
    {
        id<FileSelectionContext> ctx = nil;
        if (indexPath.section == kDiskDrivesSection)
        {
            ctx = [[[AdfSelectionContext alloc] init] autorelease];
            ((AdfSelectionContext *)ctx).driveNumber = indexPath.row;
        }
        else if (indexPath.section == kHardDrivesSection)
        {
            ctx = [[[HdfSelectionContext alloc] init] autorelease];
        }
        else
        {
            ctx = [[[RomSelectionContext alloc] init] autorelease];
        }
        [self performSegueWithIdentifier:kSelectFileSegue sender:ctx];
    }
    else if (indexPath.section == kConfigSection)
    {
        if (indexPath.row == 1)
        {
            [self performSegueWithIdentifier:kAssignDiskfilesSegue sender:nil];
        }
        else if (indexPath.row == 2)
        {
            [self performSegueWithIdentifier:kLoadConfigurationSegue sender:nil];
        }
    }
    else if (indexPath.section == kMiscSection)
    {
        if (indexPath.row == 0)
        {
            [self performSegueWithIdentifier:kKeyButtonsSegue sender:nil];
        }
        else if (indexPath.row == 1)
        {
            [self performSegueWithIdentifier:kStateManagementSegue sender:nil];
        }
        else if (indexPath.row == 2)
        {
            [self showResetConfirmation];
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kSelectFileSegue])
    {
        EMUROMBrowserViewController *controller = segue.destinationViewController;
        id<FileSelectionContext> ctx = sender;
        controller.extensions = ctx.extensions;
        controller.delegate = self;
        controller.context = ctx;
    }
    else if ([segue.identifier isEqualToString:kLoadConfigurationSegue])
    {
        SelectConfigurationViewController *controller = segue.destinationViewController;
        controller.delegate = self;
    }
    else if ([segue.identifier isEqualToString:kStateManagementSegue])
    {
        StateManagementController *stateController = segue.destinationViewController;
        stateController.emulatorScreenshot = _emulatorScreenshot;
    }
}

// SelectRomDelegate - callback when selecting an adf/rom/hdf
- (void)didSelectROM:(EMUFileInfo *)fileInfo withContext:(id<FileSelectionContext>)ctx {
    NSString *path = [fileInfo path];
    if ([ctx class] == [RomSelectionContext class])
    {
        [self didReallySelectRom:path];
    }
    else if ([ctx class] == [AdfSelectionContext class])
    {
        [self didSelectAdf:path context:ctx];
    }
    else
    {
        [self didSelectHdf:path];
    }
}

- (void)didReallySelectRom:(NSString *)romPath {
    [_romSetting setValue:romPath];
    [self setupRomLabel];
}

- (void)didSelectAdf:(NSString *)adfPath context:(AdfSelectionContext *)ctx {
    [self onAdfChanged:adfPath drive:ctx.driveNumber];
    [_diskDriveService insertDisk:adfPath intoDrive:ctx.driveNumber];
}

- (void)didSelectHdf:(NSString *)hdfPath {
    [_hd0PathSetting setValue:hdfPath];
    [self setupDriveLabels];
    [self setupWarningLabels];
}

- (void)onAdfChanged:(NSString *)adfPath drive:(NSUInteger)driveNumber {
    NSArray *floppyPaths = _settings.insertedFloppies;
    NSMutableArray *mutableFloppyPaths = floppyPaths ?
        [[floppyPaths mutableCopy] autorelease] : [[[NSMutableArray alloc] init] autorelease];
    while ([mutableFloppyPaths count] <= driveNumber)
    {
        // pad the array if a disk is inserted into a drive with a higher number, and
        // there's nothing in the lower number drive(s) yet
        [mutableFloppyPaths addObject:kNoDiskAdfPath];
    }
    [mutableFloppyPaths replaceObjectAtIndex:driveNumber withObject:adfPath];
    _settings.insertedFloppies = mutableFloppyPaths;
    [_settings setFloppyConfiguration:adfPath];
}

- (NSString *)getFirstOption {
    return @"General";
}

- (BOOL)isRecentConfig:(NSString *)configurationname {    
    return [_configNameLabel.text isEqualToString:configurationname];
}

- (void)didSelectConfiguration:(NSString *)configurationName {
    [_configNameLabel setText:configurationName];
    _settings.configurationName = configurationName;
    [_ntscEnabledSetting setValue:[NSNumber numberWithBool:_settings.ntsc]];
    [_romSetting setValue: [_romSetting getValue]];
    [_hd0PathSetting setValue:[_hd0PathSetting getValue]];
    [_hd0ReadOnlySetting setValue:[_hd0ReadOnlySetting getValue]];
    [_cmemSetting setValue:[NSNumber numberWithInteger:_settings.CMem]];
    [_fmemSetting setValue:[NSNumber numberWithInteger:_settings.FMem]];
    [self setupUIState];
    [_audioService setVolume:_settings.volume];
}

- (void)didDeleteConfiguration {
    NSArray *configurations = _settings.configurations;
    
    if(![configurations indexOfObject:_configNameLabel.text])
    {
        [_configNameLabel setText:@"General"];
    }
}

- (void)showResetConfirmation {
    UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:@"Reset"
                                            message:@"Really reset the emulator?"
                                     preferredStyle:UIAlertControllerStyleAlert];

    if ([_settings hasSettingHandlers]) {
        UIAlertAction *ra = [UIAlertAction actionWithTitle:@"OK - reset state config"
                                                     style:UIAlertViewStyleDefault
                                                   handler:^(UIAlertAction *action) {
                                                       [self resetAndClearStateConfig:YES];
                                                   }];
        [alert addAction:ra];
        UIAlertAction *rs = [UIAlertAction actionWithTitle:@"OK - keep state config"
                                                     style:UIAlertViewStyleDefault
                                                   handler:^(UIAlertAction *action) {
                                                       [self resetAndClearStateConfig:NO];
                                                   }];
        [alert addAction:rs];
    } else {
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK"
                                                     style:UIAlertViewStyleDefault
                                                   handler:^(UIAlertAction *action) {
                                                       [self resetAndClearStateConfig:YES];
                                                   }];
        [alert addAction:ok];
    }
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertViewStyleDefault
                                                   handler:nil];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)resetAndClearStateConfig:(BOOL)clearStateConfig {
    [_resetDelegate didSelectReset:[self getDriveState]];
    [CoreSettings onReset];
    if (clearStateConfig) {
        [_settings clearAllSettingHandlers];
    }
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (DriveState *)getDriveState {
    DriveState *driveState = [DriveState getAllEnabled];
    driveState.df1Enabled = [[_df1EnabledSetting getValue] boolValue];
    driveState.df2Enabled = [[_df2EnabledSetting getValue] boolValue];
    driveState.df3Enabled = [[_df3EnabledSetting getValue] boolValue];
    return driveState;
}

- (void)dealloc {
    [_diskDriveService release];
    [_settings release];
    [_emulatorScreenshot release];
    [_settingLabelHandler release];

    [_df1EnabledSetting release];
    [_df2EnabledSetting release];
    [_df3EnabledSetting release];
    [_hd0ReadOnlySetting release];
    
    [super dealloc];
}

@end
