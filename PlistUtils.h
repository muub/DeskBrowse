/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import <Cocoa/Cocoa.h>


@interface PlistUtils : NSObject {}

+ (void)setIsBackgroundApp:(BOOL)bgappflag;
+ (BOOL)isBackgroundApp;
+ (NSString *)plistFilePath;
+ (void)updateApp;

@end

