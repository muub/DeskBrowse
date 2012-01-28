/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import "BookmarkBar.h"

#import "Bookmark.h"
#import "BookmarkBarCell.h"
#import "BookmarkController.h"
#import "BookmarkBarPopUpButton.h"


const float kDistanceBetweenBookmarks = 5;

@interface BookmarkBar (Private)

- (float) maxRightEdgeForCells;

- (void) drawBackgroundInRect: (NSRect) rect;
- (void) drawCellsInRect: (NSRect) rect;
- (void) drawDragIndicatorInRect: (NSRect) rect;

- (void) arrangeBookmarkBarCells;

- (void) setUpPopUpButton;
- (void) adjustPopUpButtonPosition;
- (void) removeAllBookmarksFromPopUpButton;
- (void) addBookmarkCellToPopUpButton: (id <BookmarkBarCell>) BookmarkBarCell;
- (void) removePopUpButton;
- (void) addPopUpButton;

@end


@implementation BookmarkBar

- (id) initWithFrame: (NSRect) frame
{
    if (self = [super initWithFrame: frame])
	{
		mBookmarkCells		= [[NSMutableArray alloc] init];
		mBackgroundColor	= [[NSColor colorWithDeviceRed: 0.35 green: 0.35 blue: 0.35 alpha: 1.0] retain];
		
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reloadData) name: kBookmarksDidChangeNotification object: nil];
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(frameDidChange:) name: NSViewFrameDidChangeNotification object: self];
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(frameDidChange:) name: NSViewBoundsDidChangeNotification object: self];
		
		[self setPostsFrameChangedNotifications: YES];
		[self setPostsBoundsChangedNotifications: YES];
		
		[self registerForDraggedTypes: [NSArray arrayWithObject: DBBookmarkCellPboardType]];
	}
	
	return self;
}

- (void) awakeFromNib
{
	[self setUpPopUpButton];
	
	mLastFrame = [self frame];
}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	
	[mBookmarkController release];
	[mBackgroundColor release];
	[mExtraBookmarksPopUpButton	release];
	[mBookmarkCells release];
	
	[super dealloc];
}


#pragma mark -

- (void) drawRect: (NSRect) rect
{
	[self drawBackgroundInRect: [self bounds]];//rect];
	[self drawCellsInRect: rect];
}


#pragma mark -


- (void) setBookmarkController: (BookmarkController*) bookmarkController
{
	if (bookmarkController != mBookmarkController)
	{
		[bookmarkController retain];
		[mBookmarkController release];
		
		mBookmarkController = bookmarkController;
		
		[self reloadData];
	}
}

- (void) frameDidChange: (NSNotification*) notification
{
	NSRect frame = [self frame];
	
	if (frame.size.width != mLastFrame.size.width)
	{
		[self arrangeBookmarkBarCells];
	}
	
	mLastFrame = frame;
}

- (void) reloadData
{
	[self removeAllBookmarksFromPopUpButton];	
	[mBookmarkCells removeAllObjects];
	
	NSArray*		bookmarks			= [mBookmarkController bookmarks];
	
	NSRect			frame				= [self frame];
	float			frameHeight			= frame.size.height;
	float			frameWidth			= frame.size.width;
	
	float			maxRightEdge		= [self maxRightEdgeForCells];
	
	NSEnumerator*	bookmarkEnumerator	= [mBookmarkController bookmarkEnumerator];
	Bookmark*		currentBookmark		= nil;
	
	while ((currentBookmark = [bookmarkEnumerator nextObject]) != nil)
	{
		id <BookmarkBarCell> bookmarkBarCell = [currentBookmark cell];
		
		if (bookmarkBarCell != nil)
		{
			[mBookmarkCells addObject: bookmarkBarCell];
			
			if (maxRightEdge > NSMaxX([bookmarkBarCell frame]))
			{
				[self addBookmarkCellToPopUpButton: bookmarkBarCell];
			}
		}
	}
	
	[self arrangeBookmarkBarCells];
		
	[self setNeedsDisplay: YES];
}

- (id <BookmarkBarCell>) bookmarkCellAtPoint: (NSPoint) point
{
	id <BookmarkBarCell>	bookmarkCell	= nil;
	
	float					maxRightEdge	= [self maxRightEdgeForCells];
	
	NSEnumerator*			cellEnumerator	= [mBookmarkCells objectEnumerator];
	id <BookmarkBarCell>	currentCell		= nil;
	
	while ((currentCell = [cellEnumerator nextObject]) != nil)
	{
		NSRect cellFrame = [currentCell frame];
		
		if (NSMaxX(cellFrame) < maxRightEdge)
		{
			if (NSPointInRect(point, [currentCell frame]))
			{
				bookmarkCell = currentCell;
				break;
			}
		}
		else
		{
			break;
		}
	}
	
	return bookmarkCell;
}

