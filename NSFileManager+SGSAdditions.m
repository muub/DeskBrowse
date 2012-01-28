/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import "NSFileManager+SGSAdditions.h"


/* ----- NSFileManager Additons : Implementation ----- */

@implementation NSFileManager (SGSAdditions)

- (void) createPath: (NSString*) filePath
{
	if(![self fileExistsAtPath: filePath])
	{
		NSMutableString*	currentPath		= [NSMutableString string];
		NSArray*			pathComponents	= [[filePath stringByExpandingTildeInPath] pathComponents];
		
		int i;
		for(i = 0; i < [pathComponents count]; i++)
		{
			if(i == 1 || i == 0)
			{
				[currentPath appendString: [pathComponents objectAtIndex: i]];
			}
			else
			{
				[currentPath appendString: [NSString stringWithFormat: @"/%@", [pathComponents objectAtIndex: i]]];
			}
			
			if(![self fileExistsAtPath: currentPath])
			{
				[self createDirectoryAtPath: currentPath attributes: nil];
				[[NSWorkspace sharedWorkspace] noteFileSystemChanged];
			}
		}
	}
}

@end