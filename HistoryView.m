/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import "HistoryView.h"

#import "HistoryController.h"


@implementation HistoryView


////-------------------------------------------------
//		initWithFrame:
////-------------------------------------------------

- (id) initWithFrame: (NSRect) frame
{
	if(self = [super initWithFrame: frame])
	{
		textColor				= [[NSColor colorWithDeviceRed: 0.8 green: 0.8 blue: 0.8 alpha: 1.0] retain];
		selectedTextColor		= [[NSColor whiteColor] retain];
		finishedTextColor		= [[NSColor colorWithDeviceRed: 0.8 green: 0.8 blue: 0.8 alpha: 0.5] retain];
		
		textSize				= 10;
		textAttributes			= [[NSMutableDictionary alloc] init];
		
		rowHeight				= 18;
		topPadding				= 30;
		
		[textAttributes setValue: textColor								forKey: NSForegroundColorAttributeName];
		[textAttributes setValue: [NSFont systemFontOfSize: textSize]	forKey: NSFontAttributeName];
		
		selectedRow				= -1;
	}
	
	return self;
}


////-------------------------------------------------
//		acceptsFirstResponder
////-------------------------------------------------

- (BOOL) acceptsFirstResponder
{
	return YES;
}


////-------------------------------------------------
//		dealloc
////-------------------------------------------------

- (void) dealloc
{
	[delegate			release];
	[textColor			release];
	[selectedTextColor	release];
	[finishedTextColor	release];
	[textAttributes		release];
	
	[super dealloc];
}


////-------------------------------------------------
//		setDelegate:
////-------------------------------------------------

- (void) setDelegate: (id) object
{
	[delegate release];
	delegate = [object retain];
	[self setNeedsDisplay: YES];
}


////-------------------------------------------------
//		drawRect:
////-------------------------------------------------

- (void) drawRect: (NSRect) rect
{
	if (delegate != nil)
	{
		NSRect			displayArea			= NSMakeRect([self frame].origin.x + 20, [self frame].origin.y, [self frame].size.width - 40, [self frame].size.height);
		NSRect			dateArea			= NSMakeRect(displayArea.origin.x, displayArea.origin.y, displayArea.size.width, displayArea.size.height);
		NSRect			pageArea			= NSMakeRect(displayArea.origin.x + 20, displayArea.origin.y, displayArea.size.width - 20, displayArea.size.height);
		
		int				dates				= [delegate numberOfDates];
		
		int				itemsForCurrentDate	= 0;
		int				currentDrawRow		= 1;
		NSCalendarDate*	currentDate			= nil;
		NSString*		pageString			= nil;
		NSString*		dateString			= nil;

		int i;
		int j;

		// Draw history items
		for (i = 0; i < dates; i++)
		{
			if(currentDrawRow == selectedRow)
			{
				[textAttributes setValue: selectedTextColor forKey: NSForegroundColorAttributeName];
			}
			else
			{
				[textAttributes setValue: textColor forKey: NSForegroundColorAttributeName];
			}
			
			currentDate		= [delegate dateAtIndex: i];
			dateString		= [currentDate descriptionWithCalendarFormat: @"%m/%d/%Y"];
			dateString		= [self string: dateString withAttributes: textAttributes constrainedToWidth: dateArea.size.width];
			
			[dateString drawAtPoint: NSMakePoint(dateArea.origin.x, dateArea.size.height - (currentDrawRow * rowHeight))	withAttributes: textAttributes];

			itemsForCurrentDate = [delegate numberOfItemsForDate: currentDate];
			currentDrawRow		+= 1;
			
			for (j = 0; j < itemsForCurrentDate; j++)
			{
				if(currentDrawRow == selectedRow)
				{
					[textAttributes setValue: selectedTextColor forKey: NSForegroundColorAttributeName];
				}
				else
				{
					[textAttributes setValue: textColor forKey: NSForegroundColorAttributeName];
				}
				
				pageString		= [delegate objectForDate: currentDate index: j]; 
				pageString		= [self string: pageString withAttributes: textAttributes constrainedToWidth: pageArea.size.width];
				
				[pageString drawAtPoint: NSMakePoint(pageArea.origin.x, pageArea.size.height - (currentDrawRow * rowHeight))	withAttributes: textAttributes];
				
				currentDrawRow	+= 1;
			}
		}
	}
}


