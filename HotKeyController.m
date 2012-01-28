/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/


#import "HotKeyController.h"

#import "WindowLevel.h"


@implementation HotKeyController


//-------------------------------------
//
//	MyHotKeyHandler()
//
//
//	Last edited by: Ian
//	On:	June 3, 2005
//	At:	6:22 PM
//
//-------------------------------------

pascal OSStatus HotKeyHandler(EventHandlerCallRef nextHandler, EventRef theEvent, void* userData)
{
	EventHotKeyID		theHotKeyID;
	OSStatus			theError;

	theError = GetEventParameter(theEvent, kEventParamDirectObject, typeEventHotKeyID, NULL, sizeof(EventHotKeyID), NULL, &theHotKeyID );

	if(theError == noErr)
	{
		UInt32 theEventKind = GetEventKind(theEvent);
		
		if(theEventKind == kEventHotKeyPressed)
		{			
			if(theHotKeyID.signature == sbHotKeyID.signature && theHotKeyID.id == sbHotKeyID.id)
			{				
				if(sbInvocation)
				{
					[[sbInvocation target] performSelector: [sbInvocation selector]];
				}
				else
				{
					NSLog(@"No SlideBrowse hot key listener");
				}
			}
			else if(theHotKeyID.signature == wbHotKeyID.signature && theHotKeyID.id == wbHotKeyID.id)
			{				
				if(wbInvocation)
				{
					[[wbInvocation target] performSelector: [wbInvocation selector]];
				}
				else
				{
					NSLog(@"No Webspose hot key listener");
				}
			}
		}
	}

	return theError;
}


//-------------------------------------
//
//	init
//
//
//	Last edited by: Ian
//	On:	June 6, 2005
//	At:	4:20 PM
//
//-------------------------------------

- (id) init
{
	if(self = [super init])
	{
		sbHotKeyIdentifier		= 'DBSB';
		wbHotKeyIdentifier		= 'DBWB';
		
		eventType.eventClass	= kEventClassKeyboard;
		eventType.eventKind		= kEventHotKeyPressed;
		
		sbHotKeyID.signature	= sbHotKeyIdentifier;
		sbHotKeyID.id			= 1;
		
		wbHotKeyID.signature	= wbHotKeyIdentifier;
		wbHotKeyID.id			= 2;
		
		InstallApplicationEventHandler(&HotKeyHandler, 1, &eventType, NULL, NULL);

		[self loadHotKeysFromPrefs];
	}
	
	return self;
}


//-------------------------------------
//
//	dealloc
//
//
//	Last edited by: Ian
//	On:	June 3, 2005
//	At:	6:20 PM
//
//-------------------------------------

- (void) dealloc
{
	[wbInvocation	release];
	[sbInvocation	release];
	
	[super			dealloc];
}


//-------------------------------------
//
//	setSlideBrowseListener:selector:
//
//
//	Last edited by: Ian
//	On:	June 3, 2005
//	At:	6:40 PM
//
//-------------------------------------

- (void) setSlideBrowseListener: (id) listener selector: (SEL) selector
{
	if(listener && selector)
	{
		NSMethodSignature*	signature;
		NSInvocation*		invocation;

		signature	= [[listener class]	instanceMethodSignatureForSelector:	selector];
		invocation	= [NSInvocation	invocationWithMethodSignature: signature];
		
		[invocation setSelector:	selector];
		[invocation setTarget:		listener];
		
		[sbInvocation release];
		sbInvocation = [invocation retain];
	}
	else
	{
		NSLog(@"Missing argument %@ for [DBApplication setSlideBrowseListener:selector:]", listener ? @"1" : @"0");
	}
}


//-------------------------------------
//
//	setWebsposeListener:selector:
//
//
//	Last edited by: Ian
//	On:	June 3, 2005
//	At:	6:40 PM
//
//-------------------------------------

- (void) setWebsposeListener: (id) listener selector: (SEL) selector
{
	if(listener && selector)
	{
		NSMethodSignature*	signature;
		NSInvocation*		invocation;

		signature	= [[listener class]	instanceMethodSignatureForSelector:	selector];
		invocation	= [NSInvocation	invocationWithMethodSignature: signature];
		
		[invocation setSelector:	selector];
		[invocation setTarget:		listener];
		
		[wbInvocation release];
		wbInvocation = [invocation retain];
	}
	else
	{
		NSLog(@"Missing argument %@ for [DBApplication setWebsposeListener:selector:]", listener ? @"1" : @"0");
	}
}


