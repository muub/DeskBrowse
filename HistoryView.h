/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import <Cocoa/Cocoa.h>

@class HistoryController;


@interface HistoryView : NSView
{
	id						delegate;
	NSColor*				textColor;
	NSColor*				selectedTextColor;
	NSColor*				finishedTextColor;
	int						textSize;
	int						selectedRow;
	NSMutableDictionary*	textAttributes;
	float						rowHeight;
	float						topPadding;
}

- (void) setDelegate: (id) object;

//

- (NSString*) string: (NSString*) string withAttributes: (NSDictionary*) attributes constrainedToWidth: (float) width;
- (void) setTextColor: (NSColor*) color;
- (void) setTextSize: (int) size;

//
- (int) selectedRow;
- (void) updateSelectedRow;
- (void) reloadData;

@end
