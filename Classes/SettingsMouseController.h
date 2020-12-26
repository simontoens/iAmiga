//
//  SettingsMouseController.h
//  iUAE
//
//  Created by Urs on 08.08.16.
//
//

#import <UIKit/UIKit.h>

@interface SettingsMouseController : UITableViewController

@property (retain, nonatomic) IBOutlet UISwitch *rstickSwitch;
@property (retain, nonatomic) IBOutlet UISwitch *lstickSwitch;
@property (retain, nonatomic) IBOutlet UISwitch *butSwitch;
@property (retain, nonatomic) IBOutlet UISwitch *rbutSwitch;
@property (retain, nonatomic) IBOutlet UISwitch *speedSwitch;

- (IBAction)togglerStick:(id)sender;
- (IBAction)togglelStick:(id)sender;
- (IBAction)togglebutSwitch:(id)sender;
- (IBAction)togglerbutSwitch:(id)sender;
//- (IBAction)togglespeedSwitch:(id)sender;

@end
