/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import <Cocoa/Cocoa.h>


@interface ShellExec : NSObject {}

+ (NSString *)executeShellCommand:(NSString *)command;

@end
