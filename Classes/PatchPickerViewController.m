//
//  PatchTableViewController.m
//  Hexatone
//
//  Created by Glenn Barnett on 5/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PatchPickerViewController.h"
#import "HexaphoneAppDelegate.h"
#import "Instrument.h"
#import "PatchManager.h"
#import "Patch.h"
#import "AppStateManager.h"
#import "AppState.h"

#import "UIConstants.h"

@implementation PatchPickerViewController

@synthesize appDelegate;

- (id)init  {
    if (self = [super initWithStyle:UITableViewStylePlain]) {

    }
    return self;
}

-(void) show {
	
//	[UIView beginAnimations:nil context:NULL];
//	[UIView setAnimationDuration:0.5];
//	
//	// GSB: this looks ok... 
//	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view cache:NO];
	
	self.view.hidden = NO;
	
	//	CGRect frame = appDelegate.patchTableViewController.view.frame;
	//	frame.size.height = UI_PATCHPICKERVC_WIDTH;
	//	frame.size.width = UI_PATCHPICKERVC_HEIGHT;
	//	frame.origin.x = UI_PATCHPICKERVC_YOFFSET; // GSB intentionally swapped
	//	frame.origin.y = UI_PATCHPICKERVC_XOFFSET; // GSB intentionally swapped
	//	appDelegate.patchTableViewController.view.frame = frame;
	
//	[UIView commitAnimations];
	
	//[appDelegate.patchManager openActionSheetInView:appDelegate.emptyLandscapeView];
}

-(void) hide {
	self.view.hidden = YES;
}

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/


#define kRowHeight 27



- (void)viewDidLoad {
    [super viewDidLoad];

	
	//GSB FROM COCOAWITHLOVE
	//
	// Change the properties of the imageView and tableView (these could be set
	// in interface builder instead).
	//
	tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	tableView.rowHeight = 100;
	tableView.backgroundColor = [UIColor clearColor];
	imageView.image = [UIImage imageNamed:@"picker-bg.png"];

	//	//
//	// Create a header view. Wrap it in a container to allow us to position
//	// it better.
//	//
//	UIView *containerView =
//	[[[UIView alloc]
//	  initWithFrame:CGRectMake(0, 0, 300, 60)]
//	 autorelease];
//	UILabel *headerLabel =
//	[[[UILabel alloc]
//	  initWithFrame:CGRectMake(10, 20, 300, 40)]
//	 autorelease];
//	headerLabel.text = NSLocalizedString(@"Header for the table", @"");
//	headerLabel.textColor = [UIColor whiteColor];
//	headerLabel.shadowColor = [UIColor blackColor];
//	headerLabel.shadowOffset = CGSizeMake(0, 1);
//	headerLabel.font = [UIFont boldSystemFontOfSize:22];
//	headerLabel.backgroundColor = [UIColor clearColor];
//	[containerView addSubview:headerLabel];
//	self.tableView.tableHeaderView = containerView;	
//	//GSB FROM COCOAWITHLOVE
	
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	//self.tableView.separatorColor = UIColorFromRGB(0x484848);
    self.tableView.rowHeight = kRowHeight;
	self.tableView.sectionHeaderHeight = 15;
    //self.tableView.backgroundColor = UIColorFromRGB(0x1e1e1e);
	//self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"picker-bg.png"]];
	self.tableView.backgroundColor = [UIColor clearColor];
	
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if([appDelegate.appStateManager.appState hasAnyRecentPatches])
		return 2;
	else 
		return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if([appDelegate.appStateManager.appState hasAnyRecentPatches] && section == 0) { // recent
		int recentCount = 0;
		if(appDelegate.appStateManager.appState.recentPatchId1 != nil) recentCount++;
		if(appDelegate.appStateManager.appState.recentPatchId2 != nil) recentCount++;
		if(appDelegate.appStateManager.appState.recentPatchId3 != nil) recentCount++;
		return recentCount;
	} else {
		return [appDelegate.patchManager.sortedPatches count];
	}
}

#define kHeaderSectionHeight 20.0
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return kHeaderSectionHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	// create the parent view that will hold header Label
	UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 300.0, kHeaderSectionHeight)];
