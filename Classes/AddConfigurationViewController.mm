//  Created by Emufr3ak on 31.1.2016
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
#import "AddConfigurationViewController.h"
#import "Settings.h"

@interface AddConfigurationViewController ()

@end

@implementation AddConfigurationViewController {
    Settings *settings;
    NSMutableArray *configurations;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_add setEnabled:false];
    
    settings = [[Settings alloc] init];
    
    configurations = [[settings arrayForKey:@"configurations"] mutableCopy];

    if(!configurations)
    {
        configurations = [[NSMutableArray alloc] init];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)addConfiguration:(id)sender {
    if([configurations containsObject:_name.text] || [_name.text isEqual:@"None"])
    {
        UIAlertController * alert = [UIAlertController
                        alertControllerWithTitle:@"Configuration Exists"
                                         message:@"Configuration Already exists enter a new Name"
                                  preferredStyle:UIAlertControllerStyleAlert];



        UIAlertAction* okButton = [UIAlertAction
                            actionWithTitle:@"OK"
                                      style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        //Handle your yes please button action here
                                    }];

        [alert addAction:okButton];

        [self presentViewController:alert animated:YES completion:nil];
    }
    else
    {
        [configurations addObject:[NSString stringWithString:_name.text]];
        [settings setObject:configurations forKey:@"configurations"];
        [self.navigationController popViewControllerAnimated:YES];
        
        if(self.delegate)
        {
            [self.delegate configurationAdded:_name.text];
        }
    }
    
}

-(IBAction)toggleAddConfiguration:(id)sender {

    if(_name.text.length > 0)
    {
        [_add setEnabled:TRUE];
    }
    else
    {
        [_add setEnabled:FALSE];
    }
}

-(void)dealloc {
    [_add release];
    [_name release];
    [configurations release];
    [settings release];
    [super dealloc];
}

#pragma mark - Table view data source

@end
