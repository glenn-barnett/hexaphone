//
//  LoopPickerViewController.m
//  Hexatone
//
//  Created by Glenn Barnett on 5/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RecPickerViewController.h"
#import "HexaphoneAppDelegate.h"
#import "RecordingPlayer.h"
#import "RecordingManager.h"
#import "Recording.h"
#import "AppStateManager.h"
#import "AppState.h"
#import "RecViewController.h"
#import "Reachability.h"
#import "SBJSON.h"

#import "UIConstants.h"

@implementation RecPickerViewController

@synthesize appDelegate;

- (id)init  {
    if (self = [super initWithStyle:UITableViewStylePlain]) {
//		NSLog(@"RPVC: init");
		[self initializeFeaturedRecordings];
		
    }
    return self;
}

-(void) initializeFeaturedRecordings {
	arrFeaturedRecordings = [[NSMutableArray alloc] init];
	
	{
		NSMutableDictionary* recEntry = [[NSMutableDictionary alloc] init];
		[recEntry setObject:@"Bassline Practice" forKey:@"name"];
		[recEntry setObject:@"Bassline Practice.hexrec" forKey:@"url"];
		[arrFeaturedRecordings addObject:recEntry];
	}

	{
		NSMutableDictionary* recEntry = [[NSMutableDictionary alloc] init];
		[recEntry setObject:@"Blues Jam" forKey:@"name"];
		[recEntry setObject:@"Blues Jam.hexrec" forKey:@"url"];
		[arrFeaturedRecordings addObject:recEntry];
	}

	{
		NSMutableDictionary* recEntry = [[NSMutableDictionary alloc] init];
		[recEntry setObject:@"Reggae Jam" forKey:@"name"];
		[recEntry setObject:@"Reggae Jam.hexrec" forKey:@"url"];
		[arrFeaturedRecordings addObject:recEntry];
	}
	
//	Reachability *r = [Reachability reachabilityWithHostName:@"hexaphone.com"];
//	NetworkStatus internetStatus = [r currentReachabilityStatus];
//	if(internetStatus == ReachableViaWiFi || internetStatus == ReachableViaWWAN) {
//		
//		NSURL *url = [[NSURL alloc] initWithString:@"http://hexaphone.com/rec/featured.json"];
//		
//		NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:url];
//		[req setHTTPMethod:@"GET"];
//		[req setTimeoutInterval:3.0f]; // 3 second timeout
//		
//		NSHTTPURLResponse* response = nil;  
//		NSError* error = [[NSError alloc] init];  
//		NSData *responseData = [NSURLConnection sendSynchronousRequest:req   
//													 returningResponse:&response  
//																 error:&error];  
//		if(responseData != nil) {
//			NSLog(@"RPVC: Requesting featured recordings... done.");
//			NSString *result = [[NSString alloc] initWithData:responseData 
//													 encoding:NSUTF8StringEncoding];
//			
//			if (result != nil && response != nil && [response statusCode] >= 200 && [response statusCode] < 300) {
//				
//				SBJSON* sbJson = [[SBJSON alloc] init];
//				NSArray* arrJson = [sbJson objectWithString:result error:nil];
//
//				for(NSDictionary* entry in arrJson) {
//					[arrFeaturedRecordings addObject:entry];
//				}
//				
//				[sbJson release];
//			}
//			[result release];
//		}
//		[url release];
//		[req release];
//	}
	
}

-(void) show {
//	NSLog(@"RPVC: show");
	self.view.hidden = NO;
}

-(void) hide {
//	NSLog(@"RPVC: hide");
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
	
//	NSLog(@"RPVC: viewDidLoad BEGIN");
	
	tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	tableView.rowHeight = 100;
	tableView.backgroundColor = [UIColor clearColor];
	imageView.image = [UIImage imageNamed:@"picker-bg-large.png"];
	
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
	
	if(arrFeaturedRecordings != nil && [arrFeaturedRecordings count] > 0) {
		return 2;
	} else {
		return 1;
	}
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

	if(section == 0) {
		int numLocalRecordings = [[appDelegate.recordingManager getSavedRecordingFilenames] count];
		if(numLocalRecordings > 0) {
			return numLocalRecordings;
		} else {
			return 1; //placeholder 
		}
	} else {
		if(arrFeaturedRecordings != nil && [arrFeaturedRecordings count] > 0) {
			return [arrFeaturedRecordings count];
		} else {
			return 0;
		}

	}
}

#define kHeaderSectionHeight 20.0
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return kHeaderSectionHeight;
}

