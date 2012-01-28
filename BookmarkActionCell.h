/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import <Cocoa/Cocoa.h>


@protocol BookmarkBarCell;

@interface BookmarkActionCell : NSActionCell <BookmarkBarCell>
{
	NSView*				mControlView;
	
	NSColor*			mDefaultColor;
	NSColor*			mMouseOverColor;
	NSColor*			mMouseDownColor;
	
	NSTrackingRectTag	mTrackingRectTag;
	
	BOOL				mMouseOver;
	BOOL				mMouseDown;
	
	NSRect				mFrame;
}

- (id) initWithTarget: (id) target action: (SEL) action;

@end