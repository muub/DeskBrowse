/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import <Cocoa/Cocoa.h>


@interface HistoryObject : NSObject {
	NSString *url;
	NSDate *date;
}

- (void)setURL:(NSURL *)aUrl;
- (void)setStringURL:(NSString *)aStringURL;
- (void)setDate:(NSDate *)aDate;

- (NSURL *)url;
- (NSString *)stringURL;
- (NSDate *)date;

@end
