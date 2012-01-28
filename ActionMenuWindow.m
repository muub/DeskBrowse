/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/


#import "ActionMenuWindow.h"


@implementation ActionMenuWindow

- (id) initWithContentRect: (NSRect) contentRect styleMask: (unsigned int) aStyle backing: (NSBackingStoreType) bufferingType defer: (BOOL) flag
{
    if (self = [super initWithContentRect: contentRect styleMask: NSBorderlessWindowMask backing: NSBackingStoreBuffered defer: NO])
	{
//		[self setLevel: NSNormalWindowLevel + 1];
		[self setAboveMainWindowLevel: YES];
		[self setOpaque: NO];
		[self setBackgroundColor: [NSColor clearColor]];
		[self setAlphaValue: 0.0];
		[self setHasShadow: YES];
	}
    return self;
}

- (BOOL) canBecomeKeyWindow
{
	return NO;//YES;
}

- (BOOL) acceptsFirstResponder
{
	return YES;
}

- (void)mouseEntered:(NSEvent *)event {
}

- (void) orderOut: (id) sender
{
	[self setAlphaValue: 0.0];
	[super orderOut: sender];
}

@end
