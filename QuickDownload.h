/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "URLFormatter.h"


@interface QuickDownload : NSObject {
	IBOutlet NSMatrix *directoryMatrix;
	IBOutlet NSButton *openButton;
	IBOutlet NSButton *decodeButton;
	IBOutlet NSButton *downloadCancelButton;
	IBOutlet NSProgressIndicator *progressIndicator;
	IBOutlet NSTextField *URLField;
	
	BOOL isDownloading;
	
	WebDownload *download;
	
	int receivedContentLength;
	int expectedContentLength;
	
	NSString *_filename;
}

- (IBAction)downloadOrCancel:(id)sender;

- (void)setFilename:(NSString *)aString;
- (NSString *)filename;

@end
