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

#import <UIKit/UIKit.h>
#import "IOSKeyboard.h"

@protocol SelectKeyDelegate
- (void)didSelectKey:(int)asciicode keyName:(NSString *)keyName;
- (void)didSelectJoypad;
@end

@interface SettingsSelectKeyViewController : UITableViewController <IOSKeyboardDelegate>

- (IBAction)associateKey:(id)sender;
- (IBAction)associateJoypad:(id)sender;

@property (nonatomic, assign) id<SelectKeyDelegate>	delegate;
@property (retain, nonatomic) IBOutlet UILabel *KeyDetailLabel;
@property (retain, nonatomic) IBOutlet UILabel *JoypadDetailLabel;
@property (readwrite,retain, nonatomic) IBOutlet UITableViewCell *CellJoypad;
@property (readwrite, retain, nonatomic) IBOutlet UITableViewCell *CellKey;
@property (readwrite, retain) NSString *joypaddetailtext;
@property (readwrite, retain) NSString *keydetailtext;

@end
