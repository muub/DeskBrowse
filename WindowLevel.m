/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import "WindowLevel.h"


static int sWindowLevel;

@implementation WindowLevel


+ (int) windowLevel
{
	return sWindowLevel;
}

+ (void) setWindowLevel: (int) level
{
	BOOL isDifferentLevel = (level != sWindowLevel);
	
	if (isDifferentLevel)
	{
		sWindowLevel = level;
		
		[[NSNotificationCenter defaultCenter] postNotificationName: kWindowLevelChangedNotification object: nil];
	}
}


@end