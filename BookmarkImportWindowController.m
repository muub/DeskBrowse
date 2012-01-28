/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import "BookmarkImportWindowController.h"

@class BookmarkController;
@class BookmarkImporter;


NSString*	kNameOfCaminoApp		= @"Camino";
NSString*	kNameOfFirefoxApp		= @"Firefox";
NSString*	kNameOfMozillaApp		= @"Mozilla";
NSString*	kNameOfSafariApp		= @"Safari";
NSString*	kNameOfShiiraApp		= @"Shiira";

NSString*	kNoStatus				= @"";
NSString*	kDoneImportingStatus	= @"Done";
NSString*	kImportingStatus		= @"Importing...";

@implementation BookmarkImportWindowController


- (id) initWithWindowNibName: (NSString*) windowNibName bookmarkController: (BookmarkController*) bookmarkController
{
	if (self = [super initWithWindowNibName: windowNibName])
	{
		if (![NSBundle loadNibNamed: windowNibName owner: self])
		{
			NSLog(@"Failed to load nib: %@", windowNibName);
		}
		
		mBookmarkController = [bookmarkController retain];
	}
	
	return self;
}

- (void) showWindow: (id) sender
{	
	[self populatePopUpButtonWithOtherBrowsers: mOtherBrowsersPopUpButton];
	
	[mStatusTextField setStringValue: kNoStatus];
	[mImportingProgressIndicator setDisplayedWhenStopped: NO];
	
	[super showWindow: sender];
}

- (IBAction) importBookmarksFromSelectedBrowser: (id) sender
{	
	[NSThread detachNewThreadSelector: @selector(importBookmarksFromSelectedBrowserInNewThread) toTarget: self withObject: nil];
}

- (void) importBookmarksFromSelectedBrowserInNewThread
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	BOOL		sortBookmarks			= [mSortBookmarksButton state];
	NSString*	nameOfSelectedBrowser	= [mOtherBrowsersPopUpButton titleOfSelectedItem];
	
	[mImportButton setEnabled: NO];
	[mDoneButton setEnabled: NO];
	
	[mStatusTextField setStringValue: kImportingStatus];
	
	[mImportingProgressIndicator startAnimation: nil];
	[mImportingProgressIndicator setDisplayedWhenStopped: YES];
	
	BookmarkImporter*	bookmarkImporter	= [BookmarkImporter bookmarkImporter];
	NSArray*			importedBookmarks	= nil;
	
	if ([nameOfSelectedBrowser isEqualToString: kNameOfCaminoApp])
	{
		importedBookmarks = [bookmarkImporter caminoBookmarksExcludingBookmarks: [mBookmarkController bookmarks]];
	}
	else if ([nameOfSelectedBrowser isEqualToString: kNameOfFirefoxApp])
	{
		importedBookmarks = [bookmarkImporter firefoxBookmarksExcludingBookmarks: [mBookmarkController bookmarks]];
	}
	else if ([nameOfSelectedBrowser isEqualToString: kNameOfMozillaApp])
	{
		importedBookmarks = [bookmarkImporter mozillaBookmarksExcludingBookmarks: [mBookmarkController bookmarks]];
	}
	else if ([nameOfSelectedBrowser isEqualToString: kNameOfSafariApp])
	{
		importedBookmarks = [bookmarkImporter safariBookmarksExcludingBookmarks: [mBookmarkController bookmarks]];
	}
	else if ([nameOfSelectedBrowser isEqualToString: kNameOfShiiraApp])
	{
		importedBookmarks = [bookmarkImporter shiiraBookmarksExcludingBookmarks: [mBookmarkController bookmarks]];
	}
	
	if (importedBookmarks != nil && [importedBookmarks count] > 0)
	{
		if (sortBookmarks)
		{
			importedBookmarks = [importedBookmarks sortedArrayUsingSelector: @selector(compare:)];
		}
		
		[mBookmarkController addBookmarks: importedBookmarks];
	}
	
	[mImportButton setEnabled: YES];
	[mDoneButton setEnabled: YES];
	
	[mImportingProgressIndicator stopAnimation: nil];
	
	[mStatusTextField lockFocus];
	[mStatusTextField setStringValue: kDoneImportingStatus];
	[mStatusTextField unlockFocus];
	
	[pool release];
}

- (void) populatePopUpButtonWithOtherBrowsers: (NSPopUpButton*) popUpButton
{
	NSWorkspace* workspace = [NSWorkspace sharedWorkspace];
	
	[popUpButton removeAllItems];
	
	
	// Add Camino if it exsits
	
	NSString* pathOfCamino = [workspace fullPathForApplication: kNameOfCaminoApp];
	
	if (pathOfCamino != nil)
	{
		[popUpButton addItemWithTitle: kNameOfCaminoApp];
		
		NSMenuItem* caminoMenuItem	= [popUpButton itemWithTitle: kNameOfCaminoApp];
		NSImage*	caminoIcon		= [workspace iconForFile: pathOfCamino];
		
		[caminoIcon setSize: NSMakeSize(16, 16)];
		[caminoMenuItem setImage: caminoIcon];
	}
	
	
	// Add Firefox if it exsits
	
	NSString* pathOfFirefox = [workspace fullPathForApplication: kNameOfFirefoxApp];
	
	if (pathOfFirefox != nil)
	{
		[popUpButton addItemWithTitle: kNameOfFirefoxApp];
		
		NSMenuItem* firefoxMenuItem	= [popUpButton itemWithTitle: kNameOfFirefoxApp];
		NSImage*	firefoxIcon		= [workspace iconForFile: pathOfFirefox];
		
		[firefoxIcon setSize: NSMakeSize(16, 16)];
		[firefoxMenuItem setImage: firefoxIcon];
	}
	
	
	// Add Mozilla if it exsits
	
	NSString* pathOfMozilla = [workspace fullPathForApplication: kNameOfMozillaApp];
	
	if (pathOfMozilla != nil)
	{
		[popUpButton addItemWithTitle: kNameOfMozillaApp];
		
		NSMenuItem* mozillaMenuItem	= [popUpButton itemWithTitle: kNameOfMozillaApp];
		NSImage*	mozillaIcon		= [workspace iconForFile: pathOfMozilla];
		
		[mozillaIcon setSize: NSMakeSize(16, 16)];
		[mozillaMenuItem setImage: mozillaIcon];
	}
	
	
	// Add Safari if it exsits
	
	NSString* pathOfSafari = [workspace fullPathForApplication: kNameOfSafariApp];
	
	if (pathOfSafari != nil)
	{
		[popUpButton addItemWithTitle: kNameOfSafariApp];
		
		NSMenuItem* safariMenuItem	= [popUpButton itemWithTitle: kNameOfSafariApp];
		NSImage*	safariIcon		= [workspace iconForFile: pathOfSafari];
		
		[safariIcon setSize: NSMakeSize(16, 16)];
		[safariMenuItem setImage: safariIcon];
	}
	
	
	// Add Shiira if it exsits
	
	NSString* pathOfShiira = [workspace fullPathForApplication: kNameOfShiiraApp];
	
	if (pathOfShiira != nil)
	{
		[popUpButton addItemWithTitle: kNameOfShiiraApp];
		
		NSMenuItem* shiiraMenuItem	= [popUpButton itemWithTitle: kNameOfShiiraApp];
		NSImage*	shiiraIcon		= [workspace iconForFile: pathOfShiira];
		
		[shiiraIcon setSize: NSMakeSize(16, 16)];
		[shiiraMenuItem setImage: shiiraIcon];
	}
}


@end