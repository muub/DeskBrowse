/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import <Cocoa/Cocoa.h>
#import "ThreadWorker.h"


@interface ViewSourceWindowController : NSWindowController {
	IBOutlet	NSTextView	*sourceView;
	IBOutlet NSProgressIndicator *status;
	NSString *sourceCode;
}

- (IBAction)saveCode:(id)sender;
- (IBAction)refreshTheSourceCode:(id)sender;

- (void)setSourceCode:(NSString *)aStr;
- (NSString *)sourceCode;

- (void)setTitle:(NSString *)title;

- (void)doColorSyntax;

- (void)coloringDone:(ThreadWorker *)tw;

@end

