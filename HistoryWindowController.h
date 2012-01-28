/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import <Cocoa/Cocoa.h>

#import	"HistoryView.h"
#import "HistoryController.h";


@interface HistoryWindowController : NSWindowController
{
	IBOutlet HistoryView*	historyView;
	IBOutlet NSScrollView*	scrollView;
	
	HistoryController*		historyController;
}

- (id) initWithWindowNibName: (NSString*) windowNibName historyController: (HistoryController*) controller;

// Window
- (IBAction) closeWindow: (id) sender;

// UI
- (IBAction) clear: (id) sender;
- (IBAction) load: (id) sender;
- (IBAction) remove: (id) sender;

@end
