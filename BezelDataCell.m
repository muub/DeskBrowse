/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/


#import "BezelDataCell.h"


@implementation BezelDataCell

- (id) init
{
	if (self = [super init])
	{
		[self setFocusRingType: NSFocusRingTypeNone];
	}
	
	return self;
}

- (void) drawInteriorWithFrame: (NSRect) cellFrame inView: (NSView*) controlView
{
//	NSMutableDictionary *attrs = [NSMutableDictionary dictionaryWithDictionary:[[self attributedStringValue] attributesAtIndex:0 effectiveRange:NULL]];
	NSMutableDictionary *attrs = [NSMutableDictionary dictionary];

	if ([self isHighlighted])
	{
		[attrs setValue: [NSColor whiteColor] forKey: @"NSColor"];
	}
	else
	{
		[attrs setValue: [NSColor colorWithDeviceRed: 0.8 green: 0.8 blue: 0.8 alpha: 1.0] forKey: @"NSColor"];
	}
	
	[attrs setValue: [self font] forKey: NSFontAttributeName];
	
	NSRect		drawFrame	= NSMakeRect(cellFrame.origin.x + 10, cellFrame.origin.y, cellFrame.size.width - 20, cellFrame.size.height);
	NSString*	drawString	= [[self stringValue] truncatedToWidth: drawFrame.size.width withAttributes: attrs];
	
	[drawString drawInRect: drawFrame withAttributes: attrs];
}

- (NSColor*) highlightColorWithFrame: (NSRect) cellFrame inView: (NSView*) controlView
{
	return [NSColor colorWithDeviceRed: 0.0 green: 0.0 blue: 0.0 alpha: 0.77];
}


@end