-(void) selectRecordingNamed:(NSString*) filenameParam {
	NSArray* filenames = [appDelegate.recordingManager getSavedRecordingFilenames];
	int row = 0;
	for(int i=0; i < [filenames count]; i++) {
		NSString* filename = (NSString*) [filenames objectAtIndex:i];
		if([filename isEqualToString:filenameParam]) {
			row = i;
			break;
		}
	}
	
	NSLog(@"RPVC: selectRecordingNamed: %@ : picking row %d", filenameParam, row);
	[self tableView:appDelegate.recPickerViewController.tableView
						  willSelectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	// create the parent view that will hold header Label
	UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 300.0, kHeaderSectionHeight)];
	//	customView.backgroundColor = [UIColor darkGrayColor];
	
	UIImageView* bgView = [[[UIImageView alloc] init] autorelease];
	bgView.image = [UIImage imageNamed:@"picker-bg-large.png"];
	bgView.frame = CGRectMake(0, 0, UI_LOOPPICKERVC_WIDTH, 20);
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
	
	if(section == 0) {
		headerLabel.text = @"My Recordings";
	} else {
		headerLabel.text = @"Featured Recordings";

	}
	[customView addSubview:headerLabel];
	[headerLabel release];
	
	
	return [customView autorelease];
}


//
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//	
//	if(section == 0 && [appDelegate.appStateManager.appState hasAnyRecentLoops]) {
//		return @"Recently Used Loops";
//	} else if(section == 1) {
//		return @"All Loops";
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
	cell.textLabel.textColor = UIColorFromRGB(0xFFdbe8ff);
	cell.textLabel.font = [UIFont boldSystemFontOfSize:15];
	cell.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"picker-bg-large.png"]];
	cell.backgroundView = [[[UIImageView alloc] initWithFrame:CGRectMake(0,0,40,40)] autorelease];
	((UIImageView *)cell.backgroundView).image = [UIImage imageNamed:@"picker-bg-large.png"];
	((UIImageView *)cell.backgroundView).frame = CGRectMake(0, 0, 104, 20);

	
	
	
//	if(indexPath.section == 0 && [appDelegate.appStateManager.appState hasAnyRecentLoops]) { // recent
//		loop = [self getRecentLoop:indexPath.row];
//	} else { // all
//		
//		int categoryNum = indexPath.section;
//		if([appDelegate.appStateManager.appState hasAnyRecentLoops]) categoryNum--;
//		
//		NSString* loopCategory = [appDelegate.loopManager.loopCategories objectAtIndex:categoryNum];
//		
//		loop = [[appDelegate.loopManager getLoopsByCategory:loopCategory] objectAtIndex:indexPath.row];
//	}
	
	if(indexPath.section == 0) {
		int numLocalRecordings = [[appDelegate.recordingManager getSavedRecordingFilenames] count];
		if(numLocalRecordings == 0) {
			cell.textLabel.text = @"(No Recordings Found)";
		} else {
			NSArray* arrFileNames = [appDelegate.recordingManager getSavedRecordingFilenames];
			NSString* recFileName = [arrFileNames objectAtIndex:indexPath.row];
			cell.textLabel.text = [recFileName substringWithRange:NSMakeRange(0, [recFileName length] - 7)];
		}
	} else {
		NSDictionary* dictFeaturedRec = [arrFeaturedRecordings objectAtIndex:indexPath.row];
		cell.textLabel.text = [dictFeaturedRec objectForKey:@"name"];
		
	}
	
    // Set up the cell...
	
    return cell;
}



//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    // Navigation logic may go here. Create and push another view controller.
//	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
//	// [self.navigationController pushViewController:anotherViewController];
//	// [anotherViewController release];
//}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[appDelegate.recordingPlayer stop];
	if(indexPath.section == 0) {
		int numLocalRecordings = [[appDelegate.recordingManager getSavedRecordingFilenames] count];
		if(numLocalRecordings == 0) {
			[self hide];
			return nil;
		}
		NSString* recFileName = [[appDelegate.recordingManager getSavedRecordingFilenames] objectAtIndex:indexPath.row];

		NSArray* systemDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
		NSString* documentsDirectory = [systemDirectories objectAtIndex:0];  
		NSString* recordingFilePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, recFileName];
		
		[appDelegate.recordingPlayer loadRecordingFromURL:[NSURL fileURLWithPath:recordingFilePath] reloadInstrument:YES indicateModified:NO];
	} else {
		NSDictionary* dictFeaturedRec = [arrFeaturedRecordings objectAtIndex:indexPath.row];
		NSString *fileName = [dictFeaturedRec objectForKey:@"url"];
		NSString *urlAddress = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
		NSURL *url = [NSURL fileURLWithPath:urlAddress];
		
//		[appDelegate.recordingPlayer loadRecordingFromURL:[NSURL URLWithString:[dictFeaturedRec objectForKey:@"url"]] reloadInstrument:YES indicateModified:NO];
		[appDelegate.recordingPlayer loadRecordingFromURL:url reloadInstrument:YES indicateModified:NO];
		
		
	}
	[appDelegate.recordingPlayer performSelector:@selector(togglePlayback) 
						  withObject:nil 
						  afterDelay:0.5];
	//[appDelegate.recordingPlayer loadRecordingPatchAndLoopFromFilename:recFileName];

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