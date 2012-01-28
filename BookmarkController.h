/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import <Cocoa/Cocoa.h>

#import "NSFileManagerSGSAdditions.h"

@class Bookmark;
@class BookmarkBar;
@class BookmarkImporter;
@class DeskBrowseConstants;


extern NSString* const kNameOfBookmarkFile;
extern NSString* const kBookmarksDidChangeNotification;
extern NSString* const DBBookmarkRows;


@interface BookmarkController : NSWindowController
{
	NSMutableArray*			mBookmarks;
	
	
	// Interface related
	
	IBOutlet NSTableView*	mBookmarkTableView;	
	
	// New bookmark window
	
	IBOutlet NSPanel*		mNewBookmarkWindow;
	IBOutlet NSTextField*	mTitleField;
	
	NSURL*					mCurrentNewBookmarkURL;
}

- (void) newBookmarkWithURL: (NSURL*) URL title: (NSString*) title window: (NSWindow*) window;

- (unsigned) numberOfBookmarks;
- (Bookmark*) bookmarkAtIndex: (unsigned) index;
- (void) addBookmark: (Bookmark*) bookmark toFront: (BOOL) toFront;
- (BOOL) addBookmarks: (NSArray*) bookmarks;

- (void) save;
- (void) load;
- (BOOL) saveBookmarks;
- (BOOL) loadBookmarks;

// Interface methods
- (IBAction) loadSelectedBookmark: (id) sender;
- (IBAction) deleteSelectedBookmark: (id) sender;

- (IBAction) cancel: (id) sender;
- (IBAction) ok: (id) sender;

// View methods
- (void) setTableView: (NSTableView*) tableView;
- (int) numberOfRows;
- (NSString*) stringForRow: (int) row;
- (void) tableViewDoubleClick;
- (void) tableViewDeleteKeyPressed: (NSTableView*) tableView;
- (void) loadBookmarkAtIndex: (int) index;
- (void) bookmarkDelete: (NSNotification*) notification;
- (void) deleteBookmark: (Bookmark*) bookmark;
- (void) deleteBookmarkAtIndex: (int) index;

// Main window
- (IBAction) openEditWindow: (id) sender;
- (IBAction) closeEditWindow: (id) sender;

// Bookmark bar
- (NSArray*) bookmarks;
- (NSEnumerator*) bookmarkEnumerator;
- (void) bookmarkDraggedFromIndex: (int) index toIndex: (int) newIndex;

// Bookmark editing window
- (void) newBookmarkFolder;

@end