/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import <Cocoa/Cocoa.h>

@class BetterOutlineView;
@class BookmarkController;
@class BookmarkOutlineDataSource;
@class BookmarkTableDataSource;


@interface BookmarkEditWindowController : NSWindowController
{
	BookmarkController*			mBookmarkController;
	BookmarkOutlineDataSource*	mOutlineDataSource;
	NSFont*						mOutlineViewFont;
	
	IBOutlet BetterOutlineView*	mOutlineView;
}

- (id) initWithOutlineDataSource: (BookmarkOutlineDataSource*) dataSource bookmarkController: (BookmarkController*) bookmarkController;

- (IBAction) closeWindow: (id) sender;
- (IBAction) addBookmark: (id) sender;

- (void) runSheetOnWindow: (NSWindow*) window;

@end