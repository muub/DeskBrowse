/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import "SlideWindow.h"

@implementation SlideWindow

typedef int CGSConnection;
typedef int CGSWindow;
extern CGSConnection _CGSDefaultConnection();
extern OSStatus CGSGetWindowTags(const CGSConnection cid, const CGSWindow wid, int *tags, int thirtyTwo);
extern OSStatus CGSSetWindowTags(const CGSConnection cid, const CGSWindow wid, int *tags, int thirtyTwo);
extern OSStatus CGSClearWindowTags(const CGSConnection cid, const CGSWindow wid, int *tags, int thirtyTwo);

- (void)setSticky:(BOOL)flag {
	CGSConnection connectionID = _CGSDefaultConnection();
	CGSWindow winNumber = [self windowNumber];
	int allTags[0];
	int theTags[2] = {0x0002, 0};
	
	if(!CGSGetWindowTags(connectionID, winNumber, allTags, 32)) {
		if (flag) {
			CGSSetWindowTags(connectionID, winNumber, theTags, 32);
		} else {
			CGSClearWindowTags(connectionID, winNumber, theTags, 32);
      }
   }
}

#pragma mark -

- (id)initWithContentRect:(NSRect)contentRect styleMask:(unsigned int)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag {
    if(self = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO])
	{
		[self setLevel:NSNormalWindowLevel];
		[self setOpaque:NO];
		[self setBackgroundColor:[NSColor clearColor]];
		[self setAlphaValue:1.0];
		[self setHasShadow:YES];
				
		minWidth = 400.0;
	}
	
    return self;
}

- (void)dealloc
{
	[controller release];
	
    [super dealloc];
}


#pragma mark -

- (BOOL)canBecomeKeyWindow
{
	return YES;
}

- (BOOL) canBecomeMainWindow
{
	return YES;
}


#pragma mark -

/*
 * 
 *	Mouse event handlers
 *	Since we don't have a titlebar, we handle window-dragging ourselves.
 *
 */

- (void) mouseDown: (NSEvent*) theEvent
{
	currentDragMode		= DragModeNone;
    dragStartLocation	= [theEvent locationInWindow];
	NSPoint origin		= [self frame].origin;
	NSSize	size		= [self frame].size;
		
	if (((origin.x + dragStartLocation.x) < ((origin.x + size.width) - 15) && (origin.x + dragStartLocation.x) >= origin.x) && (((origin.y + dragStartLocation.y) <= (origin.y + 70))))
	{
		// Moving
		
		currentDragMode = DragModeMove;
	}
	else if (origin.y + dragStartLocation.y >= (origin.y + size.height) - 8)
	{
		if (origin.x + dragStartLocation.x >= (origin.x + size.width) - 8)
		{
			// Resizing from top right
			
			currentDragMode						= DragModeResizeFromTopRight;
			clickDistanceFromWindowEdge.width	= (origin.x + size.width) - (origin.x + dragStartLocation.x);
			clickDistanceFromWindowEdge.height	= (origin.y + size.height) - (origin.y + dragStartLocation.y);
		}
		else
		{
			// Resizing from top
			
			currentDragMode						= DragModeResizeFromTop;
			clickDistanceFromWindowEdge.height	= (origin.y + size.height) - (origin.y + dragStartLocation.y);
		}
	}
	else if (origin.x + dragStartLocation.x >= (origin.x + size.width) - 15)
	{
		if (origin.x + dragStartLocation.x >= (origin.x + size.width) - 8)
		{
			// Resizing from right
			
			currentDragMode						= DragModeResizeFromRight;
			clickDistanceFromWindowEdge.width	= (origin.x + size.width) - (origin.x + dragStartLocation.x);
		}
		
		if (origin.y + dragStartLocation.y <= origin.y + 15)
		{
			// Resizing from bottom right
						
			currentDragMode						= DragModeResizeFromBottomRight;
			clickDistanceFromWindowEdge.width	= (origin.x + size.width) - (origin.x + dragStartLocation.x);
			clickDistanceFromWindowEdge.height	= dragStartLocation.y;
		}
	}
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    if ([theEvent type] == NSLeftMouseDragged) {
        NSPoint origin;
		NSSize	size;
		NSSize	minSize;
        NSPoint newLocation;
		
		NSRect		screenRect			= [[self screen] frame];
		
		NSRect		newFrameRect		= [self frame];
		NSPoint		newOrigin			= [self frame].origin;
		NSSize		newSize				= [self frame].size;
		
        origin							= [self frame].origin;
		size							= [self frame].size;
		minSize							= [self minSize];
        newLocation						= [theEvent locationInWindow];
		
		NSSize		distanceMouseMoved = NSMakeSize(newLocation.x - size.width + clickDistanceFromWindowEdge.width, newLocation.y - clickDistanceFromWindowEdge.height);
		
        
		switch (currentDragMode)
		{
			case DragModeMove:
			{
				// Move window
				
				newOrigin.x = origin.x;
				newOrigin.y	= origin.y + newLocation.y - dragStartLocation.y;
				
				
				// Make sure we don't move past the menu bar
								
				if (newOrigin.y > origin.y)
				{
					if ((newOrigin.y + size.height) > ((screenRect.origin.y + screenRect.size.height) - 22))
					{
						newOrigin.y = ((screenRect.origin.y + screenRect.size.height) - 22) - size.height;
					}
				}
				
				break;
			}
			case DragModeResizeFromTop: // Resize from top -- CHANGED TO MOVE FROM TOP
			{
				// Move window
				
				newOrigin.x = origin.x;
				newOrigin.y	= origin.y + newLocation.y - dragStartLocation.y;
				
				
				// Make sure we don't move past the menu bar
				
				if (newOrigin.y > origin.y)
				{
					if ((newOrigin.y + size.height) > ((screenRect.origin.y + screenRect.size.height) - 22))
					{
						newOrigin.y = ((screenRect.origin.y + screenRect.size.height) - 22) - size.height;
					}
				}
				
				break;
			}
			case DragModeResizeFromTopRight: // Resize from top right
			{
				// Resize horizontally
				
				newSize.width = size.width + distanceMouseMoved.width;
				
				if (origin.x + newSize.width > screenRect.size.width)
				{
					newSize.width = screenRect.size.width - origin.x;
				}
				
				if (newSize.width < minSize.width)
				{
					newSize.width	= minSize.width;
				}
				
				
				// Resize vertically
				
				distanceMouseMoved.height	= (newLocation.y - newSize.height) + clickDistanceFromWindowEdge.height;
				newSize.height				= size.height + distanceMouseMoved.height;
				
				if (newSize.height < minSize.height)
				{
					newSize.height	= minSize.height;
				}
				
				
				// Make sure we don't resize past the menu bar
				
				if (newOrigin.y + newSize.height > (screenRect.origin.y + screenRect.size.height) - 22)
				{
					newSize.height = ((screenRect.origin.y + screenRect.size.height) - 22) - newOrigin.y;
				}
				
				break;
			}
			case DragModeResizeFromRight: // Resize from right
			{
				// Resize horizontally
				
				newSize.width = size.width + distanceMouseMoved.width;
				
				if (origin.x + newSize.width > screenRect.size.width)
				{
					newSize.width = screenRect.size.width - origin.x;
				}
				
				if (newSize.width < minSize.width)
				{
					newSize.width	= minSize.width;
				}
				
				break;
			}
			case DragModeResizeFromBottomRight: // Resize from bottom right
			{
				// Resize horizontally
				
				newSize.width = size.width + distanceMouseMoved.width;
				
				if (origin.x + newSize.width > screenRect.size.width)
				{
					newSize.width = screenRect.size.width - origin.x;
				}
				
				if (newSize.width < minSize.width)
				{
					newSize.width	= minSize.width;
				}
				
				
				// Resize vertically
				
				newSize.height	= size.height - distanceMouseMoved.height;
				newOrigin.y		= origin.y + distanceMouseMoved.height;
				
				if (newSize.height < minSize.height)
				{
					newOrigin.y		= newOrigin.y - (minSize.height - newSize.height);
					newSize.height	= minSize.height;
				}
				
				break;
			}
			default:
			{
			}
		}
		
		newFrameRect.origin		= newOrigin;
		newFrameRect.size		= newSize;
		
		[self setFrame: newFrameRect display: YES];
    }
}

