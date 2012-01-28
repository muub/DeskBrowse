/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

#import "DeskBrowseConstants.h"

@class DownloadObject;
@class BezelController;
@class BezelWindow;
@class NSFileManagerSGSAdditions;


@interface DownloadController : NSWindowController
{
	IBOutlet NSTableView*	mDownloadTableView;
	
	BezelController*		mBezelController;
	
	NSFont*					mTableCellFont;
	NSMutableArray*			mDownloads;
	
	int						mNumloads;
	int						mNumloadsfinished;
	
	double					mLastUpdate;
	
	BOOL					mAllowClearButton;
	BOOL					mAllowCancelButton;
	BOOL					mAllowCancelAllButton;
	BOOL					mAllowShowInFinderButton;
}

- (void) prepareForDownloadWithRequest: (NSURLRequest*) aRequest;

- (IBAction) clearDownloads: (id) sender;
- (IBAction) cancelSelected: (id) sender;
- (IBAction) cancelAllDownloads: (id) sender;
- (IBAction) showDownloadInFinder: (id) sender;

- (void)handleNotification: (NSNotification*) note;
- (DownloadObject*) objectWithDownload: (NSURLDownload*) download;

- (void) tableViewDoubleClick;

- (int) downloadsInProgress;
- (BOOL) deskBrowseShouldTerminate;

@end