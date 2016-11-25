//
//  CompatibleApps.m
//	MAPI - AudioCopyPaste
//
//  Copyright 2009 Sonoma Wire Works and Retronyms. All rights reserved.
//

#import "CompatibleApps.h"
#import "ASIHTTPRequest.h"

@interface CompatibleApps ()
- (void)parseApps;
@end

@implementation CompatibleApps
@synthesize compatibleApps = mCompatibleApps;
@synthesize installedApps = mInstalledApps;
@synthesize installedCopyApps = mInstalledCopyApps;
@synthesize installedPasteApps = mInstalledPasteApps;
@synthesize nonInstalledApps = mNonInstalledApps;
@synthesize nonInstalledPasteApps = mNonInstalledPasteApps;
@synthesize nonInstalledCopyApps = mNonInstalledCopyApps;
@synthesize ready = mReady;
@synthesize readyFromNetwork = mReadyFromNetwork;
@synthesize delegate = mDelegate;

-(id)init
{
    if (self = [super init]) 
	{
        NSFileManager *fm = [NSFileManager defaultManager];
        NSArray  *paths	  = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);        
        mCompatibleAppsCachePath =  [NSString stringWithFormat:@"%@/CompatibleAppsCache", [paths objectAtIndex:0]];
        [mCompatibleAppsCachePath retain];
        NSString *iconPath = [NSString stringWithFormat:@"%@/icons/", mCompatibleAppsCachePath];
        [fm createDirectoryAtPath:iconPath withIntermediateDirectories:YES attributes:nil error:nil];
        
        mQueue = [[ASINetworkQueue alloc] init];
        
    }
    return self;
}
static CompatibleApps *sCompatibleApps= nil;
+(CompatibleApps *) sharedInstance
{
    if (sCompatibleApps==nil)
    {
        sCompatibleApps = [[CompatibleApps alloc] init];
    }
    return sCompatibleApps;
}
-(NSMutableArray *)addIconsAndDetectInstalledApps{
	NSMutableArray *apps = mCompatibleApps;
	// Determine if the app is installed, and load icons if not cached
	for (NSDictionary *app in apps)
	{
		NSString *appName = [app valueForKey:@"name"];
		//NSString *appStoreURL = [app valueForKey:@"appStoreURL"];
		NSString *urlscheme = [app valueForKey:@"URLScheme"];
		NSURL *url = [NSURL URLWithString: [urlscheme stringByAppendingString:@"://"]];
		
		// Set the installed flag
		[app setValue:[NSNumber numberWithBool: [[UIApplication sharedApplication] canOpenURL:url]] forKey:@"isInstalled"];
	    NSFileManager *fm = [NSFileManager defaultManager];
        NSString *iconPath = [NSString stringWithFormat:@"%@/icons/%@.png", mCompatibleAppsCachePath,appName];
        if ([fm fileExistsAtPath:iconPath])
        {
            UIImage *image = [[UIImage alloc] initWithContentsOfFile:iconPath];
            [app setValue:image forKey:@"icon"];
			[image release];
        }
        else
        {
            NSString *surl = [app objectForKey:@"iconURL"];
            if (surl)
            {
                mImageLoadCount ++;
                NSURL *url = [NSURL URLWithString:surl];
                ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
                [request setDelegate:self];
                [request setDidFinishSelector:@selector(imageLoaded:)];
                [request setDidFailSelector:@selector(imageFailed:)];
                [mQueue addOperation:request];
                [mQueue go];
            }
        }
    }
    return apps;
}

- (void)refreshFromCache
{
    if (mCompatibleApps)
        [mCompatibleApps release];
	NSString *plist = [NSString stringWithFormat:@"%@/compatible_apps.plist", mCompatibleAppsCachePath];
    mCompatibleApps = [[NSArray arrayWithContentsOfFile:plist] mutableCopy];
    mCompatibleApps = [self addIconsAndDetectInstalledApps];
	[self parseApps];
}

- (void)imageLoaded:(ASIHTTPRequest *)request
{
    NSLog(@"image loaded ok");
    mImageLoadCount --;
    for (int i=0;i<[mCompatibleApps count];i++)
    {
        NSDictionary *dict = [mCompatibleApps objectAtIndex:i];
        NSString *iconURL = [dict objectForKey:@"iconURL"];
        
        if ([iconURL isEqualToString:request.url.absoluteString])
        {
            //write to file
            NSString *appName = [(NSDictionary*)[mCompatibleApps objectAtIndex:i] valueForKey:@"name"];
            NSString *iconPath = [NSString stringWithFormat:@"%@/icons/%@.png", mCompatibleAppsCachePath,appName];
            [[request responseData] writeToFile:iconPath atomically:YES];
            //load
            UIImage *image = [[UIImage alloc] initWithContentsOfFile:iconPath];
            [(NSMutableDictionary*)[mCompatibleApps objectAtIndex:i] setValue:image forKey:@"icon"];
			[image release];
        }
    }
    if (mImageLoadCount==0)
    {
        NSFileManager *fm = [NSFileManager defaultManager];
        NSError *error = nil;
        [fm copyItemAtPath:[NSString stringWithFormat:@"%@/compatible_apps.plist.tmp", mCompatibleAppsCachePath] toPath:[NSString stringWithFormat:@"%@/compatible_apps.plist", mCompatibleAppsCachePath] error:&error];
        [self refreshFromCache];
        mReadyFromNetwork = YES;
        mReady = YES;
        [mDelegate compatibleAppsRefreshed];
    }
}

