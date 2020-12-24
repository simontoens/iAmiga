//
//  SettingsGeneralController.h
//  iUAE
//
//  Created by Emufr3ak on 24.05.15.
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

#import "SettingsJoypadController.h"
#import "Settings.h"
#import "JoypadKey.h"

@interface SettingsJoypadController ()

@end

@implementation SettingsJoypadController {
    Settings *settings;
    UITableViewCell *context;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    settings = [[Settings alloc] init];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillAppear:(BOOL)animated {
    _CellA.detailTextLabel.text = [settings keyConfigurationNameforButton:BTN_A];
    _CellB.detailTextLabel.text = [settings keyConfigurationNameforButton:BTN_B];
    _CellX.detailTextLabel.text = [settings keyConfigurationNameforButton:BTN_X];
    _CellY.detailTextLabel.text = [settings keyConfigurationNameforButton:BTN_Y];
    _CellL1.detailTextLabel.text = [settings keyConfigurationNameforButton:BTN_L1];
    _CellL2.detailTextLabel.text =  [settings keyConfigurationNameforButton:BTN_L2];
    _CellR1.detailTextLabel.text = [settings keyConfigurationNameforButton:BTN_R1];
    _CellR2.detailTextLabel.text = [settings keyConfigurationNameforButton:BTN_R2];
    _CellUp.detailTextLabel.text = [settings keyConfigurationNameforButton:BTN_UP];
    _CellDown.detailTextLabel.text = [settings keyConfigurationNameforButton:BTN_DOWN];
    _CellLeft.detailTextLabel.text = [settings keyConfigurationNameforButton:BTN_LEFT];
    _CellRight.detailTextLabel.text = [settings keyConfigurationNameforButton:BTN_RIGHT];
    _Port.detailTextLabel.text = [settings keyConfigurationforButton:PORT];
    
    BOOL vsFlag = [[settings keyConfigurationforButton:VSWITCH] isEqualToString:@"YES"] ? 1 : 0;
    [_vSWitch setOn:vsFlag];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"SelectKey"]) {
        UITableViewCell *cellsender = (UITableViewCell *) sender;
        SettingsSelectKeyViewController *controller = segue.destinationViewController;
        controller.delegate = self;
        context = cellsender;
        
        NSString *strbuttonconnected = [settings keyConfigurationNameforButton:(int) context.tag];
        
        NSString *joypaddetailtext = [strbuttonconnected isEqualToString:@"Joypad"] ? @"Joypad" : @"";
        NSString *keydetailtext = [strbuttonconnected isEqualToString:@"Joypad"] ? @"" : strbuttonconnected;
        
        controller.joypaddetailtext = joypaddetailtext;
        controller.keydetailtext = keydetailtext;
        
    }
}

- (void)didSelectJoypad {
    [settings setKeyconfiguration:@"Joypad" Button:(int) context.tag];
    [settings setKeyconfigurationname:@"Joypad" Button:(int) context.tag];
}

- (void)didSelectKey:(int)asciicode keyName:(NSString *)keyName {
    
    
    NSString *strConfigValue = [NSString stringWithFormat: @"KEY_%d", asciicode];
    [settings setKeyconfiguration:strConfigValue Button:(int) context.tag];
    [settings setKeyconfigurationname:keyName Button:(int) context.tag];
}

- (void)didSelectPort:(int)pNumber {
    
    [settings setKeyconfiguration:[NSString stringWithFormat:@"%d", pNumber] Button:PORT];
    
}

- (IBAction)togglevSwitch:(id)sender {
    
    NSString *vsFlag = _vSWitch.on == YES ? @"YES" : @"NO";
    [settings setKeyconfiguration:vsFlag Button:VSWITCH];
    
}

- (void)dealloc {
    [settings release];

    [_CellA release];
    [_CellB release];
    [_CellX release];
    [_CellY release];
    [_CellL1 release];
    [_CellL2 release];
    [_CellR1 release];
    [_CellR2 release];
    
    [_CellUp release];
    [_CellDown release];
    [_CellLeft release];
    [_CellRight release];
    [_Port release];
    [_vSWitch release];
    [super dealloc];
}

- (IBAction)togglevsWitch:(id)sender {
}
@end
