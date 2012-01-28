/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import <Cocoa/Cocoa.h>


static NSString* kLinkTitleKey		= @"HTMLParserLink";
static NSString* kLinkURLStringKey	= @"HTMLParserURLString";

@interface HTMLParser : NSObject
{
	NSXMLParser*	mXMLParser;
	NSMutableArray*	mLinkDictionaries;
	BOOL			mStillParsing;
}

+ (HTMLParser*) HTMLParser;

- (NSArray*) linksFromHTMLString: (NSString*) HTMLString;
- (NSArray*) linksFromHTMLFileAtPath: (NSString*) HTMLFilePath;

@end