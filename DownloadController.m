/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import "DownloadController.h"

#import "DownloadObject.h"
#import "BezelController.h"
#import "BezelWindow.h"
#import "NSFileManagerSGSAdditions.h"


NSString* kDownloadWindowNibName			= @"Downloads";

NSString* defaultDownloadSaveDestination	= @"~/Desktop";
NSString* downloadFileWrapperExtension		= @"download";

@implementation DownloadController


- (id) init
{
	if (self = [super initWithWindowNibName: kDownloadWindowNibName])
	{
		// holds all download objects
		mDownloads			= [[NSMutableArray alloc] init];
		
		// displays when a download is complete
		mBezelController	= [[BezelController alloc] init];
		
		// number of downloads unfinished
		mNumloads			= 0;
		
		// number of downloads finished
		mNumloadsfinished	= 0;
		
		// font of table cells
		mTableCellFont		= [[NSFont systemFontOfSize: 12.0] retain];
		
		// register for notifications
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(handleNotification:) name: @"DBDownloadNotification" object: nil];
		
		// disable toolbar items
		mAllowClearButton			= NO;
		mAllowCancelButton			= NO;
		mAllowCancelAllButton		= NO;
		mAllowShowInFinderButton	= NO;
	}
	
	return self;
}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	
	[mDownloads release];
	[mBezelController release];
	[mTableCellFont release];
	
	[super dealloc];
}

- (void) awakeFromNib
{
	[mDownloadTableView setTarget: self];
	[mDownloadTableView setDoubleAction: @selector(tableViewDoubleClick)];
}


#pragma mark -

#pragma mark Interface

- (IBAction) clearDownloads: (id) sender
{
	NSMutableArray*	downloadsToRemove	= [NSMutableArray array];
	
	NSEnumerator*	downloadEnumerator	= [mDownloads objectEnumerator];
	DownloadObject*	currentDownload		= nil;
	
	while ((currentDownload = [downloadEnumerator nextObject]) != nil)
	{
		if ([currentDownload status] != kDownloadStatusDownloading)
		{
			[downloadsToRemove addObject: currentDownload];
		}
	}
	
	[mDownloads removeObjectsInArray: downloadsToRemove];
	
	mNumloads			= 0;
	mNumloadsfinished	= 0;
	
	// Adjust toolbar items
	mAllowClearButton		= NO;
	mAllowShowInFinderButton	= NO;
	
	// [[downloadWindow toolbar] validateVisibleButtons];
	[mDownloadTableView reloadData];
	
}

- (IBAction) cancelSelected: (id) sender
{
	if (mDownloadTableView != nil)
	{
		int				row		= [mDownloadTableView selectedRow];
		DownloadObject*	object	= nil;

		if (row > -1 && row < [mDownloads count]) // a row is selected
		{
			object = [mDownloads objectAtIndex: row];
			
			if ([object status] == kDownloadStatusDownloading)
			{
				[object cancel];
				
				mNumloads--;
				mNumloadsfinished++;
			
				// Adjust toolbar items
				mAllowClearButton		= YES;
				mAllowCancelButton		= NO;
				mAllowShowInFinderButton	= NO;
				
				// [[downloadWindow toolbar] validateVisibleButtons];
				[mDownloadTableView reloadData];
			}
		}
	}
}

- (IBAction) cancelAllDownloads: (id) sender
{
	NSAlert *msg = [NSAlert alertWithMessageText: @"Alert!" defaultButton: @"Yes" alternateButton: @"No" otherButton: nil informativeTextWithFormat: @"Are you sure you want to cancel all active downloads?"];
	[msg beginSheetModalForWindow: [self window] modalDelegate: self didEndSelector: @selector(alertDidEnd:returnCode:contextInfo:) contextInfo: nil];
}

