/*
 Frodo, Commodore 64 emulator for the iPhone
 Copyright (C) 2007, 2008 Stuart Carnie
 See gpl.txt for license information.
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "DiskAssociationViewController.h"
#import "EMUBrowser.h"
#import "EMUFileInfo.h"
#import "EMUFileGroup.h"
#import "Settings.h"

@implementation DiskAssocationViewController {
    NSString *disktoassociate;
    Settings *settings;
}

@synthesize roms, selectedIndexPath, indexTitles, context;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Initialization code
	}
	return self;
}

- (void)viewDidLoad {
	
    settings = [[Settings alloc] init];
    self.title = @"Browser";
	
	self.indexTitles = [NSArray arrayWithObjects:@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", 
						@"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V",
						@"W", @"X", @"Y", @"Z", @"#", nil];
	
	NSMutableArray *sections = [[NSMutableArray alloc] init];
	for (int i = 0; i < 26; i++) {
		unichar c = i+65;
		EMUFileGroup *g = [[EMUFileGroup alloc] initWithSectionName:[NSString stringWithFormat:@"%c", c]];
		[sections addObject:g];
	}
	[sections addObject:[[EMUFileGroup alloc] initWithSectionName:@"#"]];
	
	EMUBrowser *browser = [[EMUBrowser alloc] init];
	NSArray *files = [browser getAdfFileInfos];
	for (EMUFileInfo* f in files) {
		unichar c = [[f fileName] characterAtIndex:0];
		if (isdigit(c)) {
			EMUFileGroup *g = (EMUFileGroup*)[sections objectAtIndex:26];
			[g.files addObject:f];
		} else {
			c = toupper(c) - 65;
			EMUFileGroup *g = (EMUFileGroup*)[sections objectAtIndex:c];
			[g.files addObject:f];
		}
	}
	[browser release];
	self.roms = sections;
}

- (void)viewDidAppear:(BOOL)animated {
//	if (!prefs)
//		prefs = new Prefs();
//	
//	prefs->Load(Frodo::prefs_path());
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationPortrait;
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.roms.count;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return indexTitles;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	EMUFileGroup *g = (EMUFileGroup*)[self.roms objectAtIndex:section];
	return g.sectionName;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    unichar c = [title characterAtIndex:0];
	if (c > 64 && c < 91)
		return c - 65;
	
    return 26;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	EMUFileGroup *g = (EMUFileGroup*)[self.roms objectAtIndex:section];
    return g.files.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	/*if (indexPath == selectedIndexPath)
		return;
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:self.selectedIndexPath];

    
    cell.accessoryType = UITableViewCellAccessoryNone;
	
	cell = [tableView cellForRowAtIndexPath:indexPath];
	//cell.accessoryType = UITableViewCellAccessoryCheckmark;
	self.selectedIndexPath = indexPath;
		
	EMUFileGroup *g = (EMUFileGroup*)[self.roms objectAtIndex:indexPath.section];
	EMUFileInfo *fi = [g.files objectAtIndex:indexPath.row];
	//[self dismissModalViewControllerAnimated:YES];
	[self.navigationController popViewControllerAnimated:YES];*/
}

#define CELL_ID @"DiskCell"

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    UITableViewCell *cell;
    EMUFileGroup *g = (EMUFileGroup*)[self.roms objectAtIndex:indexPath.section];
    
    if (g.files)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID
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
    
    /*Get Information */
    
    EMUFileGroup *g = (EMUFileGroup*)[self.roms objectAtIndex:indexPath.section];
    NSString *fileName = [(EMUFileInfo *)[g.files objectAtIndex:indexPath.row] fileName];
    
    NSString *configurationfile = [self getconfigforDisk:fileName];
    /*Set Cell Labels */
    cell.textLabel.text = fileName;
    cell.detailTextLabel.text = configurationfile;

    
    return cell;

}

- (NSString *) getconfigforDisk:(NSString *)fileName {
    
    NSString *configurationfile = [settings configForDisk:fileName] ? [settings configForDisk:fileName]  : [NSString stringWithFormat:@"None"];
    
    return configurationfile;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"associateconfiguration"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        EMUFileGroup *g = (EMUFileGroup*)[self.roms objectAtIndex:indexPath.section];
        disktoassociate = [[(EMUFileInfo *)[g.files objectAtIndex:indexPath.row] fileName] retain];
        
        SelectConfigurationViewController *controller = (SelectConfigurationViewController *)segue.destinationViewController;
        controller.delegate = self;
    }
}

- (BOOL)isRecentConfig:(NSString *)configurationname {
    
    if([[self getconfigforDisk:disktoassociate] isEqual:configurationname])
    {
        return true;
    }
    
    return false;
}

- (void)didSelectConfiguration:(NSString *)configurationname {
    [self saveConfiguration:configurationname];
    
    /*reload affected cell */
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
}

- (void)didDeleteConfiguration {
    [self.tableView beginUpdates];
    [self.tableView reloadData];
    [self.tableView endUpdates];
}

- (void)saveConfiguration:(NSString *)configurationname {
    
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    EMUFileGroup *g = (EMUFileGroup*)[self.roms objectAtIndex:indexPath.section];
    NSString *fileName = [(EMUFileInfo *)[g.files objectAtIndex:indexPath.row] fileName];
    
    [settings setConfig:configurationname forDisk:fileName];
    
}

- (NSString *)getFirstOption {
    return @"None";
}

- (void)dealloc {
	
	self.roms = nil;
	self.indexTitles = nil;
	self.selectedIndexPath = nil;
	self.context = nil;
    [settings release];
    settings = nil;
	[super dealloc];
}

@end
