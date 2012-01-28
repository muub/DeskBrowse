/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

/* SlideWindow */

#import <Cocoa/Cocoa.h>
#import <ApplicationServices/ApplicationServices.h>

#import "DeskBrowseConstants.h"

typedef enum
{
	DragModeNone = 0,
	DragModeMove,
	DragModeResizeFromTop,
	DragModeResizeFromRight,
	DragModeResizeFromTopRight,
	DragModeResizeFromBottomRight
} DragMode;

@interface SlideWindow : NSWindow
{
	BOOL		snapsToEdges;		/* whether or not the window snaps to edges */
    float		snapTolerance;	/* distance from edge within which snapping occurs */
    BOOL		snapping;		/* whether we're currently snapping to an edge */
    NSPoint		dragStartLocation;	/* keeps track of last drag's mousedown point */
    float		padding;
	float		minWidth;
	NSSize		clickDistanceFromWindowEdge;
	DragMode	currentDragMode;
	id			controller;
}

- (void) saveFrame;
- (void) loadFrame;

	/* Accessor methods */
- (void) setOnScreen: (BOOL) flag;

- (void)setSticky:(BOOL)flag;

- (void)setController:(id)aController;

@end

