/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import <Cocoa/Cocoa.h>

#import "KeyStuff.h"


@interface HotKeyTextField : NSTextField
{
	UInt32		iKeyCode;
	UInt32		iModifiers;
	NSString*	stringRep;
}

- (UInt32) keyCode;
- (void) setKeyCode: (UInt32) keyCode;
- (UInt32) modifiers;
- (void) setModifiers: (UInt32) modifiers;
- (NSString*) stringRepresentation;

@end
