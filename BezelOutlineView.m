/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/


#import "BezelOutlineView.h"


@implementation BezelOutlineView


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
	
	
	int				i;
	NSArray*		tableColumns		= [self tableColumns];
	NSTableColumn*	currentTableColumn	= nil;
	
	for (i = 0; i < [tableColumns count]; i++)
	{
		currentTableColumn			= [tableColumns objectAtIndex: i];
		BezelDataCell* newDataCell	= [[BezelDataCell alloc] init];
		
		[currentTableColumn setDataCell: newDataCell];
		[newDataCell release];
	}
	
	BezelButtonCell* newOutlineCell = [[BezelButtonCell alloc] init];
	[newOutlineCell setBackgroundColor: [NSColor redColor]];
	[self setOutlineCell: newOutlineCell];
	[newOutlineCell release];

	// Have to do this so the columns size themselves properly before display
	NSRect frame	= [self frame];
	NSRect newFrame	= frame;
	
	newFrame.size.width = newFrame.size.width + 1;
	
	[self setFrame: newFrame];
	[self setFrame: frame];
}

- (void) keyDown: (NSEvent*) theEvent
{
	NSString*	characters	= [theEvent charactersIgnoringModifiers];
	BOOL		handled		= NO;
	
	if ([characters length] == 1)
	{
		unichar	character = [characters characterAtIndex: 0];
		
		if (character == NSDeleteFunctionKey || character == 0x7F)
		{
			[[self delegate] tableViewDeleteKeyPressed: self];
			handled = YES;
		}
	}
	
	if (!handled)
	{
		[super keyDown: theEvent];
	}
}


@end

@implementation NSOutlineView (SGSAdditions)

- (void) setOutlineCell: (NSButtonCell*) newCell
{
	if (newCell != _outlineCell)
	{
		[newCell retain];
		[_outlineCell release];
		
		_outlineCell = newCell;
	}
}

@end