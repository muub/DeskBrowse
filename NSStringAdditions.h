/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import <Cocoa/Cocoa.h>


@interface NSString (SGSAdditions)

- (NSString*) truncatedToWidth: (float) width withAttributes: (NSDictionary*) attributes;

@end