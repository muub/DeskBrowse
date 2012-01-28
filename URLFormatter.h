/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import <Cocoa/Cocoa.h>


@interface URLFormatter : NSObject {
//	NSString *oldurl;
}
//- (id)initWithStringURL:(NSString *)url;
+ (NSString *)formatAndReturnStringWithString: (NSString*) URLString;
+ (NSURL *)formatAndReturnURLWithString: (NSString*) URLString;

//- (void)setStringURL:(NSString *)url;
//- (NSString *)stringURL;
@end