- (void) alertDidEnd: (NSAlert*) alert returnCode: (int) returnCode contextInfo: (void*) contextInfo
{
	if (returnCode == NSOKButton)
	{
		NSEnumerator*	downloadEnumerator	= [mDownloads objectEnumerator];
		DownloadObject*	currentObject		= nil;
		
		while ((currentObject = [downloadEnumerator nextObject]) != nil)
		{
			if ([currentObject status] == kDownloadStatusDownloading)
			{
				[currentObject cancel];
				
				mNumloadsfinished++;
				mNumloads--;
			}
		}
		
		// Adjust toolbar items
		mAllowCancelAllButton	= NO;
		mAllowCancelButton	= NO;
		mAllowClearButton	= YES;
		
		// [[downloadWindow toolbar] validateVisibleButtons];
		[mDownloadTableView reloadData];
	}
}

- (IBAction) showDownloadInFinder: (id) sender
{
	if (mDownloadTableView != nil)
	{
		int row = [mDownloadTableView selectedRow];
		
		if (row > -1 && row < [mDownloads count])
		{
			NSString* filePath = [[mDownloads objectAtIndex: row] downloadedFilePath];
			
			if ([[NSFileManager defaultManager] fileExistsAtPath: filePath])
			{
				[[NSWorkspace sharedWorkspace] selectFile: filePath inFileViewerRootedAtPath: NSHomeDirectory()];
			}
		}
	}
}

- (int) downloadsInProgress
{
	return mNumloads;
}

#pragma mark -

#pragma mark NSTableView Methods

#pragma mark -

- (void) tableViewDoubleClick
{
	int row = [mDownloadTableView selectedRow];
	
	if (row > -1 && row < [mDownloads count])
	{
		// Handle double click here
	}
}


#pragma mark -


- (int) numberOfRowsInTableView: (NSTableView*) tableView
{	
	return [mDownloads count];
}

- (id) tableView: (NSTableView*) tableView objectValueForTableColumn: (NSTableColumn*) column row: (int) row
{
	id				value		= nil;
	NSString*		identifier	= [column identifier];
	DownloadObject*	download	= [mDownloads objectAtIndex: row];

	if ([identifier isEqualToString: @"FileName"])
	{
		value = [download displayName];
	}
	else if ([identifier isEqualToString: @"Progress"])
	{
		value = [download stringStatus];
	}
	
	return value;
}

#pragma mark -

- (void) tableView: (NSTableView*) tableView willDisplayCell: (id) cell forTableColumn: (NSTableColumn*) tableColumn row: (int) row
{
	[(NSCell*)cell setFont: [NSFont systemFontOfSize: 10.0]];
}

#pragma mark -

#pragma mark NSURLDownload Delegate Methods


// -----------------------------------
//
// NSURLDownload delegate methods
//
// -----------------------------------


- (void) download: (NSURLDownload*) download decideDestinationWithSuggestedFilename: (NSString*) fileName
{	
	NSString*		finalDestination		= nil;
	
	DownloadObject*	object				= [self objectWithDownload: download];
	NSFileManager*	fileManager			= [NSFileManager defaultManager];
	NSString*		saveLocation		= [[[NSUserDefaults standardUserDefaults] objectForKey: kDownloadLocation] stringByExpandingTildeInPath];
	NSString*       fileWrapperPath		= nil;
	
	if (![fileManager fileExistsAtPath: saveLocation])
	{
		saveLocation = [defaultDownloadSaveDestination stringByExpandingTildeInPath];
	}
	
	fileWrapperPath		= [saveLocation stringByAppendingPathComponent: fileName];
	fileWrapperPath		= [fileWrapperPath stringByAppendingPathExtension: downloadFileWrapperExtension];
	fileWrapperPath		= [fileManager uniqueFilePath: fileWrapperPath];
	finalDestination	= [fileWrapperPath stringByAppendingPathComponent: fileName];
	
	[fileManager createDirectoryAtPath: fileWrapperPath attributes: nil];
	
	NSFileWrapper*  fileWrapper = [[NSFileWrapper alloc] initWithPath: fileWrapperPath];
	
	if (![fileWrapper writeToFile: fileWrapperPath atomically: YES updateFilenames: NO])
	{
	}
	
	if (fileWrapperPath != nil)
	{
		[download setDestination: finalDestination allowOverwrite: NO];
		[object setDisplayName: fileName];
	}
}