//	customView.backgroundColor = [UIColor darkGrayColor];

	UIImageView* bgView = [[[UIImageView alloc] init] autorelease];
	bgView.image = [UIImage imageNamed:@"picker-bg.png"];
	bgView.frame = CGRectMake(0, 0, 144, 20);
	[customView addSubview:bgView];
	
	// create the button object
	UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	headerLabel.opaque = NO;
	headerLabel.textColor = [UIColor lightGrayColor];
	headerLabel.backgroundColor = [UIColor clearColor];
	//headerLabel.highlightedTextColor = [UIColor whiteColor];
	headerLabel.font = [UIFont systemFontOfSize:10];
	headerLabel.frame = CGRectMake(4.0, 0.0, 300.0, kHeaderSectionHeight);
	
	// If you want to align the header text as centered
	// headerLabel.frame = CGRectMake(150.0, 0.0, 300.0, 44.0);
	
	if(section == 0 && [appDelegate.appStateManager.appState hasAnyRecentPatches]) {
		headerLabel.text = @"Recently Used";
	} else {
		headerLabel.text = @"All Patches";
	}
	[customView addSubview:headerLabel];
	[headerLabel release];


	return [customView autorelease];
}


//
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//	
//	if(section == 0 && [appDelegate.appStateManager.appState hasAnyRecentPatches]) {
//		return @"Recently Used Patches";
//	} else if(section == 1) {
//		return @"All Patches";
//	} else {
//		return 0;
//	}
//}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	
    
	Patch* patch;
	
	if(indexPath.section == 0 && [appDelegate.appStateManager.appState hasAnyRecentPatches]) { // recent
		patch = [self getRecentPatch:indexPath.row];
	} else { // all
		patch = [appDelegate.patchManager.sortedPatches objectAtIndex:indexPath.row];
	}
	
	cell.textLabel.textColor = UIColorFromRGB(0xFFdbe8ff);
	cell.textLabel.font = [UIFont boldSystemFontOfSize:12];
	cell.textLabel.text = patch.patchName;
	//cell.textLabel.adjustsFontSizeToFitWidth = YES; //GSB: looks awful

	cell.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"picker-bg.png"]];

	//cell.backgroundColor = [UIColor colorWithPatternImage:[[UIImage imageNamed:@"picker-bg.png"] stretchableImageWithLeftCapWidth:1 topCapHeight:1]];
	
	//cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"picker-bg.png"]] autorelease];

	cell.backgroundView = [[[UIImageView alloc] initWithFrame:CGRectMake(0,0,40,40)] autorelease];
	((UIImageView *)cell.backgroundView).image = [UIImage imageNamed:@"picker-bg.png"];
	((UIImageView *)cell.backgroundView).frame = CGRectMake(0, 0, 104, 20);

    // Set up the cell...
	
    return cell;
}

-(Patch*) getRecentPatch:(int) index {
	if(index == 0) {
		return [appDelegate.patchManager.patchesMap objectForKey:appDelegate.appStateManager.appState.recentPatchId1];
	} else if(index == 1) {
		return [appDelegate.patchManager.patchesMap objectForKey:appDelegate.appStateManager.appState.recentPatchId2];
	} else {
		return [appDelegate.patchManager.patchesMap objectForKey:appDelegate.appStateManager.appState.recentPatchId3];
	}
}



//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    // Navigation logic may go here. Create and push another view controller.
//	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
//	// [self.navigationController pushViewController:anotherViewController];
//	// [anotherViewController release];
//}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	Patch* patch;
	
	if(indexPath.section == 0 && [appDelegate.appStateManager.appState hasAnyRecentPatches]) { // recent
		patch = [self getRecentPatch:indexPath.row];
	} else { // all
		patch = [appDelegate.patchManager.sortedPatches objectAtIndex:indexPath.row];
	}

	[appDelegate.instrument loadPatch:patch];
	
	[self hide];
	
	return nil; // returning nil will tell the UITableView NOT to select (blue-ify) the row
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


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


- (void)dealloc {
    [super dealloc];
}


@end

