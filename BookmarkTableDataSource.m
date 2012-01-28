/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import "BookmarkTableDataSource.h"

#import "Bookmark.h"
#import "BookmarkController.h"


NSString* const kTitleIdentifier	= @"Title";
NSString* const kURLIdentifier		= @"URL";

NSString* const kBookmarkDragType	= @"DBBookmarkDragType";


@implementation BookmarkTableDataSource


- (id) initWithBookmarkController: (BookmarkController*) bookmarkController
{
	if (self = [super init])
	{
		mBookmarkController = [bookmarkController retain];
	}
	
	return self;
}

- (void) dealloc
{
	[mBookmarkController release];
	
	[super dealloc];
}


- (int) numberOfRowsInTableView: (NSTableView*) tableView
{
	return [mBookmarkController numberOfBookmarks];
}

- (id) tableView: (NSTableView*) tableView objectValueForTableColumn: (NSTableColumn*) tableColumn row: (int) row
{
	id			value				= nil;
	NSString*	columnIdentifier	= [tableColumn identifier];
	
	if ([columnIdentifier isEqualToString: kTitleIdentifier])
	{
		value = [mBookmarkController bookmarkAtIndex: row];
	}
	else if ([columnIdentifier isEqualToString: kURLIdentifier])
	{
	}
	
	return value;
}


@end



@implementation BookmarkOutlineDataSource


- (id) initWithBookmarkController: (BookmarkController*) bookmarkController
{
	if (self = [super init])
	{
		mBookmarkController = [bookmarkController retain];
	}
	
	return self;
}

- (void) dealloc
{
	[mBookmarkController release];
	[mDraggingBookmarks release];
	
	[super dealloc];
}


- (int) outlineView: (NSOutlineView*) outlineView numberOfChildrenOfItem: (id) item
{
	int numberOfChildren = 0;
	
	if (item != nil && [item respondsToSelector: @selector(subBookmarks)])
	{
		numberOfChildren = [[item subBookmarks] count];
	}
	else
	{
		numberOfChildren = [mBookmarkController numberOfBookmarks];
	}
	
	return numberOfChildren;
}


// PRETTYIZE IT!

- (BOOL) outlineView: (NSOutlineView*) outlineView isItemExpandable: (id) item
{
	return ([item respondsToSelector: @selector(subBookmarks)] && [[item subBookmarks] count] > 0);
}


- (id) outlineView: (NSOutlineView*) outlineView child: (int) index ofItem: (id) item
{
	id child = nil;
	
	if (item == nil)
	{
		child = [mBookmarkController bookmarkAtIndex: index];
	}
	else
	{
		child = [[item subBookmarks] objectAtIndex: index];
	}
	
	return child;
}

- (id) outlineView: (NSOutlineView*) outlineView objectValueForTableColumn: (NSTableColumn*) tableColumn byItem: (id) item
{
	id			value				= nil;
	NSString*	columnIdentifier	= [tableColumn identifier];
	
	if ([columnIdentifier isEqualToString: kTitleIdentifier])
	{
		value = [item title];
	}
	else if ([columnIdentifier isEqualToString: kURLIdentifier])
	{
		value = [item URLString];
	}
	
	return value;
}

- (void) outlineView: (NSOutlineView*) outlineView setObjectValue: (id) object forTableColumn: (NSTableColumn*) tableColumn byItem: (id) item
{
	NSString* columnIdentifier = [tableColumn identifier];
	
	if ([columnIdentifier isEqualToString: kTitleIdentifier])
	{
		[item setTitle: object];
	}
	else if ([columnIdentifier isEqualToString: kURLIdentifier])
	{
		[item setURLString: object];
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName: kBookmarksDidChangeNotification object: mBookmarkController];
}

- (BOOL) outlineView: (NSOutlineView*) olv writeItems: (NSArray*) items toPasteboard: (NSPasteboard*) pboard
{
	BOOL wroteToPasteboard = NO;
	
//	if ([pboard setPropertyList: bookmarkDictionary forType: kBookmarkDragType])
	{
		wroteToPasteboard	= YES;
		mDraggingBookmarks	= [items copy];
		NSLog(@"%@ vs %@", [items class], [mDraggingBookmarks class]);
		NSLog(@"Write item: %@ %@", [items objectAtIndex: 0], [[items objectAtIndex: 0] title]);
	}
	
	return wroteToPasteboard;
}

- (NSDragOperation) outlineView: (NSOutlineView*) olv validateDrop: (id <NSDraggingInfo>) info proposedItem: (id) item proposedChildIndex: (int) index
{
	NSDragOperation operation = NSDragOperationGeneric;
	
	return operation;
}

- (BOOL) outlineView: (NSOutlineView*) olv acceptDrop: (id <NSDraggingInfo>) info item: (id) item childIndex: (int) index
{
	BOOL			acceptDrop		= NO;
	
	NSPasteboard*	draggingPboard	= [info draggingPasteboard];
	NSDragOperation	draggingMask	= [info draggingSourceOperationMask];
	
	if (draggingMask == NSTableViewDropAbove)
	{
		NSDictionary*	bdict		= [draggingPboard propertyListForType: kBookmarkDragType];
		Bookmark*		newBookmark = [[Bookmark alloc] initWithDictionary: bdict];
		//[item addBookmark: newBookmark];
		int i = [mDraggingBookmarks count];
		while (i--)
		{
			Bookmark* bookmark	= [mDraggingBookmarks objectAtIndex: i];
			Bookmark* copy		= [(Bookmark*)bookmark copy];
			//NSLog(@"%@", [bookmark class]);
			NSLog(@"%i", [mDraggingBookmarks count]);
			NSLog(@"%@ vs %@", bookmark, copy);
			[item addBookmark: copy];
		}
		
		[[NSNotificationCenter defaultCenter] postNotificationName: kBookmarksDidChangeNotification object: mBookmarkController];
		
		[mDraggingBookmarks release];
		mDraggingBookmarks	= nil;
		
		acceptDrop = YES;
	}
	
	return acceptDrop;
}


@end