- (void) mouseUp: (NSEvent*) theEvent
{
	[self saveFrame];
	
	currentDragMode	= DragModeNone;
}


#pragma mark -

- (void) saveFrame
{
	NSUserDefaults* userDefaults	= [NSUserDefaults standardUserDefaults];
	NSNumber*		y				= [NSNumber numberWithFloat: [self frame].origin.y];
	NSNumber*		width			= [NSNumber numberWithFloat: [self frame].size.width];
	NSNumber*		height			= [NSNumber numberWithFloat: [self frame].size.height];
	
	[userDefaults setValue: y		forKey:	kSlideWindowY];
	[userDefaults setValue: width	forKey:	kSlideWindowWidth];
	[userDefaults setValue: height	forKey:	kSlideWindowHeight];
}

- (void) loadFrame
{
	NSUserDefaults* userDefaults	= [NSUserDefaults standardUserDefaults];
	float			y				= [[userDefaults objectForKey: kSlideWindowY]		floatValue];
	float			width			= [[userDefaults objectForKey: kSlideWindowWidth]	floatValue];
	float			height			= [[userDefaults objectForKey: kSlideWindowHeight]	floatValue];	
	
	NSRect			newFrame		= NSMakeRect(-width, y, width, height);
	
	[self setFrame: newFrame display: YES animate: NO];
}


#pragma mark -

/* Accessor methods */

- (void) setOnScreen: (BOOL) flag
{
	NSRect	frame		= [self frame];
	NSRect	newFrame	= frame;
	NSPoint	origin		= frame.origin;
	NSSize	size		= frame.size;
	
	if (flag)
	{
		// Show window
		
		newFrame = NSMakeRect(0, origin.y, size.width, size.height);
		[self setIsVisible: flag];
		[self setFrame: newFrame display: YES animate: YES];
	}
	else
	{
		// Hide window
				
		newFrame = NSMakeRect(-size.width, origin.y, size.width, size.height);
		
		[self setFrame: newFrame display: YES animate: YES];
		[self setIsVisible: flag];
	}
}

- (void)setController:(id)aController {
	[controller release];
	controller = [aController retain];
}

@end



