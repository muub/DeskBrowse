/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>

@class HotKeyController;
@class DeskBrowseConstants;


@interface DBApplication : NSApplication
{
	HotKeyController*	hotKeyController;
}

- (void) initHotKeyController;
- (void) handleKeyEvent: (NSEvent*) theEvent;
- (HotKeyController*) hotKeyController;

@end