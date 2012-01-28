/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import <Cocoa/Cocoa.h>


@protocol BookmarkBarCell;

@interface BookmarkMenuCell : NSPopUpButtonCell <BookmarkBarCell>
{
	NSView*				mControlView;
	
	NSString*			mStringValue;
	
	NSColor*			mDefaultColor;
	NSColor*			mMouseOverColor;
	NSColor*			mMouseDownColor;
	
	NSTrackingRectTag	mTrackingRectTag;
	
	BOOL				mMouseOver;
	BOOL				mMouseDown;
	BOOL				mPopUpMenuVisible;
	
	NSRect				mFrame;
}

@end