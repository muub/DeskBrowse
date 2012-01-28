/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import <Cocoa/Cocoa.h>


@interface ChangeHotkeyController : NSWindowController
{
	IBOutlet id		hotkey;
}

- (IBAction) ok: (id) sender;
- (IBAction) cancel: (id) sender;

@end
