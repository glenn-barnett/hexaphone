//
//  ScalePickerViewController.m
//  Hexatone
//
//  Created by Glenn Barnett on 5/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ScalePickerViewController.h"
#import "HexaphoneAppDelegate.h"
#import "Instrument.h"
#import "ScaleManager.h"
#import "Scale.h"
#import "AppStateManager.h"
#import "AppState.h"

#import "UIConstants.h"

@implementation ScalePickerViewController

@synthesize appDelegate;

- (id)init  {
    if (self = [super initWithStyle:UITableViewStylePlain]) {
		
    }
    return self;
}

-(void) show {
	self.view.hidden = NO;
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
	
	
	tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	tableView.rowHeight = 100;
	tableView.backgroundColor = [UIColor clearColor];
	imageView.image = [UIImage imageNamed:@"picker-bg.png"];
		
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = kRowHeight;
	self.tableView.sectionHeaderHeight = 15;
    //self.tableView.backgroundColor = UIColorFromRGB(0x1e1e1e);
	//self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"picker-bg.png"]];
	self.tableView.backgroundColor = [UIColor clearColor];
	
}


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
	if([appDelegate.appStateManager.appState hasAnyRecentScales])
		return 2;
	else 
		return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if([appDelegate.appStateManager.appState hasAnyRecentScales] && section == 0) { // recent
		int recentCount = 0;
		if(appDelegate.appStateManager.appState.recentScaleId1 != nil) recentCount++;
		if(appDelegate.appStateManager.appState.recentScaleId2 != nil) recentCount++;
		if(appDelegate.appStateManager.appState.recentScaleId3 != nil) recentCount++;
		return recentCount;
	} else {
		return [appDelegate.scaleManager.sortedScales count];
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
	
	if(section == 0 && [appDelegate.appStateManager.appState hasAnyRecentScales]) {
		headerLabel.text = @"Recently Used";
	} else {
		headerLabel.text = @"All Scales";
	}
	[customView addSubview:headerLabel];
	[headerLabel release];
	
	
	return [customView autorelease];
}


//
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//	
//	if(section == 0 && [appDelegate.appStateManager.appState hasAnyRecentScales]) {
//		return @"Recently Used Scales";
//	} else if(section == 1) {
//		return @"All Scales";
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
	
    
	Scale* scale;
	
	if(indexPath.section == 0 && [appDelegate.appStateManager.appState hasAnyRecentScales]) { // recent
		scale = [self getRecentScale:indexPath.row];
	} else { // all
		scale = [appDelegate.scaleManager.sortedScales objectAtIndex:indexPath.row];
	}
	
	cell.textLabel.textColor = UIColorFromRGB(0xFFdbe8ff);
	cell.textLabel.font = [UIFont boldSystemFontOfSize:12];
	cell.textLabel.text = scale.scaleName;
	
	cell.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"picker-bg.png"]];
	
	//cell.backgroundColor = [UIColor colorWithPatternImage:[[UIImage imageNamed:@"picker-bg.png"] stretchableImageWithLeftCapWidth:1 topCapHeight:1]];
	
	//cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"picker-bg.png"]] autorelease];
	
	cell.backgroundView = [[[UIImageView alloc] initWithFrame:CGRectMake(0,0,40,40)] autorelease];
	((UIImageView *)cell.backgroundView).image = [UIImage imageNamed:@"picker-bg.png"];
	((UIImageView *)cell.backgroundView).frame = CGRectMake(0, 0, 104, 20);
	
    // Set up the cell...
	
    return cell;
}

-(Scale*) getRecentScale:(int) index {
	if(index == 0) {
		return [appDelegate.scaleManager.scalesMap objectForKey:appDelegate.appStateManager.appState.recentScaleId1];
	} else if(index == 1) {
		return [appDelegate.scaleManager.scalesMap objectForKey:appDelegate.appStateManager.appState.recentScaleId2];
	} else {
		return [appDelegate.scaleManager.scalesMap objectForKey:appDelegate.appStateManager.appState.recentScaleId3];
	}
}



//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    // Navigation logic may go here. Create and push another view controller.
//	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
//	// [self.navigationController pushViewController:anotherViewController];
//	// [anotherViewController release];
//}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	Scale* scale;
	
	if(indexPath.section == 0 && [appDelegate.appStateManager.appState hasAnyRecentScales]) { // recent
		scale = [self getRecentScale:indexPath.row];
	} else { // all
		scale = [appDelegate.scaleManager.sortedScales objectAtIndex:indexPath.row];
	}
	
	[appDelegate.instrument loadScale:scale];
	
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

