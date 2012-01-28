/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/


#import <Cocoa/Cocoa.h>


@interface BezelController : NSObject {
	NSWindow *bezel;
	NSString *file;
	NSTimer *timer;
	NSTextField *filenameDisplay;
	NSImageView *imageView;
	NSImageView *bgView;
}
- (void)setDownloadFile:(NSString *)filename;
- (NSString *)downloadFile;
- (void)showBezel;
- (void)showBezelForFile:(NSString *)filename;
- (void)hideBezel;

- (void)handleNotification:(NSNotification *)note;

@end