- (void) download: (NSURLDownload*) download didCancelAuthenticationChallenge: (NSURLAuthenticationChallenge*) challenge
{
	//
}

- (void) download: (NSURLDownload*) download didCreateDestination: (NSString*) path
{
	[[self objectWithDownload: download] setDownloadedFilePath: path];
}

- (void) download: (NSURLDownload*) download didFailWithError: (NSError*) error
{
	//
}

- (void) download: (NSURLDownload*) download didReceiveAuthenticationChallenge: (NSURLAuthenticationChallenge*) challenge
{
	//
}

- (void) download: (NSURLDownload*) download didReceiveDataOfLength: (unsigned) length
{
	DownloadObject*	object = [self objectWithDownload: download];
	
	[object setBytesLoaded: ([object bytesLoaded] + length)];
	
	if ([NSDate timeIntervalSinceReferenceDate] >= mLastUpdate + 1) // if it has been more than 1 second since last reload
	{
		if (mDownloadTableView != nil)
		{
			[mDownloadTableView reloadData];
			mLastUpdate = [NSDate timeIntervalSinceReferenceDate];
		}
	}
}

- (void) download: (NSURLDownload*) download didReceiveResponse: (NSURLResponse*) response
{
	DownloadObject* object = [self objectWithDownload: download];
	
    [object setBytesLoaded: 0];
    [object setURLResponse: response];
}

- (BOOL) download: (NSURLDownload*) download shouldDecodeSourceDataOfMIMEType: (NSString*) encodingType
{
	return NO;
}

- (NSURLRequest*) download: (NSURLDownload*) download willSendRequest: (NSURLRequest*) request redirectResponse: (NSURLResponse*) redirectResponse
{
	DownloadObject* downloadObject	= [self objectWithDownload: download];
	[downloadObject setURLRequest: request];
	
	[mDownloadTableView reloadData];
	
	return request;
}

- (void) downloadDidBegin: (NSURLDownload*) download
{
	DownloadObject* downloadObject = [self objectWithDownload: download];
	
	[downloadObject setStatus: kDownloadStatusDownloading];
	
	// Adjust toolbar items
	mAllowCancelAllButton = YES;
	
	// [[downloadWindow toolbar] validateVisibleButtons];
	[mDownloadTableView reloadData];
}

- (void) downloadDidFinish: (NSURLDownload*) download
{	
	DownloadObject*		downloadObject			= [self objectWithDownload: download];
	NSString*			downloadedFilePath		= [downloadObject downloadedFilePath];
	NSString*			nameOfDownloadedFile	= [downloadedFilePath lastPathComponent];
	NSWorkspace*		workspace				= [NSWorkspace sharedWorkspace];
	NSFileManager*		fileManager				= [NSFileManager defaultManager];
	
	NSString*			parentDirectory		= [downloadedFilePath stringByDeletingLastPathComponent];
	NSString*			parentExtension		= [parentDirectory pathExtension];
	
	if ([parentExtension isEqualToString: downloadFileWrapperExtension])
	{
		NSString* newDownloadedFilePath = [parentDirectory stringByDeletingLastPathComponent];
		newDownloadedFilePath			= [newDownloadedFilePath stringByAppendingPathComponent: nameOfDownloadedFile];
		newDownloadedFilePath			= [fileManager uniqueFilePath: newDownloadedFilePath];
		
		if ([fileManager movePath: downloadedFilePath toPath: newDownloadedFilePath handler: nil])
		{
			[downloadObject setDownloadedFilePath: newDownloadedFilePath];
			
			[fileManager removeFileAtPath: parentDirectory handler: nil];
		}
	}
	
	[downloadObject setStatus: kDownloadStatusFinished];
	
	mNumloadsfinished++;
	mNumloads--;

	[mBezelController showBezelForFile: [downloadObject displayName]];
	
	// adjust toolbar items
	mAllowClearButton			= YES;
	mAllowShowInFinderButton	= NO;
	mAllowCancelButton			= NO;
	
	if (mNumloads <= 0)
	{
		mAllowCancelAllButton = NO;
	}
	else
	{
		mAllowCancelAllButton = YES;
	}
	
	if (mNumloadsfinished <= 0)
	{
		mAllowClearButton = NO;
	}
	else
	{
		mAllowClearButton = YES;
	}
	
	[mDownloadTableView reloadData];
}


