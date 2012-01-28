/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import <Cocoa/Cocoa.h>

#import "LeveledWindow.h"


@interface BezelWindow : LeveledWindow
{
	NSPoint	dragStartLocation;
	NSView*	subview;
	BOOL	resizing;
	BOOL	moving;
	NSSize	clickDistanceFromWindowEdge;
}

@end
