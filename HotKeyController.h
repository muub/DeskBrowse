/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>

#import "DeskBrowseConstants.h"
#import "NSFileManagerSGSAdditions.h"
#import "HotKeyTextField.h"
#import "KeyStuff.h"

@class WindowLevel;


// ----- Constants ----- 

EventHotKeyID	sbHotKeyID;		//
EventHotKeyID	wbHotKeyID;		// These are constants so the C
NSInvocation*	wbInvocation;	// function can acccess them
NSInvocation*	sbInvocation;	//


@interface HotKeyController : NSObject
{	
	// ----- SlideBrowse Variables ----- \\
	
	UInt32			sbKeyCode;
	UInt32			sbModifiers;
	UInt32			sbHotKeyIdentifier;
	EventHotKeyRef	sbHotKeyRef;
	
	
	// ----- Websposé Variables ----- \\
	
	UInt32			wbKeyCode;
	UInt32			wbModifiers;
	EventHotKeyRef	wbHotKeyRef;
	UInt32			wbHotKeyIdentifier;
	
	
	// ----- Independent Variables -----\\
	
	EventTypeSpec	eventType;
	BOOL			keepListening;
	BOOL			save;
	
	
	// ----- Interface Outlets -----\\
	
	IBOutlet NSWindow*			mainWindow;
	IBOutlet NSTextField*		typeField;
	IBOutlet HotKeyTextField*	keysField;
}

- (void) setSlideBrowseListener: (id) listener selector: (SEL) selector;
- (void) setWebsposeListener: (id) listener selector: (SEL) selector;
- (void) getNewSlideBrowseHotKey;
- (void) getNewWebsposeHotKey;
- (void) loadHotKeysFromPrefs;
- (void) saveHotKeysToPrefs;
- (void) registerHotKeys;
- (void) unregisterHotKeys;
- (void) listenForKeyEvents;
- (NSString*) currentSBKeyString;
- (NSString*) currentWBKeyString;
- (IBAction) ok: (id) sender;
- (IBAction) cancel: (id) sender;

@end