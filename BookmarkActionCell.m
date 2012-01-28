/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import "BookmarkActionCell.h"

#import "BookmarkBarCell.h"
#import "NSBezierPathRoundRects.h"
#import "NSStringAdditions.h"


@implementation BookmarkActionCell


- (id) init
{
	if (self = [super init])
	{
		mDefaultColor	= [[NSColor colorWithDeviceRed: 0.0 green: 0.0 blue: 0.0 alpha: 0.0] retain];
		mMouseOverColor = [[NSColor colorWithDeviceRed: 0.7 green: 0.7 blue: 0.7 alpha: 0.4] retain];
		mMouseDownColor	= [[NSColor colorWithDeviceRed: 0.55 green: 0.55 blue: 0.55 alpha: 0.4] retain];
		
		[self setFont: [NSFont systemFontOfSize: 10.0]];
		[self sendActionOn: 0];
	}
	
	return self;
}

- (id) initWithTarget: (id) target action: (SEL) action
{
	if (self = [self init])
	{
		[self setTarget: target];
		[self setAction: action];
	}
	
	return self;
}


#pragma mark -

- (void) sendActionToTarget
{
	[[self target] performSelector: [self action] withObject: self];
}


#pragma mark -

- (void) setFrame: (NSRect) frame
{
	mFrame = frame;
	
	[self resetTrackingRect];
}

- (NSRect) frame
{
	return mFrame;
}


#pragma mark -

- (NSRect) textFrame
{
	NSRect textFrame = NSMakeRect(mFrame.origin.x + DBPaddingOnSidesOfTextFrame, mFrame.origin.y, mFrame.size.width - DBPaddingOnSidesOfTextFrame * 2, mFrame.size.height);
	
	return textFrame;
}

- (NSDictionary*) textAttributes
{
	return [NSDictionary dictionaryWithObjects: [NSArray arrayWithObjects: [NSColor blackColor], [self font], nil] forKeys: [NSArray arrayWithObjects: @"NSColor", NSFontAttributeName, nil]];
}


#pragma mark -

- (void) drawBackgroundInFrame: (NSRect) frame
{
	NSColor* backgroundColor = mDefaultColor;
		
	if (mMouseDown)
	{
		backgroundColor = mMouseDownColor;
	}
	else if (mMouseOver)
	{
		backgroundColor = mMouseOverColor;
	}
	
	[backgroundColor set];
	[NSBezierPath fillRoundRectInRect: frame radius: 15];
}

- (void) drawTextInFrame: (NSRect) frame
{
	NSRect			textFrame			= [self textFrame];
	NSDictionary*	stringAttributes	= [self textAttributes];
	NSString*		drawText			= [[self stringValue] truncatedToWidth: textFrame.size.width withAttributes: stringAttributes];
	NSSize			stringSize			= [drawText sizeWithAttributes: stringAttributes];
	
	if (stringSize.width < textFrame.size.width)
	{
		float extraWidth	= textFrame.size.width - stringSize.width;
		textFrame.origin.x	= textFrame.origin.x + extraWidth / 2;
	}
	
	if (stringSize.height < NSHeight(textFrame))
	{
		textFrame.origin.y += (NSHeight(textFrame) - stringSize.height) / 2;
	}
	
	textFrame.size.height = stringSize.height;
	
	[drawText drawInRect: textFrame withAttributes: stringAttributes];
}

- (void) drawWithFrame: (NSRect) cellFrame inView: (NSView*) controlView
{
	if (controlView != mControlView)
	{
		[controlView retain];
		[mControlView release];
		
		mControlView = controlView;
		
		[self resetTrackingRect];
	}
	else if (mTrackingRectTag == 0)
	{
		[self resetTrackingRect];
	}
	
		
	[self drawBackgroundInFrame: cellFrame];
	[self drawTextInFrame: cellFrame];
}


#pragma mark -

- (void) mouseDown: (NSEvent*) event
{
	mMouseDown = YES;
	
	[mControlView setNeedsDisplayInRect: mFrame];
}

- (void) mouseUp: (NSEvent*) event
{
	mMouseDown = NO;
	
	[self sendActionToTarget];
	
	[mControlView setNeedsDisplayInRect: mFrame];
}


#pragma mark -

- (void) mouseEntered: (NSEvent*) event
{
	mMouseOver = YES;
	
	[mControlView setNeedsDisplayInRect: mFrame];
}

- (void) mouseExited: (NSEvent*) event
{
	mMouseOver	= NO;
	mMouseDown	= NO;
	
	[mControlView setNeedsDisplayInRect: mFrame];
}

- (void) resetTrackingRect
{
	if (mTrackingRectTag > 0)
	{
		[mControlView removeTrackingRect: mTrackingRectTag];
	}
	
	NSPoint mouseLocation	= [[mControlView window] mouseLocationOutsideOfEventStream];
	BOOL	mouseInFrame	= NSMouseInRect(mouseLocation, mFrame, NO);
	
	mTrackingRectTag = [mControlView addTrackingRect: mFrame owner: self userData: nil assumeInside: mouseInFrame];
	
	
	if (mouseInFrame)
	{
		if (!mMouseOver || !mMouseDown)
		{
			[self mouseEntered: nil];
		}
	}
	else
	{
		if (mMouseOver || mMouseDown)
		{
			[self mouseExited: nil];
		}
	}
}


#pragma mark -

- (void) setStringValue: (NSString*) stringValue
{
	if (stringValue == nil)
	{
		stringValue = @"";
	}
	
	[super setStringValue: stringValue];
	
	NSRect			frame				= mFrame;
	NSDictionary*	stringAttributes	= [self textAttributes];
	NSSize			stringSize			= [[self stringValue] sizeWithAttributes: stringAttributes];
	float			desiredWidth		= stringSize.width + DBPaddingOnSidesOfTextFrame * 2;
	float			newWidth			= (desiredWidth <= DBBookmarkCellMaximumWidth) ? desiredWidth : DBBookmarkCellMaximumWidth;
	
	[self setFrame: NSMakeRect(frame.origin.x, frame.origin.y, newWidth, frame.size.height)];
}

- (void) setMenu: (NSMenu*) menu
{
	[super setMenu: menu];
}


#pragma mark -

- (NSImage*) dragImage
{
	NSImage*	dragImage	= nil;
	NSSize		imageSize	= mFrame.size;
	
	
	dragImage = [[[NSImage alloc] initWithSize: imageSize] autorelease];
	
	[dragImage lockFocus];
	{
		[self drawWithFrame: NSMakeRect(0, 0, imageSize.width, imageSize.height) inView: mControlView];
	}
	[dragImage unlockFocus];
	
	
	return dragImage;
}

- (NSMenuItem*) menuItem
{
	NSMenuItem* menuItem = [[NSMenuItem alloc] initWithTitle: [self stringValue] action: [self action] keyEquivalent: @""];
	
	[menuItem setTarget: [self target]];
	[menuItem autorelease];
	
	return menuItem;
}


@end