- (unsigned) indexClosestToPoint: (NSPoint) point
{
	unsigned returnIndex = 0;
	
	float						maxRightEdge		= [self maxRightEdgeForCells];
	NSRect						lastCellFrame		= NSZeroRect;
	
	NSEnumerator*				cellEnumerator		= [mBookmarkCells objectEnumerator];
	id <BookmarkBarCell>	currentCell			= nil;
	unsigned					currentCellIndex	= 0;
	
	while ((currentCell = [cellEnumerator nextObject]) != nil)
	{
		NSRect cellFrame = [currentCell frame];
		
		if (NSMaxX(cellFrame) > maxRightEdge || point.x < NSMidX(cellFrame) && point.x > NSMidX(lastCellFrame))
		{
			returnIndex = currentCellIndex;
			break;
		}
		
		lastCellFrame = cellFrame;
		
		currentCellIndex++;
	}
	
	return returnIndex;
}

- (void) setVisiblePosition: (NSPoint) position
{
	NSRect frame = [self frame];
	[self setFrame: NSMakeRect(position.x, position.y, frame.size.width, frame.size.height)];
}


#pragma mark -

- (void) mouseDown: (NSEvent*) event
{
	NSPoint						clickPoint	= [self convertPoint: [event locationInWindow] fromView: nil];
	id <BookmarkBarCell>	clickedCell = [self bookmarkCellAtPoint: clickPoint];
	
	[clickedCell mouseDown: event];
}

- (void) mouseUp: (NSEvent*) event
{
	NSPoint						clickPoint	= [self convertPoint: [event locationInWindow] fromView: nil];
	id <BookmarkBarCell>	clickedCell = [self bookmarkCellAtPoint: clickPoint];
	
	[clickedCell mouseUp: event];
}

- (void) mouseDragged: (NSEvent*) event
{
	NSPasteboard*				pboard		= [NSPasteboard pasteboardWithName: NSDragPboard];
	NSPoint						clickPoint	= [self convertPoint: [event locationInWindow] fromView: nil];
	id <BookmarkBarCell>	clickedCell = [self bookmarkCellAtPoint: clickPoint];
	
	if (clickedCell != nil)
	{
		int			indexOfCellInArray	= [mBookmarkCells indexOfObject: clickedCell];
		NSNumber*	numberIndexOfCell	= [NSNumber numberWithInt: indexOfCellInArray];
		
		[pboard declareTypes: [NSArray arrayWithObject: DBBookmarkCellPboardType] owner: self];
		[pboard setPropertyList: numberIndexOfCell forType: DBBookmarkCellPboardType];
		
		
		NSImage* dragImage = [clickedCell dragImage];
		
		if (dragImage != nil)
		{
			[self dragImage: [clickedCell dragImage] at: [clickedCell frame].origin offset: NSZeroSize event: event pasteboard: pboard source: self slideBack: YES];
		}
	}
}


#pragma mark -

- (NSArray*) menuItemsForPopUpButton: (NSPopUpButton*) popUpButton
{
	NSMutableArray*				menuItems		= [NSMutableArray array];
	BOOL						fillNow			= NO;
	
	float						maxRightEdge	= [self maxRightEdgeForCells];
	
	NSEnumerator*				cellEnumerator	= [mBookmarkCells objectEnumerator];
	id <BookmarkBarCell>	currentCell		= nil;
	
	while ((currentCell = [cellEnumerator nextObject]) != nil)
	{
		if (!fillNow)
		{
			if (NSMaxX([currentCell frame]) >= maxRightEdge)
			{
				fillNow = YES;
			}
		}
		
		if (fillNow)
		{
			NSMenuItem* cellMenuItem = [currentCell menuItem];
			
			if (cellMenuItem != nil)
			{
				[menuItems addObject: cellMenuItem];
			}
		}
	}
	
	return menuItems;
}


@end

#pragma mark -


@implementation BookmarkBar (DraggingDesitination)


- (NSDragOperation) draggingSourceOperationMaskForLocal: (BOOL) flag
{
	NSDragOperation operation = NSDragOperationNone;
	
	if (flag)
	{
		operation = NSDragOperationGeneric;
	}
	
	return operation;
}

