/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import <Cocoa/Cocoa.h>


@interface BookmarkObject : NSObject {
	NSString *bookmarkTitle;
	NSURL *bookmarkLink;
}

- (void)setTitle:(NSString *)aTitle;
- (NSString *)title;

- (void)setLink:(NSURL *)aURL;
- (NSURL *)link;

@end
