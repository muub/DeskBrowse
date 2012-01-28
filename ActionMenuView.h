/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/


#import <Cocoa/Cocoa.h>
#import "ActionMenuItem.h"


@interface ActionMenuView : NSView {
	NSImage *bgImage;
	float opacity;
	ActionMenuItem *history;
	ActionMenuItem *downloads;
	ActionMenuItem *bookmarks;
	ActionMenuItem *webspose;
}

@end
