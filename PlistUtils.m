/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import "PlistUtils.h"


@implementation PlistUtils

/*+ (void) setIsBackgroundApp: (BOOL) flag
{
	NSDictionary* plistTags = (NSDictionary*) CFBundleGetLocalInfoDictionary(CFBundleGetMainBundle());applicationservices
	
	if (flag)
	{
		[plistTags setValue: @"1" forKey: @"NSUIElement"];
	}
	else
	{
		[plistTags setValue: @"0" forKey: @"NSUIElement"];
	}
	
	[plistTags writeToFile: [self plistFilePath] atomically: YES];
}*/

+ (void)setIsBackgroundApp:(BOOL)bgappflag {
	NSDictionary *plistTags = [NSDictionary dictionaryWithContentsOfFile:[self plistFilePath]];
	if (bgappflag) {
		[plistTags setValue:@"1" forKey:@"NSUIElement"];
	} else {
		[plistTags setValue:@"0" forKey:@"NSUIElement"];
	}
	[plistTags writeToFile:[self plistFilePath] atomically:YES];
	[[NSWorkspace sharedWorkspace] noteFileSystemChanged];
	[self updateApp];
}

+ (BOOL)isBackgroundApp {
	NSDictionary *plistTags = [NSDictionary dictionaryWithContentsOfFile:[self plistFilePath]];
	if ([[plistTags objectForKey:@"NSUIElement"] isEqualTo:@"1"]) {
		return YES;
	} else {
		return NO;
	}
}

+ (NSString *)plistFilePath {
	return [NSString stringWithFormat:@"%@/Contents/Info.plist", [[NSBundle mainBundle] bundlePath]];
}

+ (void)updateApp {
	NSTask *touch = [[NSTask alloc] init];
	[touch setLaunchPath:@"/usr/bin/touch"];
	[touch setArguments:[NSArray arrayWithObject:[[NSBundle mainBundle] bundlePath]]];
	[touch waitUntilExit];
	[touch launch];
}

@end