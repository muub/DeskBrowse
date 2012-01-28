/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import "BezelTableView.h"


@implementation BezelTableView


- (void) awakeFromNib
{
	BezelScroller* scroller = [[BezelScroller alloc] init];

	[[self enclosingScrollView] setVerticalScroller: scroller];
	[scroller release];

	// This is the color used in all our bezel windows
	NSColor* backgroundColor = [NSColor colorWithDeviceRed: 0.0 green: 0.0 blue: 0.0 alpha: 0.77];
	
	[self setBackgroundColor: backgroundColor];
	[self setGridColor: backgroundColor];
	[self setGridStyleMask: NSTableViewGridNone];
	[self setIntercellSpacing: NSMakeSize(0, 0)];
	
	
	NSEnumerator*	columnEnumerator	= [[self tableColumns] objectEnumerator];
	NSTableColumn*	currentTableColumn	= nil;
	
	while ((currentTableColumn = [columnEnumerator nextObject]) != nil)
	{
		BezelDataCell* newDataCell = [[BezelDataCell alloc] init];
		
		[currentTableColumn setDataCell: newDataCell];
		[newDataCell release];
	}

	// Have to do this so the columns size themselves properly before display
	NSRect frame	= [self frame];
	NSRect newFrame	= frame;
	
	newFrame.size.width = newFrame.size.width + 1;
	
	[self setFrame: newFrame];
	[self setFrame: frame];
}

- (BOOL) performKeyEquivalent: (NSEvent*) event
{
	BOOL handled = NO;
	
	if (self == [[self window] firstResponder])
	{
		NSString* characters = [event charactersIgnoringModifiers];
		
		if ([characters length] == 1)
		{
			unichar character = [characters characterAtIndex: 0];
			
			if (character == NSDeleteFunctionKey || character == 0x7F)
			{
				id delegate = [self delegate];
				
				if (delegate != nil)
				{
					if ([delegate respondsToSelector: @selector(tableViewDeleteKeyPressed:)])
					{
						[delegate tableViewDeleteKeyPressed: self];	
						handled = YES;
					}
				}
			}
		}
	}
	
	if (!handled)
	{
		handled = [super performKeyEquivalent: event];
	}
	
	return handled;
}


#pragma mark -
#pragma mark Drag and Drop

/*- (NSImage*) dragImageForRowsWithIndexes: (NSIndexSet*) dragRows tableColumns: (NSArray*) tableColumns event: (NSEvent*) dragEvent offset: (NSPointPointer) dragImageOffset
{

	// Get our superclass's image -- it's a good starting point.
	NSImage*	superImage		= [super dragImageForRowsWithIndexes: dragRows tableColumns: tableColumns event: dragEvent offset: dragImageOffset];
	NSSize		superImageSize	= [superImage size];
	
	// Allocate an image which is just a bit larger.
	NSRect imageRect;
	imageRect.origin.x		= 0.0f;
	imageRect.origin.y		= 0.0f;
	imageRect.size.width	= superImageSize.width + 3.0f;
	imageRect.size.height	= superImageSize.height + 2.0f;
	
	NSImage* newImage = [[[NSImage alloc] initWithSize: imageRect.size] autorelease];
	[newImage lockFocus];
	
	// Create a transparent row-sized fill.
	[[[NSColor colorWithDeviceRed: 0.0 green: 0.0 blue: 0.0 alpha: 0.77] colorWithAlphaComponent: kDragImageAlpha] set];
//	NSRectFill(imageRect);
	
	// Frame it with transparent black.
	[[NSColor blackColor] set];
//	NSFrameRectWithWidthUsingOperation(imageRect, 1.0f, NSCompositeDestinationOver);
	
	// Draw our superclass's image underneath the fill.
	[superImage compositeToPoint: NSMakePoint(1.0f, 1.0f) operation: NSCompositeDestinationOver];
	
	// End drawing
	[newImage unlockFocus];
	
	return newImage;
}*/

- (unsigned int) draggingSourceOperationMaskForLocal: (BOOL) isLocal
{
	unsigned int operation = NSDragOperationNone;
	
	if (isLocal)
	{
		operation = NSDragOperationMove;
	}
	
	return operation;
}


@end