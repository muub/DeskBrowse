/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import "TabBar.h"


@implementation TabBar


- (id) initWithFrame: (NSRect) frame
{
    if (self = [super initWithFrame:frame])
	{
        tabBarImage = [[NSImage imageNamed: @"backbar_fill.png"] retain];
		
		[tabBarImage setSize: frame.size];
		
		NSMenu *cmenu = [[NSMenu alloc] init];
		NSMenuItem *newTab = [[NSMenuItem alloc] initWithTitle:@"New Tab"
														action:@selector(askForNewTab)
												 keyEquivalent:@"t"];
		[cmenu addItem:newTab];
		
		[self setMenu:cmenu];
		
		[newTab release];
		[cmenu release];
    }
	
    return self;
}

- (void) dealloc
{
	[tabBarImage release];
	
	[super dealloc];
}

- (void) drawRect: (NSRect) rect
{
    NSRect imageRect;
	
	imageRect.origin	= NSZeroPoint;
	imageRect.size		= [tabBarImage size];
	
	[tabBarImage drawInRect: [self frame]
				   fromRect: imageRect
				  operation: NSCompositeCopy
			       fraction: 1.0];
}

- (void)askForNewTab {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"DBNewBlankTab"
														object:self
													  userInfo:nil];
}


@end
