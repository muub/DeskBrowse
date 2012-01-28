/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import <Cocoa/Cocoa.h>


@interface LocationTextFieldCell : NSTextFieldCell
{
@private
	NSImage*	mImage;
	NSSize		mSpaceOnRight;
}

- (void) setExtraSpaceOnRight: (NSSize) extraSize;

@end
