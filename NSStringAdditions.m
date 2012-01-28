/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import "NSStringAdditions.h"


@implementation NSString (SGSAdditions)

- (NSString*) truncatedToWidth: (float) width withAttributes: (NSDictionary*) attributes
{
	NSString*	fixedString		= self;
	NSString*	currentString	= self;
	NSSize		stringSize		= [currentString sizeWithAttributes: attributes];
	
	if (stringSize.width > width)
	{
		int i = [self length];
		while ([currentString sizeWithAttributes: attributes].width > width)
		{
			if (i > 0)
			{
				currentString = [[self substringToIndex: i] stringByAppendingString: @"..."];
				i--;
			}
			else
			{
				currentString = @"";
				break;
			}
		}
		
		fixedString = currentString;
	}
	
	return fixedString;
}

@end
