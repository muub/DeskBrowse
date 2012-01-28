/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import <Cocoa/Cocoa.h>


extern NSString*	DBBookmarkCellPboardType;
extern float		DBBookmarkCellMaximumWidth;
extern float		DBPaddingOnSidesOfTextFrame;

@protocol BookmarkBarCell

- (void) setFrame: (NSRect) frame;
- (NSRect) frame;

- (void) setStringValue: (NSString*) stringValue;
- (void) setMenu: (NSMenu*) menu;

- (void) mouseDown: (NSEvent*) event;
- (void) mouseUp: (NSEvent*) event;

- (void) drawWithFrame: (NSRect) frameRect inView: (NSView*) controlView;

- (NSImage*) dragImage;
- (NSMenuItem*) menuItem;

- (void) resetTrackingRect;

@end