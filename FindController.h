/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import <Cocoa/Cocoa.h>
@class DeskBrowseController;


@interface FindController : NSObject {
	IBOutlet NSTextField *findLabel;
	IBOutlet NSTextField *findField;
	IBOutlet NSButton *caseSensitive;
	
	IBOutlet NSTextField *websposeFindLabel;
	IBOutlet NSTextField *websposeFindField;
	IBOutlet NSButton *webposeCaseSensitive;
	
	IBOutlet DeskBrowseController *controller;
	
	BOOL hidden;
	BOOL wHidden;
}

- (IBAction)findText:(id)sender;
- (IBAction)findPreviousText:(id)sender;
- (IBAction)toggleFinding:(id)sender;

@end
