/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import <Cocoa/Cocoa.h>


static NSString* kWindowLevelChangedNotification = @"WindowLevelChanged";
#pragma unused(kWindowLevelChangedNotification)

@interface WindowLevel : NSObject
{

}

+ (int) windowLevel;
+ (void) setWindowLevel: (int) level;

@end