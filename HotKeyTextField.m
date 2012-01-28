/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import "HotKeyTextField.h"


@implementation HotKeyTextField


// --------------------------------------
//
//	initWithCoder:
//
//
//	Last edited by: Ian
//	On:	June 3, 2005
//	At:	8:40 PM
//
// --------------------------------------

- (id) initWithCoder: (NSCoder*) coder
{
	if(self = [super initWithCoder: coder])
	{
		[self setEditable: NO];
	}
	
	return self;
}


// --------------------------------------
//
//	performKeyEquivalent:
//
//
//	Last edited by: Ian
//	On:	June 3, 2005
//	At:	8:40 PM
//
// --------------------------------------

- (BOOL) performKeyEquivalent: (NSEvent*) theEvent
{
	[self keyDown: theEvent];
	return YES;
}


// --------------------------------------
//
//	keyDown:
//
//
//	Last edited by: Ian
//	On:	June 3, 2005
//	At:	8:40 PM
//
// --------------------------------------

- (void) keyDown: (NSEvent*) theEvent
{
	if([theEvent type] == NSKeyDown)
	{
		iKeyCode	= [theEvent keyCode];
		iModifiers	= [theEvent modifierFlags];
		stringRep	= [KeyStuff stringForKeyCode: iKeyCode modifiers: iModifiers];
		
		[self setStringValue: stringRep];
	}
}


// --------------------------------------
//
//	keyCode
//
//
//	Last edited by: Ian
//	On:	June 3, 2005
//	At:	8:38 PM
//
// --------------------------------------

- (UInt32) keyCode
{
	if(![[KeyStuff stringForKeyCode: iKeyCode] length] > 0)
	{
		iKeyCode = -1;
	}
	
	return iKeyCode;
}


// --------------------------------------
//
//	setKeyCode:
//
//
//	Last edited by: Ian
//	On:	June 4, 2005
//	At:	2:05 AM
//
// --------------------------------------

- (void) setKeyCode: (UInt32) keyCode
{
	iKeyCode = keyCode;
}


// --------------------------------------
//
//	modifiers
//
//
//	Last edited by: Ian
//	On:	June 3, 2005
//	At:	8:38 PM
//
// --------------------------------------

- (UInt32) modifiers
{
	if(![[KeyStuff stringForModifiers: iModifiers] length] > 0)
	{
		iModifiers = 0;
	}
	
	return iModifiers;
}


// --------------------------------------
//
//	setModifiers:
//
//
//	Last edited by: Ian
//	On:	June 4, 2005
//	At:	2:05 AM
//
// --------------------------------------

- (void) setModifiers: (UInt32) modifiers
{
	iModifiers = modifiers;
}


// --------------------------------------
//
//	stringRepresentation
//
//
//	Last edited by: Ian
//	On:	June 3, 2005
//	At:	8:38 PM
//
// --------------------------------------

- (NSString*) stringRepresentation
{
	stringRep = [KeyStuff stringForKeyCode: iKeyCode modifiers: iModifiers];
	
	return stringRep;
}


@end
