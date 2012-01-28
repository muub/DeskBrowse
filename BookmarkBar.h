/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import <Cocoa/Cocoa.h>

@class Bookmark;
@class BookmarkController;
@class BookmarkBarPopUpButton;


@interface BookmarkBar : NSView
{
	BookmarkController*		mBookmarkController;
	NSColor*				mBackgroundColor;
	BookmarkBarPopUpButton*	mExtraBookmarksPopUpButton;
	
	NSMutableArray*			mBookmarkCells;
	
	BOOL					mDragging;
	float					mLastMouseX;
	
	NSRect					mLastFrame;
}

- (void) setBookmarkController: (BookmarkController*) bookmarkController;
- (void) reloadData;
- (void) setVisiblePosition: (NSPoint) position;
- (NSArray*) menuItemsForPopUpButton: (NSPopUpButton*) popUpButton;

@end