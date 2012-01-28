/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import "LocationTextFieldCell.h"


@interface NSTextFieldCell (Private)
- (void) _drawFocusRingWithFrame: (NSRect) rect;
- (NSRect) _focusRingFrameForFrame: (NSRect) editFrame cellFrame: (NSRect) cellFrame;
@end


const short		kImagePadding		= 3;
NSString* const kDefaultImageName	= @"DefaultLocationFieldIcon";

@implementation LocationTextFieldCell


- (id) initTextCell: (NSString*) text
{
	if (self = [super initTextCell: text])
	{
		[self setImage: [NSImage imageNamed: kDefaultImageName]];
	}
	
	return self;
}

- (void) dealloc
{
	[mImage release];
	[super dealloc];
}


#pragma mark -

- (NSImage*) image
{	
	return mImage;
}

- (void) setImage: (NSImage*) image
{
	if (image != mImage)
	{
		[image retain];
		[mImage release];
		
		mImage = image;
		
		if (mImage == nil)
		{
			mImage = [[NSImage imageNamed: kDefaultImageName] retain];
		}
		
		[mImage setScalesWhenResized: YES];
		
		[[self controlView] setNeedsDisplay: YES];
		[[self controlView] setKeyboardFocusRingNeedsDisplayInRect: [[self controlView] frame]];
	}
}

- (void) setExtraSpaceOnRight: (NSSize) extraSize
{
	mSpaceOnRight = extraSize;
	[[self controlView] setNeedsDisplay: YES];
}


#pragma mark -

- (NSRect) imageRectForFrame: (NSRect) frame
{
	return NSMakeRect(NSMinX(frame), NSMinY(frame), NSHeight(frame), NSHeight(frame));
}

- (NSRect) textRectForFrame: (NSRect) frame
{
	NSRect imageRect = [self imageRectForFrame: frame];
	
	// Hack: Subtracting kImagePadding from the origin (and adding to width) because otherwise the text is too far away from the icon. Ick.
	NSRect textRect = NSMakeRect(NSMinX(frame) + NSWidth(imageRect) - kImagePadding, NSMinY(frame), NSWidth(frame) - NSWidth(imageRect) + kImagePadding - mSpaceOnRight.width, NSHeight(frame));
	
	return textRect;
}


#pragma mark -

- (void) drawImageWithFrame: (NSRect) frameRect inView: (NSView*) controlView
{
	NSGraphicsContext* currentGraphicsContext = [NSGraphicsContext currentContext];
	
	[currentGraphicsContext saveGraphicsState];
	[currentGraphicsContext setImageInterpolation: NSImageInterpolationNone];
	
//	[[self image] setSize: frameRect.size];
//	[[self image] compositeToPoint: frameRect.origin operation: NSCompositeSourceOver];

	{
		NSSize		newImageSize	= [self imageRectForFrame: frameRect].size;
		NSImageRep* prettyImageRep	= [[self image] bestRepresentationForDevice: nil];
		NSImage*	newImage		= [[NSImage alloc] initWithSize: newImageSize];
		
		[newImage lockFocus];
		
			[[NSGraphicsContext currentContext] setImageInterpolation: NSImageInterpolationHigh];
			[prettyImageRep drawInRect: NSMakeRect(0, 0, newImageSize.width, newImageSize.height)];
		
		[newImage unlockFocus];
		
		[newImage compositeToPoint: frameRect.origin operation: NSCompositeSourceOver];
	}

	[currentGraphicsContext restoreGraphicsState];
}

- (void) drawInteriorWithFrame: (NSRect) frameRect inView: (NSView*) controlView
{
	NSRect imageRect	= [self imageRectForFrame: frameRect];
	NSRect textRect		= [self textRectForFrame: frameRect];
	
	if ([self image] != nil)
	{
		if ([[self controlView] isFlipped])
		{
			imageRect.origin.y	+= NSHeight(imageRect) - kImagePadding;
		}
		else
		{
			imageRect.origin.y	+= kImagePadding;
		}
		
		imageRect.origin.x		+= kImagePadding;
		imageRect.size.width	-= kImagePadding * 2;
		imageRect.size.height	-= kImagePadding * 2;
		
		[self drawImageWithFrame: imageRect inView: controlView];
	}
	
	[super drawInteriorWithFrame: textRect inView: controlView];
}


#pragma mark -

- (void) selectWithFrame: (NSRect) frame inView: (NSView*) controlView editor: (NSText*) editor delegate: (id) delegate start: (int) selStart length: (int) selLength
{
    [super selectWithFrame: [self textRectForFrame: frame] inView: controlView editor: editor delegate: delegate start: selStart length: selLength];
}

- (void) editWithFrame: (NSRect) frame inView: (NSView*) controlView editor: (NSText*) editor delegate: (id) delegate event: (NSEvent*) event
{
    [super editWithFrame: [self textRectForFrame: frame] inView: controlView editor: editor delegate: delegate event: event];
}

- (void) resetCursorRect: (NSRect) cellFrame inView: (NSView*) controlView
{
	[super resetCursorRect: [self textRectForFrame: cellFrame] inView: controlView];
}


@end



@implementation LocationTextFieldCell (Private)


- (void) _drawFocusRingWithFrame: (NSRect) rect
{
    [super _drawFocusRingWithFrame: rect];
}

- (NSRect) _focusRingFrameForFrame: (NSRect) editFrame cellFrame: (NSRect) cellFrame
{
	NSRect focusRingFrame		= [super _focusRingFrameForFrame: editFrame cellFrame: cellFrame];
    NSRect textRect				= [self textRectForFrame:cellFrame];
	
    focusRingFrame.origin.x		-= NSMinX(textRect) - NSMinX(cellFrame);
    focusRingFrame.size.width	+= NSWidth(cellFrame) - NSWidth(textRect);
	
    return focusRingFrame;
}


@end
