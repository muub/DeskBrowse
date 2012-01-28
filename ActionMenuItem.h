/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import <Cocoa/Cocoa.h>


@interface ActionMenuItem : NSView {
	NSString *label;
	NSTrackingRectTag _tag;
}

- (id)initWithFrame:(NSRect)frame label:(NSString *)aLabel;

- (void)setLabel:(NSString *)aLabel;
- (NSString *)label;

@end
