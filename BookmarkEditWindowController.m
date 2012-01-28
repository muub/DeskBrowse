/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import "BookmarkEditWindowController.h"

#import "BetterOutlineView.h"
#import "Bookmark.h"
#import "BookmarkController.h"
#import "BookmarkTableDataSource.h"


NSString* const kBookmarkEditWindowNibName = @"BookmarkEdit";

@implementation BookmarkEditWindowController


- (id) initWithOutlineDataSource: (BookmarkOutlineDataSource*) dataSource bookmarkController: (BookmarkController*) bookmarkController
{
	if (self = [super initWithWindowNibName: kBookmarkEditWindowNibName])
	{
		mOutlineDataSource	= [dataSource retain];
		mBookmarkController	= [bookmarkController retain];
		mOutlineViewFont	= [[NSFont systemFontOfSize: 10.0] retain];
		
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reloadData) name: kBookmarksDidChangeNotification object: nil];
	}
	
	return self;
}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	
	[mOutlineDataSource release];
	[mBookmarkController release];
	[mOutlineViewFont release];
		
	[super dealloc];
}


- (IBAction) closeWindow: (id) sender
{
	[NSApp endSheet: [self window]];
	[self close];
}

- (IBAction) addBookmark: (id) sender
{
	Bookmark* newBookmark = [[Bookmark alloc] initWithURL: nil title: nil];
	
	[mBookmarkController addBookmark: newBookmark toFront: YES];
	[newBookmark release];
	
	[mOutlineView selectRow: 0 byExtendingSelection: NO];
	[mOutlineView editFirstColumnOfSelectedRow];
}


- (void) close
{
	[NSApp endSheet: [self window]];
	[super close];
	
	[self release];
}

- (void) runSheetOnWindow: (NSWindow*) window
{
	[NSApp beginSheet: [self window] modalForWindow: window modalDelegate: nil didEndSelector: nil contextInfo: nil];
	
	[mOutlineView setDelegate: self];
	[mOutlineView setDataSource: mOutlineDataSource];
	
	[mOutlineView setDraggingSourceOperationMask: NSTableViewDropAbove forLocal: YES];
	[mOutlineView registerForDraggedTypes: [NSArray arrayWithObject: kBookmarkDragType]];
	
	[self retain];
}


- (void) reloadData
{
	[mOutlineView reloadData];
}


- (void) outlineView: (NSOutlineView*) outlineView willDisplayCell: (id) cell forTableColumn: (NSTableColumn*) tableColumn item: (id) item
{
	[cell setFont: mOutlineViewFont];
}


@end