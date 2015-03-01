//
//  SelectConfigurationViewController.m
//  iUAE
//
//  Created by Urs on 25.01.15.
//
//

#import "SelectConfigurationViewController.h"
#import "EMUBrowser.h"
#import "EMUFileInfo.h"

@interface SelectConfigurationViewController ()

@end

@implementation SelectConfigurationViewController {
    NSMutableArray *configurations;
    NSUserDefaults *defaults;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    defaults = [NSUserDefaults standardUserDefaults];
    configurations = [[defaults arrayForKey:@"configurations"] mutableCopy];
        
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidAppear:(BOOL)animated {
    configurations = [[defaults arrayForKey:@"configurations"] mutableCopy];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [configurations count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    
    if (configurations)
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
    NSString *configurationname = [configurations objectAtIndex:indexPath.row];
    cell.textLabel.text = configurationname;
    
    if(self.delegate)
    {
        if([self.delegate isRecentConfig:configurationname])
        {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.delegate)
    {
        NSString *configurationname = [configurations objectAtIndex:indexPath.row];
        
        [self.navigationController popViewControllerAnimated:YES];
        [self.delegate didSelectConfiguration:configurationname];
    }
}

- (void)configurationAdded:(NSString *)configurationname {
    if(!configurations)
    {
        configurations = [NSMutableArray arrayWithObjects:configurationname, nil];
    }
    else
    {
        [configurations addObject:configurationname];
    }
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void) dealloc {
    [configurations release];
    [super dealloc];
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        [self deleteConfiguration:indexPath];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];

    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

- (void)deleteConfiguration:(NSIndexPath *)indexPath {
    EMUBrowser *browser = [[EMUBrowser alloc] initWithBasePath:@""];
    NSArray *files = [browser getFiles];
    NSString *configdeleted = [configurations objectAtIndex:indexPath.row];
    
    [configurations removeObjectAtIndex:indexPath.row];
    [defaults setObject:configurations forKey:@"configurations"];
    
    NSString *recentconfig;
    for (EMUFileInfo* f in files) {
        
        /*Associated Configuration File*/
        NSString *settingstring = [NSString stringWithFormat:@"cnf%@", [f fileName]];
        NSString *configurationfile = [defaults stringForKey:settingstring] ? [defaults stringForKey:settingstring] : [NSString stringWithFormat:@""];
        if([configurationfile isEqualToString:configdeleted]) {
            if(self.delegate)
            {
                [self.delegate didDeleteConfiguration];
            }
            [defaults removeObjectForKey:settingstring];
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"addconfiguration"]) {
        AddConfigurationViewController *controller = (AddConfigurationViewController *)segue.destinationViewController;
        controller.delegate = self;
    }
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


