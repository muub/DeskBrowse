/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import <Cocoa/Cocoa.h>


@class Bookmark;
@class BookmarkController;

@interface NewBookmarkWindowController : NSWindowController
{
	IBOutlet NSTextField*	mTitleField;
	
	BookmarkController*		mBookmarkController;
	NSURL*					mBookmarkURL;
	NSString*				mBookmarkTitle;
}

- (id) initWithBookmarkController: (BookmarkController*) bookmarkController title: (NSString*) bookmarkTitle url: (NSURL*) bookmarkURL;

- (void) runSheetOnWindow: (NSWindow*) window;

- (IBAction) ok: (id) sender;
- (IBAction) cancel: (id) sender;

@end