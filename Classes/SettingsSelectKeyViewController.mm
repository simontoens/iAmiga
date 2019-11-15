//
//  SettingsGeneralController.h
//  iUAE
//
//  Created by Emufr3ak on 24.5.15.
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

#import "SettingsSelectKeyViewController.h"
#import "IOSKeyboard.h"
#import "Settings.h"

@interface SettingsSelectKeyViewController ()

@end

@implementation SettingsSelectKeyViewController {
    IOSKeyboard *ioskeyboard;
    Settings *settings;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    ioskeyboard = [[IOSKeyboard alloc] initAndCreateDummyFields:self.view];
    ioskeyboard.delegate = self;
    
    settings = [[Settings alloc] init];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

}

- (void)viewWillAppear:(BOOL)animated {
    _KeyDetailLabel.text = _keydetailtext;
    _JoypadDetailLabel.text = _joypaddetailtext;
    
    _CellJoypad.accessoryType = [_joypaddetailtext isEqualToString:@"Joypad"] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    _CellKey.accessoryType = [_joypaddetailtext isEqualToString:@"Joypad"] ? UITableViewCellAccessoryNone : UITableViewCellAccessoryCheckmark;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)associateKey:(id)sender {
    
    [ioskeyboard toggleKeyboard];
}

- (IBAction)associateJoypad:(id)sender {
    
    [self.delegate didSelectJoypad];
    [self.navigationController popViewControllerAnimated:YES];

}

- (void)keyPressed:(int)asciicode keyName:(NSString *)keyName {
    [self.delegate didSelectKey:asciicode keyName:keyName];
    [ioskeyboard toggleKeyboard];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc
{
    [_CellKey release];
    [_CellJoypad release];
    [_JoypadDetailLabel release];
    [_KeyDetailLabel release];
    [settings release];
    [ioskeyboard release];
    
    [super dealloc];
}

@end