//-------------------------------------
//
//	getNewSlideBrowseHotKey
//
//
//	On:	December 12, 2005
//	At:	10:00 PM
//	At:	9:06 PM
//
//-------------------------------------

- (void) getNewSlideBrowseHotKey
{
	if (!mainWindow)
	{
		if (![NSBundle loadNibNamed: @"HotKey" owner: self])
		{
			NSLog(@"Failed to load HotKey nib");
		}
	}
	
	[self unregisterHotKeys];
	
	[typeField	setStringValue: @"Change SlideBrowse Hot Key(s)"];
	
	[keysField	setStringValue: [self currentSBKeyString]];
	[keysField	setKeyCode:		sbKeyCode];
	[keysField	setModifiers:	sbModifiers];
	
	
	/*___________ Start listening for key events ___________*/
	
	[NSApp beginSheet: mainWindow modalForWindow: [NSApp keyWindow] modalDelegate: self didEndSelector: nil contextInfo: nil];
	[NSApp runModalForWindow: mainWindow];
	
	// Modal is running now...
	
	[NSApp endSheet: mainWindow];
	
	/*___________ Stop listening for key events ___________*/
	
	
	if(save)
	{
		UInt32 newKeyCode	= [keysField keyCode];
		UInt32 newMods		= [keysField modifiers];

		if(newKeyCode == wbKeyCode && newMods == wbModifiers)
		{
			wbKeyCode	= -1;
			wbModifiers = 0;
		}
		
		sbKeyCode			= newKeyCode;
		sbModifiers			= newMods;
		
		[self saveHotKeysToPrefs];
	}
	
	[self registerHotKeys];
}


//-------------------------------------
//
//	getNewWebsposeHotKey
//
//
//	Last edited by: Ian
//	On:	December 12, 2005
//	At:	10:00 PM
//
//-------------------------------------

- (void) getNewWebsposeHotKey
{
	if (mainWindow == nil)
	{
		if (![NSBundle loadNibNamed: @"HotKey" owner: self])
		{
			NSLog(@"Failed to load HotKey nib");
		}
	}
	
	[self unregisterHotKeys];
	
	[typeField	setStringValue: @"Change Webspose Hot Key(s)"];
	
	[keysField	setStringValue: [self currentWBKeyString]];
	[keysField	setKeyCode:		wbKeyCode];
	[keysField	setModifiers:	wbModifiers];
	
	
	/*___________ Start listening for key events ___________*/
	
	[NSApp beginSheet: mainWindow modalForWindow: [NSApp keyWindow] modalDelegate: self didEndSelector: nil contextInfo: nil];
	[NSApp runModalForWindow: mainWindow];
	
	// Modal is running now...
	
	[NSApp endSheet: mainWindow];
	
	/*___________ Stop listening for key events ___________*/
	
	
	if (save)
	{
		UInt32 newKeyCode	= [keysField keyCode];
		UInt32 newMods		= [keysField modifiers];

		if(newKeyCode == sbKeyCode && newMods == sbModifiers)
		{
			sbKeyCode	= -1;
			sbModifiers = 0;
		}
		
		wbKeyCode			= newKeyCode;
		wbModifiers			= newMods;
		
		[self saveHotKeysToPrefs];
	}
	
	[self registerHotKeys];
}


//-------------------------------------
//
//	loadHotKeysFromPrefs
//
//
//	Last edited by: Ian
//	On:	June 3, 2005
//	At:	6:09 PM
//
//-------------------------------------

- (void) loadHotKeysFromPrefs;
{
	NSUserDefaults*	userDefaults	= [NSUserDefaults standardUserDefaults];
	wbKeyCode						= [userDefaults integerForKey: kWebsposeHotKey];
	sbKeyCode						= [userDefaults integerForKey: kSlideBrowseHotKey];
	wbModifiers						= [userDefaults integerForKey: kWebsposeModifiers];
	sbModifiers						= [userDefaults integerForKey: kSlideBrowseModifiers];

	if (wbModifiers < 0 || sbModifiers < 0)
	{
		NSLog(@"Modifier keys must be at least 0");
	}
	
	[self unregisterHotKeys];
	[self registerHotKeys];
}


