/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import "LocationTextField.h"

#import "LocationTextFieldCell.h"


@interface LocationTextField (Private)
- (void) frameDidChange: (NSNotification*) notification;
- (NSRect) progressIndicatorRectForFrame: (NSRect) frame;
@end


const short kProgressIndicatorPadding = 3;

@implementation LocationTextField


+ (void) initialize
{
	if (self == [LocationTextField class])
	{
		[self setCellClass: [LocationTextFieldCell class]];
	}
}

+ (id) cellClass
{
	return [LocationTextFieldCell class];
}


#pragma mark -

- (void) awakeFromNib
{
	[self setImage: [NSImage imageNamed: @"TestImage"]];
	
	[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(frameDidChange:) name: NSViewFrameDidChangeNotification object: self];
	
	
	mProgressIndicator = [[NSProgressIndicator alloc] initWithFrame: NSZeroRect];
	
	[mProgressIndicator setStyle: NSProgressIndicatorSpinningStyle];
	[mProgressIndicator setDisplayedWhenStopped: NO];
	
	[self addSubview: mProgressIndicator];
}

- (void) dealloc
{
	[mProgressIndicator release];
	[super dealloc];
}


#pragma mark -

- (BOOL) isFlipped
{
	return YES;
}


#pragma mark -

- (NSRect) progressIndicatorRectForFrame: (NSRect) frame
{
	return NSMakeRect(NSWidth(frame) - NSHeight(frame), 0, NSHeight(frame), NSHeight(frame));
}

- (void) animate: (BOOL) animate
{
	if (animate)
	{
		[mProgressIndicator startAnimation: nil];
		[[self cell] setExtraSpaceOnRight: [self progressIndicatorRectForFrame: [self frame]].size];
	}
	else
	{
		[mProgressIndicator stopAnimation: nil];
		[[self cell] setExtraSpaceOnRight: NSZeroSize];
	}
}

- (void) setImage: (NSImage*) image
{
	[[self cell] setImage: image];
}


#pragma mark -

- (void) frameDidChange: (NSNotification*) notification
{
	NSRect spinnerRect = [self progressIndicatorRectForFrame: [self frame]];
	
	[[self cell] setExtraSpaceOnRight: spinnerRect.size];
	
	spinnerRect.origin.y	+= kProgressIndicatorPadding;
	spinnerRect.origin.x	+= kProgressIndicatorPadding;
	spinnerRect.size.width	-= kProgressIndicatorPadding << 1;
	spinnerRect.size.height	-= kProgressIndicatorPadding << 1;
	
	[mProgressIndicator setFrame: spinnerRect];
}


@end
