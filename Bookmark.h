/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import <Cocoa/Cocoa.h>

#import "BookmarkBarCell.h"


extern NSString* kDBLoadURLNotification;
extern NSString* kDBDeleteBookmarkNotification;

@interface Bookmark : NSView <NSCopying>
{
	NSURL*		mURL;
	NSString*	mTitle;
	
	
	// Bookmark bar
	
	id <BookmarkBarCell>	mBookmarkBarCell;
	
	BOOL					mDragging;
	BOOL					mMouseOver;
	BOOL					mMouseDown;
	
	NSNumber*				mIndex;
}

- (id) initWithDictionary: (NSDictionary*) dictionary;
- (id) initWithURL: (NSURL*) URL title: (NSString*) title;
- (void) load;
- (void) remove;
- (NSMutableDictionary*) dictionary;

- (NSURL*) URL;
- (void) setURL: (NSURL*) URL;

- (NSString*) URLString;
- (void) setURLString: (NSString*) urlString;

- (NSString*) title;
- (void) setTitle: (NSString*) title;


// Bookmark bar

- (id <BookmarkBarCell>) cell;

@end


@interface BookmarkFolder: Bookmark
{
	NSMutableArray* mContainedBookmarks;
}

- (unsigned) numberOfBookmarks;

- (NSArray*) subBookmarks;						// These should not be used by outsiders; they are used only for NSCoding
- (void) setSubBookmarks: (NSArray*) bookmarks;	//

- (void) addBookmark: (Bookmark*) bookmark;
- (void) removeBookmark: (Bookmark*) bookmark;

- (void) reloadCellMenu;

@end