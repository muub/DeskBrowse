/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import <Cocoa/Cocoa.h>


/* ----- NSFileManager Additons : Interface ----- */

@interface NSFileManager (SGSAdditions)

- (void) createPath: (NSString*) filePath;
- (NSString*) uniqueFilePath: (NSString*) filePath;

@end