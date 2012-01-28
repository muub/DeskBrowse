/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import "ShellExec.h"


@implementation ShellExec

+ (NSString *)executeShellCommand:(NSString *)command {
	NSString *tmp = [NSString stringWithUTF8String:tmpnam(NULL)];
	// set up the command
	NSString *com = [NSString stringWithFormat:@"%@ > %@", command, tmp];
	// execute the command
	system([com UTF8String]);
	// get the result
	NSString *path = [NSString stringWithFormat:@"%@", tmp];
	NSString *result = [NSString stringWithContentsOfFile:path];
	[[NSFileManager defaultManager] removeFileAtPath:path handler:nil];
	return result;
}

@end
