/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import "DBApplication.h"

#import "HotKeyController.h"
#import "DeskBrowseConstants.h"
#import "DeskBrowseController.h"


@implementation DBApplication


// --------------------------------------
//
//	init
//
// --------------------------------------

- (id) init
{
	if (self = [super init])
	{
	}
	else
	{
		NSLog(@"*** - [DBApplication init] : Failure");
	}
	
	return self;
}


// --------------------------------------
//
//	dealloc
//
// --------------------------------------

- (void) dealloc
{
	[hotKeyController	release];
	
	[super				dealloc];
}


// --------------------------------------
//
//	sendEvent:
//
// --------------------------------------

- (void) sendEvent: (NSEvent*) theEvent
{
	NSEventType type = [theEvent type];
	
	if (type == NSLeftMouseDown)
	{
		[_delegate mouseDown: theEvent];
	}
	else if (type == NSKeyDown)
	{
		[self handleKeyEvent: theEvent];
	}
	
	[super sendEvent: theEvent];
}


// --------------------------------------
//
//	handleKeyEvent:
//
// Call it handleKeyEvent so we don't accidently override the keyDown: method (which wasn't being called here, but you never know...)
//
// --------------------------------------

- (void) handleKeyEvent: (NSEvent*) theEvent
{
	NSString*	characters	= [theEvent charactersIgnoringModifiers];
	NSString*	characters1	= [theEvent characters];
	
	unsigned int modifiers	= [theEvent modifierFlags];
	
	/*
	NSLog(@"WARNING: handleKeyEvent in DBApplication STILL ALLOWS FORCE QUIT! -Ian");
	
	if ([characters isEqualToString: @"="])		//
	{											//	TEMORARY
		[NSApp endSheet: [NSApp keyWindow]];	//
		[NSApp terminate: nil];					//
	}											//
	*/
	
	if ([characters length] == 1)
	{
		if (modifiers & NSCommandKeyMask && modifiers & NSShiftKeyMask)
		{
			unichar	character = [characters characterAtIndex: 0];
			
			if (character == NSRightArrowFunctionKey)
			{
				[_delegate keyCombinationPressed: kCommandShiftRightArrow];
			}
			else if (character == NSLeftArrowFunctionKey)
			{
				[_delegate keyCombinationPressed: kCommandShiftLeftArrow];
			}
		}
		else if (modifiers & NSCommandKeyMask)
		{
			unichar	character = [characters characterAtIndex: 0];
			
			if (character == NSRightArrowFunctionKey)
			{
				[_delegate keyCombinationPressed: kCommandRightArrow];
			}
			else if (character == NSLeftArrowFunctionKey)
			{
				[_delegate keyCombinationPressed: kCommandLeftArrow];
			}
		}
	}
}


// --------------------------------------
//
//	endSheet:
//
//	Override this so we can close the window after ending its modal session.
//	I'm not sure why this isn't the default implementation.
//
// --------------------------------------

- (void) endSheet: (NSWindow*) sheet
{
	if (sheet != nil)
	{
		[super endSheet: sheet];
		[sheet orderOut: nil];
	}
}


// --------------------------------------
//
//	loadHotKeyController
//
// --------------------------------------

- (void) initHotKeyController
{
	hotKeyController = [[HotKeyController alloc] init];
}


// --------------------------------------
//
//	hotKeyController
//
// --------------------------------------

- (HotKeyController*) hotKeyController
{
	return hotKeyController;
}

@end
