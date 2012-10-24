//
//  AppsTableView.m
//	MAPI-AudioCopyPaste
//
//  Copyright 2009 Sonoma Wire Works and Retronyms. All rights reserved.
//


#import "AppsTableView.h"
#import "SimpleSettingCell.h"


@implementation AppsTableView
@synthesize delegate;
@synthesize appList = mAppList;
@synthesize showPasteApps = mShowPasteApps;
@synthesize showCopyApps = mShowCopyApps;
@synthesize showCopyPasteImages = mShowCopyPasteImages;

- (id)initWithCoder:(NSCoder*)coder
{
	if(self = [super initWithCoder:coder])
	{
		// initialization code
		self.showCopyApps = YES;
		self.showPasteApps = YES;
		self.showCopyPasteImages = YES;
		
		UIImage *cellBkg = [UIImage imageNamed:@"ac_apps_rowblue01.png"];
		
		CGRect frame = self.bounds;
		frame.origin.y += 1;
		frame.size.height -= 2;
		mTableView = [[UITableView alloc] initWithFrame:frame];
		mTableView.delegate = self;
		mTableView.dataSource = self;
		mTableView.backgroundColor = [UIColor clearColor];
		mTableView.bounces = NO;
		mTableView.showsVerticalScrollIndicator = NO;
		mTableView.rowHeight = cellBkg.size.height;
		[self addSubview:mTableView];
		[mTableView reloadData];
		[mTableView release];
		
		// Create app store section header
		UIImageView *hdbkg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ac_apps_headerblue.png"]];
		UIImageView *hdicon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"audiocopypaste_appstore_mini.png"]];
		hdicon.frame = CGRectMake(8, (hdbkg.frame.size.height - hdicon.frame.size.height)/2, hdicon.frame.size.width, hdicon.frame.size.height);
		UILabel *hdlabel = [[UILabel alloc] initWithFrame:CGRectMake(37, 4, hdbkg.frame.size.width - 32, hdbkg.frame.size.height - 8)];
		hdlabel.text = @"Compatible apps at the App Store";
		hdlabel.textColor = [UIColor colorWithRed:0.0f/255 green:126.0f/255 blue:255.0f/255 alpha:1.0f];
		hdlabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
		hdlabel.shadowColor = [UIColor whiteColor];
		hdlabel.font = [UIFont boldSystemFontOfSize:12];
		hdlabel.backgroundColor = [UIColor clearColor];
		
		mAppStoreSectionHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, hdbkg.frame.size.width,hdbkg.frame.size.height)];
		[mAppStoreSectionHeader addSubview:hdbkg];
		[mAppStoreSectionHeader addSubview:hdicon];
		[mAppStoreSectionHeader addSubview:hdlabel];
		[hdbkg release];
		[hdicon release];
		[hdlabel release];
		
		self.backgroundColor = [UIColor clearColor];
		
		// Set the content for the app table views
		CompatibleApps *ca = [CompatibleApps sharedInstance];
		ca.delegate = self;
		if ([CompatibleApps sharedInstance].ready)
		{
			self.appList = [CompatibleApps sharedInstance].compatibleApps;
		}		

		// Determine the app's URL scheme
		NSDictionary* info = [[NSBundle mainBundle] infoDictionary];
		NSArray* urlSchemes = (NSArray*)[[(NSArray*)[info objectForKey:@"CFBundleURLTypes"] objectAtIndex:0] objectForKey:@"CFBundleURLSchemes"];
		if([urlSchemes count] > 0)
			mURLScheme = [[urlSchemes objectAtIndex:0] retain];
		else
			mURLScheme = @"";
		
		//NSLog(@"app url scheme = %@", mURLScheme);

	}
	return self;
}


- (id)initWithFrame:(CGRect)frame
{
	if(self = [super initWithFrame:frame])
	{
		// initialization code
	}
	return self;
}

- (void)dealloc
{
	[mAppStoreSectionHeader release];
	self.appList = nil;
	[super dealloc];
}

- (void)setFrame:(CGRect)frame
{
	
	[super setFrame:frame];

	CGRect tbframe = self.bounds;
	tbframe.origin.y += 1;
	tbframe.size.height -= 2;
	
	mTableView.frame = tbframe; 
}

- (void)setAppList:(NSArray*)list
{
	if(list != nil)
	{
		mAppList = [list retain];
		[mTableView reloadData];
	}
}

- (void)drawRect:(CGRect)rect
{
	[super drawRect:rect];
	
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1);
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:152.0f/255 green:152.0f/255 blue:152.0f/255 alpha:1.0f].CGColor);

	CGPoint points[4] = {
		CGPointMake(0, 0), CGPointMake(rect.size.width, 0),
		CGPointMake(0, rect.size.height), CGPointMake(rect.size.width, rect.size.height)
	};
	
	CGContextStrokeLineSegments(context, points, 4);
}

