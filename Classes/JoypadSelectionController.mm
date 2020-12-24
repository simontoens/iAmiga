//
//  JoypadMappingMainController.m
//  iUAE
//
//  Created by Urs on 04.04.16.
//
//

#import "JoypadSelectionController.h"
#import "JoypadMainSettingsController.h"
#import "Settings.h"
#import "JoypadKey.h"

@implementation JoypadSelectionController {
    Settings *_settings;
    NSMutableArray *_controllers;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    _settings = [[Settings alloc] init];
    _controllers = [[_settings controllers] mutableCopy];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidAppear:(BOOL)animated {
    _controllers = [[_settings controllers] mutableCopy];
    //[configurations insertObject:firstoption atIndex:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_settings keyConfigurationCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    
    if ([_settings keyConfigurationforButton:BTN_A forController:(int) (indexPath.row + 1)])
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"
                                               forIndexPath:indexPath];
        [self configureCell:cell atIndexPath:indexPath];
        
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"EmptyCell" forIndexPath:indexPath];
    }
    
    return cell;
}

- (UITableViewCell *)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    //NSString *configurationname = [configurations objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"Controller %ld", indexPath.row + 1];

    return cell;
}

- (void)controllerAdded:(NSString *)configurationname {
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        //[self deleteConfiguration:indexPath];
        //[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    //} else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    bool returnvalue = indexPath.row == 0 ? FALSE : TRUE;
    return returnvalue;
}

- (void)deleteController:(NSIndexPath *)indexPath {
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString:@"showcontroller"]) {
        
        UITableViewCell *sCell = (UITableViewCell *) sender;
        NSInteger cNumber = [[self.tableView indexPathForCell:sCell] row] + 1;
        [_settings setCNumber:(int) cNumber];
        
    }
}

- (void) dealloc {
    [_settings release];
    [_controllers release];
    [super dealloc];
}

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