////-------------------------------------------------
//		string:withAttributes:contstrainedToWidth:
////-------------------------------------------------

- (NSString*) string: (NSString*) string withAttributes: (NSDictionary*) attributes constrainedToWidth: (float) width
{
	NSString*	fixedString		= string;
	NSString*	currentString	= [string stringByAppendingString: @"..."];
	NSSize		stringSize		= [currentString sizeWithAttributes: attributes];
	
	if(stringSize.width > width)
	{
		int i = [string length];
		while([currentString sizeWithAttributes: attributes].width > width)
		{
			if(i > 0)
			{
				currentString = [[string substringToIndex: i] stringByAppendingString: @"..."];
				i--;
			}
			else
			{
				currentString = @"";
				break;
			}
		}
		
		fixedString = currentString;
	}
	
	return fixedString;
}


////-------------------------------------------------
//		setTextColor:
////-------------------------------------------------

- (void) setTextColor: (NSColor*) color
{
	[textColor release];
	textColor = [color retain];
	
	[textAttributes setValue: textColor forKey: NSForegroundColorAttributeName];
}


////-------------------------------------------------
//		setTextSize:
////-------------------------------------------------

- (void) setTextSize: (int) size
{
	textSize = size;
	
	[textAttributes setValue: [NSFont systemFontOfSize: textSize] forKey: NSFontAttributeName];
}


////-------------------------------------------------
//		mouseDown:
////-------------------------------------------------

- (void) mouseDown: (NSEvent*) theEvent
{
	if(delegate != nil)
	{
		NSPoint	origin		= [self frame].origin;
		NSPoint clickPoint	= [self convertPoint: [theEvent locationInWindow] fromView: nil];
		float	clickPointY	= (([self frame].origin.y + [self frame].size.height) - 5) - clickPoint.y;
		
		selectedRow			= ceil(clickPointY / rowHeight);
		
		if (selectedRow > [delegate numberOfRows] || [delegate isDateAtIndex: selectedRow - 1])
		{
			selectedRow	= -1;
		}
		else
		{
			[delegate rowClicked: selectedRow];
		}
		
		if ([theEvent clickCount] > 1 && selectedRow > -1) {
			[delegate loadSelected];
		}

		[self setNeedsDisplay: YES];
	}
}


////-------------------------------------------------
//		keyDown:
////-------------------------------------------------

- (void) keyDown: (NSEvent*) theEvent
{
	int		row			= [self selectedRow];
	int		keyCode		= [theEvent keyCode];
	unichar	character	= [KeyStuff characterForKeyCode: keyCode];

	if(row > -1)
	{
		if(character == NSDeleteFunctionKey)
		{
			[delegate removeSelected];
		}
	}
}


////-------------------------------------------------
//		reloadData:
////-------------------------------------------------

- (void) reloadData
{
	if (delegate != nil)
	{
		[self updateSelectedRow];
		
		float newHeight = ([delegate numberOfRows] * rowHeight);
		
		if ([[self enclosingScrollView] frame].size.height > newHeight)
		{
			newHeight = [[self enclosingScrollView] frame].size.height;
		}
		
		[self setFrame: NSMakeRect([self frame].origin.x, [self frame].origin.y, [self frame].size.width, newHeight)];
		
		[self setNeedsDisplay: YES];
	}
	else
	{
		NSLog(@"HistoryController has no delegate");
	}
}

- (int) selectedRow
{
	return selectedRow;
}

- (void) updateSelectedRow
{
	int numberOfRows = [delegate numberOfRows];
	
	if(selectedRow > numberOfRows - 1 || [delegate isDateAtIndex: selectedRow - 1])
	{
		selectedRow = -1;
	}
}


@end
