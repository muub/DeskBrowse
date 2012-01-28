/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import "HistoryObject.h"


@implementation HistoryObject

- (id)init {
	self = [super init];
	if (self) {
		url = [[NSString alloc] initWithString:@""];
		date = [[NSDate alloc] init];
	}
	return self;
}

- (void)dealloc {
	[url release];
	[date release];
	[super dealloc];
}

- (void)setURL:(NSURL *)aUrl {
	[self setStringURL:[aUrl absoluteString]];
}
- (void)setStringURL:(NSString *)aStringURL {
	[aStringURL retain];
	[url release];
	url = aStringURL;
}
- (void)setDate:(NSDate *)aDate {
	[aDate retain];
	[date release];
	date = aDate;
}

- (NSURL *)url {
	return [NSURL URLWithString:url];
}
- (NSString *)stringURL {
	return url;
}
- (NSDate *)date {
	return date;
}

@end