//-------------------------------------
//
//	saveHotKeysToPrefs
//
//
//	Last edited by: Ian
//	On:	June 3, 2005
//	At:	6:09 PM
//
//-------------------------------------

- (void) saveHotKeysToPrefs;
{
	NSUserDefaults*	userDefaults = [NSUserDefaults standardUserDefaults];
	
	[userDefaults setInteger: wbKeyCode		forKey: kWebsposeHotKey];
	[userDefaults setInteger: sbKeyCode		forKey: kSlideBrowseHotKey];
	[userDefaults setInteger: wbModifiers	forKey: kWebsposeModifiers];
	[userDefaults setInteger: sbModifiers	forKey: kSlideBrowseModifiers];
}


//-------------------------------------
//
//	registerHotKeys
//
//
//	Last edited by: Ian
//	On:	June 3, 2005
//	At:	6:41 PM
//
//-------------------------------------

- (void) registerHotKeys
{
	[self unregisterHotKeys];
	
	if (wbKeyCode != -1)
	{
		RegisterEventHotKey(wbKeyCode, sbModifiers, wbHotKeyID, GetApplicationEventTarget(), 0, &wbHotKeyRef);
	}
	
	if (sbKeyCode != -1)
	{
		RegisterEventHotKey(sbKeyCode, sbModifiers, sbHotKeyID, GetApplicationEventTarget(), 0, &sbHotKeyRef);
	}
}


//-------------------------------------
//
//	unregisterHotKeys
//
//
//	Last edited by: Ian
//	On:	June 3, 2005
//	At:	6:41 PM
//
//-------------------------------------

- (void) unregisterHotKeys
{
	UnregisterEventHotKey(wbHotKeyRef);
	UnregisterEventHotKey(sbHotKeyRef);
}


//-------------------------------------
//
//	listenForKeyEvents
//
//
//	Last edited by: Ian
//	On:	June 3, 2005
//	At:	6:09 PM
//
//-------------------------------------

- (void) listenForKeyEvents
{
	BOOL stop = NO;
	
    while (!stop)
    {
        EventRecord theEvent;
		
        if (WaitNextEvent(everyEvent, &theEvent, 0, NULL))
        {
            switch (theEvent.what)
            {
                case keyDown:
                case keyUp:
                case autoKey:
                {
                    UInt16       asciiKeyCode       = ((theEvent.message) >> 8)   & 0xFF;
                    UInt16       virtualKeyCode     = ((theEvent.message) >> 8)   & 0xFF;
                    UInt32       modifierKeyState   = ((theEvent.modifiers) >> 8) & 0xFF;
					
					[keysField setStringValue: [KeyStuff stringForKeyCode: virtualKeyCode modifiers: modifierKeyState]];
                    NSLog(@"For key %d ('%c') the virtual keycode is: %d with modifiers: %d\n", asciiKeyCode, asciiKeyCode, virtualKeyCode, modifierKeyState);
                }
                break;
                case mouseDown:
                {
                    stop = true;
                }
                break;
            }
        }
    }
}


// --------------------------------------
//
//	currentSBKeyString
//
//
//	Last edited by: Ian
//	On:	June 3, 2005
//	At:	9:35 PM
//
// --------------------------------------

- (NSString*) currentSBKeyString
{
	NSString* keyString = [KeyStuff stringForKeyCode: sbKeyCode modifiers: sbModifiers];
	
	if (!keyString)
	{
		keyString = @"";
	}
	
	return keyString;
}


// --------------------------------------
//
//	currentWBKeyString
//
//
//	Last edited by: Ian
//	On:	June 3, 2005
//	At:	9:35 PM
//
// --------------------------------------

- (NSString*) currentWBKeyString
{
	NSString* keyString = [KeyStuff stringForKeyCode: wbKeyCode modifiers: wbModifiers];
	
	if (!keyString)
	{
		keyString = @"";
	}
	
	return keyString;
}


// --------------------------------------
//
//	ok:
//
//
//	Last edited by: Ian
//	On:	December 12, 2005
//	At:	6:00 PM
//
// --------------------------------------

- (IBAction) ok: (id) sender
{
	[NSApp stopModal];
	save = YES;
}


// --------------------------------------
//
//	cancel:
//
//
//	Last edited by: Ian
//	On:	December 12, 2005
//	At:	6:00 PM
//
// --------------------------------------

- (IBAction) cancel: (id) sender
{
	[NSApp stopModal];
	save = NO;
}


@end