- (void)imageFailed:(ASIHTTPRequest *)request
{    
    NSError *error = [request error];
    NSLog(@"image download failed: %@ %@", 
          [error localizedDescription], 
          [[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
    
    [self refreshFromCache];
    mReadyFromNetwork = NO;
    mReady = YES;
    [mDelegate compatibleAppsRefreshed];
}

- (void)requestDone:(ASIHTTPRequest *)request
{
    NSData *response = [request responseData];
    //write to temp file and turn 
	NSString *temp = [NSString stringWithFormat:@"%@/compatible_apps.plist.tmp", mCompatibleAppsCachePath];
    [response writeToFile:temp atomically:YES];
    if (mCompatibleApps)
        [mCompatibleApps release];
    mCompatibleApps =  [[NSArray arrayWithContentsOfFile:temp] mutableCopy];
    mCompatibleApps = [self addIconsAndDetectInstalledApps];
    if (mImageLoadCount==0)
    {
        //write to cache
        NSFileManager *fm = [NSFileManager defaultManager];
        NSError *error = nil;
		[fm removeItemAtPath:[NSString stringWithFormat:@"%@/compatible_apps.plist", mCompatibleAppsCachePath] error:nil];
        [fm copyItemAtPath:temp toPath:[NSString stringWithFormat:@"%@/compatible_apps.plist", mCompatibleAppsCachePath] error:&error];
        //load from cache
        [self refreshFromCache];

		// parse into installed vs non-installed
		[self parseApps];

		mReadyFromNetwork = YES;
        mReady = YES;    
		[mDelegate compatibleAppsRefreshed];
    }	
}

- (void)requestWentWrong:(ASIHTTPRequest *)request
{
    [self refreshFromCache];
    NSError *error = [request error];
    NSLog(@"plist download failed: %@ %@", 
          [error localizedDescription], 
          [[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
    mReadyFromNetwork = NO;
    mReady = YES;
    [mDelegate compatibleAppsRefreshed];
}

- (void)refresh
{
    //make network request
    NSURL *url = [NSURL URLWithString:@"http://www.sonomawireworks.com/iphone/mapi/compatible_apps.plist"];
    ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
    [request setDelegate:self];
    [mQueue setDelegate:self];
    [request setDidFinishSelector:@selector(requestDone:)];
    [request setDidFailSelector:@selector(requestWentWrong:)];
    [mQueue addOperation:request];
    [mQueue go];
}

- (void)parseApps
{
	[mInstalledApps release];
	[mNonInstalledApps release];
	[mInstalledCopyApps release];
	[mInstalledPasteApps release];
	[mNonInstalledPasteApps release];
	[mNonInstalledCopyApps release];	
	mInstalledApps = [[NSMutableArray alloc] initWithCapacity:0];
	mInstalledCopyApps = [[NSMutableArray alloc] initWithCapacity:0];
	mInstalledPasteApps = [[NSMutableArray alloc] initWithCapacity:0];
	mNonInstalledApps = [[NSMutableArray alloc] initWithCapacity:0];
	mNonInstalledPasteApps = [[NSMutableArray alloc] initWithCapacity:0];
	mNonInstalledCopyApps = [[NSMutableArray alloc] initWithCapacity:0];
	
	// Get my url scheme.
	NSString *my_url_scheme = @"";
	NSDictionary* info = [[NSBundle mainBundle] infoDictionary];
	NSArray *urlSchemes = (NSArray*)[[(NSArray*)[info objectForKey:@"CFBundleURLTypes"] objectAtIndex:0] objectForKey:@"CFBundleURLSchemes"];
	if([urlSchemes count] > 0)
		my_url_scheme = [urlSchemes objectAtIndex:0];
	
	NSDictionary *removeApp = nil;
	for(NSDictionary *app in mCompatibleApps)
	{
		if([[app valueForKey:@"URLScheme"] isEqualToString:my_url_scheme])
		{
			removeApp = app;
			continue;
		}
		
		NSNumber *isInstalled = (NSNumber*)[app valueForKey:@"isInstalled"];
		NSNumber *canCopy = (NSNumber*)[app valueForKey:@"canCopy"];
		NSNumber *canPaste = (NSNumber*)[app valueForKey:@"canPaste"];
		if([isInstalled boolValue])
		{
			[mInstalledApps addObject:app];
			if ([canCopy boolValue])
				[mInstalledCopyApps addObject:app];
			if ([canPaste boolValue])
				[mInstalledPasteApps addObject:app];
		}
		else
		{
			[mNonInstalledApps addObject:app];
			if ([canCopy boolValue])
				[mNonInstalledCopyApps addObject:app];
			if ([canPaste boolValue])
				[mNonInstalledPasteApps addObject:app];
		}
	}
	
	if(removeApp != nil)
		[mCompatibleApps removeObject:removeApp];
}

- (void)dealloc
{
	self.compatibleApps = nil;
	self.installedApps = nil;
	self.installedPasteApps = nil;
	self.installedCopyApps = nil;
	self.nonInstalledApps = nil;
	self.nonInstalledPasteApps = nil;
	self.nonInstalledCopyApps = nil;
	self.delegate = nil;
	[super dealloc];
}
@end

