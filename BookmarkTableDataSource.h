/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import <Cocoa/Cocoa.h>

@class BookmarkController;


extern NSString* const kBookmarkDragType;

@interface BookmarkTableDataSource : NSObject
{
@private
	BookmarkController* mBookmarkController;
}

- (id) initWithBookmarkController: (BookmarkController*) bookmarkController;

@end


@interface BookmarkOutlineDataSource : NSObject
{
@private
	BookmarkController* mBookmarkController;
	NSArray*			mDraggingBookmarks;
}

- (id) initWithBookmarkController: (BookmarkController*) bookmarkController;

@end