- (unsigned int) draggingEntered: (id <NSDraggingInfo>) sender
{
	NSDragOperation returnOperation	= NSDragOperationNone;
	NSDragOperation operation		= [sender draggingSourceOperationMask];
	NSPasteboard*	pboard			= [sender draggingPasteboard];
	
	if (operation == NSDragOperationGeneric)
	{
		id <BookmarkBarCell> draggedCell = [pboard propertyListForType: DBBookmarkCellPboardType];
		
		if (draggedCell != nil)
		{
			returnOperation	= NSDragOperationGeneric;
			mDragging		= YES;
			
			[self setNeedsDisplay: YES];
		}
	}
	
	return returnOperation;
}

- (NSDragOperation) draggingUpdated: (id <NSDraggingInfo>) sender
{
	NSDragOperation returnOperation	= NSDragOperationNone;
	NSDragOperation operation		= [sender draggingSourceOperationMask];
	NSPasteboard*	pboard			= [sender draggingPasteboard];
	
	if (operation == NSDragOperationGeneric)
	{
		id <BookmarkBarCell> draggedCell = [pboard propertyListForType: DBBookmarkCellPboardType];
		
		if (draggedCell != nil)
		{
			NSPoint mouseLocation = [[self window] convertScreenToBase: [NSEvent mouseLocation]];
			
			if (mouseLocation.x != mLastMouseX)
			{
				mDragging		= YES;
				mLastMouseX		= mouseLocation.x;
				returnOperation	= NSDragOperationGeneric;
				
				[self setNeedsDisplay: YES];
			}
		}
	}
	
	return operation;
}

- (void) draggingExited: (id <NSDraggingInfo>) sender
{
	mDragging = NO;
	[self setNeedsDisplay: YES];
}


#pragma mark -

- (BOOL) prepareForDragOperation: (id <NSDraggingInfo>) sender
{
	return YES;
}

- (BOOL) performDragOperation: (id <NSDraggingInfo>) sender
{
	BOOL			perform					= NO;
	NSPoint			dragLocation			= [self convertPoint: [sender draggingLocation] fromView: nil];
	NSPasteboard*	pboard					= [sender draggingPasteboard];
	NSNumber*		indexOfDraggedBookmark	= [pboard propertyListForType: DBBookmarkCellPboardType];
	
	if (indexOfDraggedBookmark != nil)
	{
		mDragging			= NO;
		perform				= YES;
		
		unsigned fromIndex	= [indexOfDraggedBookmark intValue];
		unsigned toIndex	= [self indexClosestToPoint: dragLocation];
		
		if (fromIndex != toIndex)
		{
			[mBookmarkController bookmarkDraggedFromIndex: fromIndex toIndex: toIndex];
			
			[self reloadData];
		}
	}
	
	return perform;
}

- (void) concludeDragOperation: (id <NSDraggingInfo>) sender
{
	[self setNeedsDisplay: YES];
}


@end

#pragma mark -


@implementation BookmarkBar (Private)


- (float) maxRightEdgeForCells
{
	float	maxRightEdge	=  0;
	NSRect	frameRect		= [self frame];
	
	if ([mExtraBookmarksPopUpButton superview] == self)
	{
		maxRightEdge = frameRect.size.width - [mExtraBookmarksPopUpButton frame].size.width - kDistanceBetweenBookmarks;
	}
	else
	{
		maxRightEdge = frameRect.size.width - kDistanceBetweenBookmarks;
	}
	
	return maxRightEdge;
}


#pragma mark -

- (void) drawBackgroundInRect: (NSRect) rect
{
//	[mBackgroundColor set];
//	[[NSColor whiteColor] set];
//	NSRectFill(rect);
	NSImage* image = [NSImage imageNamed: @"bb-top-bookmark-stretch"];
	[image drawInRect: rect fromRect: NSMakeRect(0, 0, [image size].width, [image size].height) operation: NSCompositeCopy fraction: 1.0];
}

