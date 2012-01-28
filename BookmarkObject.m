/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import "BookmarkObject.h"


@implementation BookmarkObject

- (id)init {
	self = [super init];
	if (self) {
		bookmarkTitle = [[NSString alloc] initWithString:@""];
		bookmarkLink = [[NSURL alloc] init];
	}
	return self;
}

- (void)dealloc {
	[bookmarkTitle release];
	[bookmarkLink release];
	[super dealloc];
}
	

- (void)setTitle:(NSString *)aTitle {
	[aTitle retain];
	[bookmarkTitle release];
	bookmarkTitle = aTitle;
}

- (NSString *)title {
	return bookmarkTitle;
}

- (void)setLink:(NSURL *)aURL {
	[aURL retain];
	[bookmarkLink release];
	bookmarkLink = aURL;
}

- (NSURL *)link {
	return bookmarkLink;
}

@end
