/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import <Cocoa/Cocoa.h>

@class WindowLevel;


@interface LeveledWindow : NSWindow
{
	BOOL mAboveMainWindowLevel;
}

- (void) setAboveMainWindowLevel: (BOOL) aboveMainWindowLevel;
- (void) windowLevelChanged: (NSNotification*) notification;

@end