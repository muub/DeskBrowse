/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/


#import <Cocoa/Cocoa.h>


@interface BezelScroller : NSScroller
{
	NSImage* topOfKnob;
	NSImage* middleOfKnob;
	NSImage* bottomOfKnob;
	
	NSImage* knobSlotTop;
	NSImage* knobSlotFiller;
	NSImage* knobSlotBottom;
}

@end