- (void) drawCellsInRect: (NSRect) rect
{
	NSPoint					mouseLocation		= [[self window] convertScreenToBase: [NSEvent mouseLocation]];//[self convertPoint: [[[NSApp mainWindow] currentEvent] locationInWindow] fromView: nil];
	NSRect					frameRect			= [self frame];
	NSRect					frameMinusPadding	= NSMakeRect(frameRect.origin.x - kDistanceBetweenBookmarks, frameRect.origin.y, frameRect.size.width - (2 * kDistanceBetweenBookmarks), frameRect.size.height);
	
	float					maxRightEdge		= [self maxRightEdgeForCells];
	NSRect					lastCellFrame		= NSZeroRect;
	
	NSEnumerator*			cellEnumerator		= [mBookmarkCells objectEnumerator];
	id <BookmarkBarCell>	currentCell			= nil;
	
	while ((currentCell = [cellEnumerator nextObject]) != nil)
	{
		NSRect cellFrame = [currentCell frame];
		
		if (mDragging)
		{
			if (mouseLocation.x < NSMidX(cellFrame) && mouseLocation.x > NSMidX(lastCellFrame))
			{
				float	positionOfIndicator		= NSMaxX(lastCellFrame) + (NSMinX(cellFrame) - NSMaxX(lastCellFrame)) / 2;
				NSRect	rectForDragIndicator	= NSMakeRect(positionOfIndicator, 0, 1, NSHeight(frameRect) - 2);
				
				[self drawDragIndicatorInRect: rectForDragIndicator];
			}
		}
		
		if (NSMaxX(cellFrame) < maxRightEdge)
		{
			if (NSIntersectsRect(rect, cellFrame))
			{
				[currentCell drawWithFrame: cellFrame inView: self];
			}
		}
		else
		{
			break;
		}
		
		lastCellFrame = cellFrame;
	}
}

- (void) drawDragIndicatorInRect: (NSRect) rect
{
	[[NSColor whiteColor] set];

	NSRectFill(rect);
}


#pragma mark -

- (void) arrangeBookmarkBarCells
{
	[self adjustPopUpButtonPosition];
	
	NSRect					frameRect					= [self frame];
	NSRect					frameMinusPadding			= NSMakeRect(frameRect.origin.x - kDistanceBetweenBookmarks, frameRect.origin.y, frameRect.size.width - (2 * kDistanceBetweenBookmarks), frameRect.size.height);
	
	unsigned				currentCellIndex			= 0;
	unsigned				numberOfCells				= [mBookmarkCells count];
	
	NSEnumerator*			bookmarkBarCellEnumerator	= [mBookmarkCells objectEnumerator];
	id <BookmarkBarCell>	currentCell					= nil;
	NSRect					lastCellFrame				= NSMakeRect(0, 3, 0, 16);
	
	while ((currentCell = [bookmarkBarCellEnumerator nextObject]) != nil)
	{
		NSRect	cellFrame		= [currentCell frame];
		NSRect	newCellFrame	= lastCellFrame;
		
		newCellFrame.origin.x	= NSMaxX(lastCellFrame) + kDistanceBetweenBookmarks;
		newCellFrame.size.width = cellFrame.size.width;
		
		
		[currentCell setFrame: newCellFrame];
		
		if (currentCellIndex == numberOfCells - 1)
		{
			if (NSMaxX(newCellFrame) < (frameRect.size.width - kDistanceBetweenBookmarks))
			{
				[self removePopUpButton];
			}
			else
			{
				[self addPopUpButton];
			}
		}
		
		
		lastCellFrame = newCellFrame;
		currentCellIndex++;
	}
}


#pragma mark -

- (void) setUpPopUpButton
{
	NSRect popUpButtonFrame		= NSMakeRect(0, 3, 51, 15);
	mExtraBookmarksPopUpButton	= [[BookmarkBarPopUpButton alloc] initWithFrame: popUpButtonFrame];
	
	[self adjustPopUpButtonPosition];
}

- (void) adjustPopUpButtonPosition
{
	NSRect frame	= [mExtraBookmarksPopUpButton frame];
	frame.origin.x	= NSWidth([self frame]) - NSWidth(frame) - kDistanceBetweenBookmarks;
	
	[mExtraBookmarksPopUpButton setFrame: frame];
}

- (void) removeAllBookmarksFromPopUpButton
{
	[mExtraBookmarksPopUpButton removeAllItems];
}

- (void) addBookmarkCellToPopUpButton: (id <BookmarkBarCell>) bookmarkBarCell
{
	NSMenu*		menu		= [mExtraBookmarksPopUpButton menu];
	NSMenuItem*	menuItem	= [bookmarkBarCell menuItem];
	
	if (menuItem != nil)
	{
		[menu addItem: menuItem];
	}
	
}

- (void) removePopUpButton
{
	if ([mExtraBookmarksPopUpButton superview] == self)
	{
		[mExtraBookmarksPopUpButton removeFromSuperview];
	}
}

- (void) addPopUpButton
{
	if ([mExtraBookmarksPopUpButton superview] != self)
	{
		[self addSubview: mExtraBookmarksPopUpButton];
	}
}


@end