- (void) download: (NSURLDownload*) download willResumeWithResponse: (NSURLResponse*) response fromByte: (long long) startingByte
{
	//
}


#pragma mark -

#pragma mark Other Methods

// -----------------------------------
//
// Other methods
//
// -----------------------------------

- (DownloadObject*) objectWithDownload: (NSURLDownload*) download
{
	DownloadObject*	downloadObject	= nil;
	
	NSEnumerator*	downloadEnumerator	= [mDownloads objectEnumerator];
	DownloadObject*	currentObject		= nil;
	
	while ((currentObject = [downloadEnumerator nextObject]) != nil && downloadObject == nil)
	{
		if ([currentObject URLDownload] == download)
		{
			downloadObject = currentObject;
		}
	}
	
	return downloadObject;
}

- (void) prepareForDownloadWithRequest: (NSURLRequest*) aRequest
{
	WebDownload*	download		= [[WebDownload alloc] initWithRequest: aRequest delegate: self];
	DownloadObject*	downloadObject	= [[DownloadObject alloc] initWithURLDownload: download];
	
	[mDownloads addObject: downloadObject];
	
	[download release];
	[downloadObject release];
	
	mNumloads++;
	
	[mDownloadTableView reloadData];
}

- (void) handleNotification: (NSNotification*) note
{
	NSString* type = [[note userInfo] objectForKey: @"notificationType"];
	
	if ([type isEqualToString: @"beginDownload"])
	{
		NSURL*			tURL			= [[note userInfo] objectForKey: @"fileURL"];
		WebDownload*	download		= [[WebDownload alloc] initWithRequest: [NSURLRequest requestWithURL: tURL] delegate: self];
		DownloadObject*	downloadObject	= [[DownloadObject alloc] initWithURLDownload: download];
		
		[mDownloads addObject: downloadObject];
		
		[download release];
		[downloadObject release];
		
		mNumloads++;
		
		[mDownloadTableView reloadData];
	}
	else if ([type isEqualToString:@"showDownloadWindow"])
	{
		NSLog(@"Find the sender and eliminate: NSNotification-showDownloadWindow");
	}
}

- (BOOL) deskBrowseShouldTerminate
{
	BOOL terminate = YES;
	
	if (mNumloads > 0)
	{
		NSString* alertMessage = [NSString stringWithFormat: @"%i", mNumloads];
		
		if (mNumloads == 1)
		{
			alertMessage = [NSString stringWithFormat:@"%@ download", alertMessage];
		}
		else
		{
			alertMessage = [NSString stringWithFormat:@"%@ downloads", alertMessage];
		}
		
		NSAlert* downloadAlert = [NSAlert alertWithMessageText: @"Downloads in Progress"
										defaultButton: @"No"
									  alternateButton: @"Yes"
										  otherButton: nil
							informativeTextWithFormat: @"You have %@ in progress.  Quitting will stop all downloads.  Do you still want to quit?", alertMessage];
		
		int response = [downloadAlert runModal];
		
		if (response == NSOKButton)
		{
			terminate = NO;
		}
	}
	
	return terminate;
}


@end