- (void)reloadData
{
	[mTableView reloadData];
}

#pragma mark CompatibleAppsDelegate
-(void)compatibleAppsRefreshed
{
	self.appList = [CompatibleApps sharedInstance].compatibleApps;
	[mTableView reloadData];
}


#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	[delegate appWasSelected:indexPath.row inSection:indexPath.section fromTable:self];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	if(section == 0)
		return 0;
	else
	{
		if([[CompatibleApps sharedInstance].nonInstalledApps count] <= 0)
			return 0;
		else
			return mAppStoreSectionHeader.frame.size.height;
	}
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	return mAppStoreSectionHeader;
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

	if (!mShowPasteApps)
	{
		if(section == 0)
			return [[CompatibleApps sharedInstance].installedCopyApps count];
		else 
			return [[CompatibleApps sharedInstance].nonInstalledCopyApps count];
	}
	else if (!mShowCopyApps)
	{
		if(section == 0)
			return [[CompatibleApps sharedInstance].installedPasteApps count];
		else 
			return [[CompatibleApps sharedInstance].nonInstalledPasteApps count];
	}
	else
	{
		if(section == 0)
			return [[CompatibleApps sharedInstance].installedApps count];
		else 
			return [[CompatibleApps sharedInstance].nonInstalledApps count];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	SimpleSettingCell *cell = (SimpleSettingCell*)[tableView dequeueReusableCellWithIdentifier:@"SimSettingIdentifier"];
	if (!cell) {
		cell = [[SimpleSettingCell create] autorelease];
	}
	
	NSDictionary *dict;
	if (!mShowPasteApps)
	{
		if(indexPath.section == 0)
			dict = [[CompatibleApps sharedInstance].installedCopyApps objectAtIndex:indexPath.row];	
		else
			dict = [[CompatibleApps sharedInstance].nonInstalledCopyApps objectAtIndex:indexPath.row];	
	}
	else if (!mShowCopyApps)
	{
		if(indexPath.section == 0)
			dict = [[CompatibleApps sharedInstance].installedPasteApps objectAtIndex:indexPath.row];	
		else
			dict = [[CompatibleApps sharedInstance].nonInstalledPasteApps objectAtIndex:indexPath.row];	
	}
	else
	{
		if(indexPath.section == 0)
			dict = [[CompatibleApps sharedInstance].installedApps objectAtIndex:indexPath.row];	
		else
			dict = [[CompatibleApps sharedInstance].nonInstalledApps objectAtIndex:indexPath.row];	
	}
	
	NSNumber *isInstalled = (NSNumber*)[dict valueForKey:@"isInstalled"];
	NSNumber *canCopy = (NSNumber*)[dict valueForKey:@"canCopy"];
	NSNumber *canPaste = (NSNumber*)[dict valueForKey:@"canPaste"];
	NSString *urlScheme = (NSString*)[dict valueForKey:@"URLScheme"];
	
	cell.name.text = [dict valueForKey:@"name"];
//	cell.status.text = [isInstalled boolValue] ? @"Installed" : @"At the App Store";
//	cell.accessoryView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"audiocopypaste_chev.png"]] autorelease];
	
	
	if([isInstalled boolValue])
	{
		if(indexPath.row % 2 == 0)
			cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ac_apps_rowyellow01.png"]] autorelease];
		else
			cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ac_apps_rowyellow02.png"]] autorelease];
	}
	else 
	{
		if(indexPath.row % 2 == 0)
			cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ac_apps_rowblue01.png"]] autorelease];
		else
			cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ac_apps_rowblue02.png"]] autorelease];
	}
	
	cell.supportedImage1.image = nil;
	cell.supportedImage2.image = nil;
	if(self.showCopyPasteImages)
	{
		if([canCopy boolValue])
		{
			cell.supportedImage1.image = [UIImage imageNamed:@"miniicon_audiocopy.png"];
			if([canPaste boolValue])
				cell.supportedImage2.image = [UIImage imageNamed:@"miniicon_audiopaste.png"];
		}
		else if([canPaste boolValue])
		{
			cell.supportedImage1.image = [UIImage imageNamed:@"miniicon_audiopaste.png"];
		}
	}
	cell.appIcon.image = [dict objectForKey:@"icon"];
	
	// Set the action image
	if([urlScheme compare:mURLScheme] == NSOrderedSame)
		cell.actionImage.image = [UIImage imageNamed:@"btn_apps_running_idle.png"];
	else if([isInstalled boolValue])
		cell.actionImage.image = [UIImage imageNamed:@"btn_apps_launch_idle.png"];
	else 
		cell.actionImage.image = [UIImage imageNamed:@"btn_apps_shop_idle.png"];
	
	return cell;
}

@end
