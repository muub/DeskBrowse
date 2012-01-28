/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

static NSImage*	selectedTabFill;
static NSImage*	selectedTabRight;
static NSImage*	selectedTabLeft;

static NSImage*	unselectedTabFill;
static NSImage*	unselectedTabRight;
static NSImage*	unselectedTabLeft;

static NSImage*	tabClose;
static NSImage*	tabCloseMouseOver;
static NSImage*	tabCloseMouseDown;

static BOOL		tabImagesInitialized;


@interface Tab : NSView
{
	NSString*	label;
	BOOL		selected;
	BOOL		mouseOver;
	BOOL		mouseOverClose;
	BOOL		mouseDownClose;
	
	NSTrackingRectTag	trackingRectTag;
	
	// WebView information
	NSImage*	favicon;
	NSString*	status;
	NSString*	URLString;
	NSString*	title;
	BOOL		loading;
}

- (void) drawTabInRect: (NSRect) rect;
- (void) drawCloseButtonInRect: (NSRect) rect;
- (NSRect) rectForCloseButton;
- (BOOL) pointInCloseButton: (NSPoint) point;
- (void) drawLabelInRect: (NSRect) rect;

- (void) setLabel: (NSString*) newLabel;
- (void) setSelected: (BOOL) flag;

- (NSString*) label;
- (BOOL)selected;

- (void)sendCloseNotification;
- (void)closeAll;
- (void)reload;
- (void)reloadAll;

- (void) resetTrackingRect;
- (void) frameDidChange: (NSNotification*) notification;

// WebView information
- (void) setFavicon: (NSImage*) newFavicon;
- (NSImage*) favicon;
- (void) setStatus: (NSString*) newStatus;
- (NSString*) status;
- (void) setURLString: (NSString*) newURLString;
- (NSString*) URLString;
- (void) setTitle: (NSString*) newTitle;
- (NSString*) title;
- (void) setLoading: (BOOL) flag;
- (BOOL) loading;

@end
