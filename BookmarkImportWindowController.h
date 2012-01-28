/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import <Cocoa/Cocoa.h>

#import "BookmarkController.h"
#import "BookmarkImporter.h"


@interface BookmarkImportWindowController : NSWindowController
{
	IBOutlet NSButton*				mDoneButton;
	IBOutlet NSButton*				mImportButton;
	IBOutlet NSButton*				mSortBookmarksButton;
	IBOutlet NSPopUpButton*			mOtherBrowsersPopUpButton;
	IBOutlet NSProgressIndicator*	mImportingProgressIndicator;
	IBOutlet NSTextField*			mStatusTextField;
	
	BookmarkController*				mBookmarkController;
}

- (id) initWithWindowNibName: (NSString*) windowNibName bookmarkController: (BookmarkController*) bookmarkController;
- (IBAction) importBookmarksFromSelectedBrowser: (id) sender;
- (void) importBookmarksFromSelectedBrowserInNewThread;
- (void) populatePopUpButtonWithOtherBrowsers: (NSPopUpButton*) popUpButton;

@end