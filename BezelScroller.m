/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/


#import "BezelScroller.h"


@implementation BezelScroller


- (id) init
{
	if(self = [super init])
	{
		topOfKnob		= [[NSImage imageNamed: @"scrbartop.png"] retain];
		middleOfKnob	= [[NSImage imageNamed: @"scrbarcenter.png"] retain];
		bottomOfKnob	= [[NSImage imageNamed: @"scrbarbottom.png"] retain];
		
		knobSlotTop		= [[NSImage imageNamed: @"scrbgtop.png"] retain];
		knobSlotFiller	= [[NSImage imageNamed: @"scrbgcenter.png"] retain];
		knobSlotBottom	= [[NSImage imageNamed: @"scrbgbottom.png"] retain];
				
		[topOfKnob		setScalesWhenResized: YES];
		[middleOfKnob	setScalesWhenResized: YES];
		[bottomOfKnob	setScalesWhenResized: YES];
				
		[knobSlotTop	setScalesWhenResized: NO];
		[knobSlotFiller	setScalesWhenResized: NO];
		[knobSlotBottom	setScalesWhenResized: NO];
		
		sFlags.arrowsLoc = NSScrollerArrowsNone;
	}
	
	return self;
}

- (void) dealloc
{
	[topOfKnob		release];
	[middleOfKnob	release];
	[bottomOfKnob	release];
		
	[knobSlotTop	release];
	[knobSlotFiller	release];
	[knobSlotBottom	release];
	
	[super dealloc];
}


- (void) drawRect: (NSRect) rect
{
	NSRect		backgroundRect	= NSMakeRect(0, 0, [self frame].size.width, [self frame].size.height);
	NSColor*	backgroundColor = [NSColor colorWithDeviceRed: 0.0 green: 0.0 blue: 0.0 alpha: 0.77];	
	[backgroundColor set];
	NSRectFill(backgroundRect);
	
	
	NSRect slotRect		= [self rectForPart: NSScrollerKnobSlot];
	
	NSSize topSize		= NSMakeSize(slotRect.size.width, [knobSlotTop size].height);
	NSSize bottomSize	= NSMakeSize(slotRect.size.width, [knobSlotBottom size].height);
	NSSize fillerSize	= NSMakeSize(slotRect.size.width, slotRect.size.height - (bottomSize.height + topSize.height));
	
	[knobSlotTop setSize: topSize];
	[knobSlotBottom setSize: bottomSize];
	[knobSlotFiller setSize: fillerSize];
	
	[knobSlotBottom drawAtPoint: NSMakePoint(slotRect.origin.x, slotRect.origin.y) fromRect: NSMakeRect(0, 0, bottomSize.width, bottomSize.height) operation: NSCompositeSourceOver fraction: 1.0];
	[knobSlotFiller drawAtPoint: NSMakePoint(slotRect.origin.x, slotRect.origin.y + bottomSize.height) fromRect: NSMakeRect(0, 0, fillerSize.width, fillerSize.height) operation: NSCompositeCopy fraction: 1.0];
	[knobSlotTop drawAtPoint: NSMakePoint(slotRect.origin.x, (slotRect.origin.y + slotRect.size.height) - topSize.height) fromRect: NSMakeRect(0, 0, topSize.width, topSize.height) operation: NSCompositeSourceOver fraction: 1.0];
	
	/*[knobSlot drawAtPoint: slotRect.origin fromRect: slotRect operation: NSCompositeCopy fraction: 1.0];*/
	
	[self drawKnob];
}

- (void) drawKnob
{	
	NSRect knobRect = [self rectForPart: NSScrollerKnob];

	[topOfKnob		setSize: NSMakeSize(knobRect.size.width, 6.0)];
	[middleOfKnob	setSize: NSMakeSize(knobRect.size.width, knobRect.size.height - 12.0)];
	[bottomOfKnob	setSize: NSMakeSize(knobRect.size.width, 6.0)];
	
	[topOfKnob		drawAtPoint: NSMakePoint(knobRect.origin.x, (knobRect.origin.y + knobRect.size.height) - 6.0)	fromRect: NSMakeRect(0, 0, knobRect.size.width, 6.0)							operation: NSCompositeSourceOver fraction: 1.0];
	[middleOfKnob	drawAtPoint: NSMakePoint(knobRect.origin.x, knobRect.origin.y + 6.0)							fromRect: NSMakeRect(0, 0, knobRect.size.width, knobRect.size.height - 12.0)	operation: NSCompositeSourceOver fraction: 1.0];
	[bottomOfKnob	drawAtPoint: NSMakePoint(knobRect.origin.x, knobRect.origin.y)									fromRect: NSMakeRect(0, 0, knobRect.size.width, 6.0)							operation: NSCompositeSourceOver fraction: 1.0];
}

/*- (void) drawArrow: (NSScrollerArrow) arrow highlight: (BOOL) flag
{
	NSRect arrowRect = [self rectForPart: NSScrollerIncrementLine];
	  
	[[NSColor yellowColor] set];
	[NSBezierPath fillRect: arrowRect];
  
	arrowRect.origin.x		+= 1.0;
	arrowRect.size.width	-= 2.0;
	arrowRect.origin.y		+= 2.0;
	arrowRect.size.height	-= 3.0;

	[[NSColor blackColor] set];
	[NSBezierPath fillRect: arrowRect];

	arrowRect = [self rectForPart: NSScrollerDecrementLine];
	
	[[NSColor yellowColor] set];
	[NSBezierPath fillRect:arrowRect];

	arrowRect.origin.x		+= 1.0;
	arrowRect.size.width	-= 2.0;
	arrowRect.origin.y		+= 1.0;
	arrowRect.size.height	-= 1.0;
	
	[[NSColor blackColor] set];
	[NSBezierPath fillRect: arrowRect];
}*/


@end
