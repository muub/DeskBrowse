/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import "BetterOutlineView.h"


@implementation BetterOutlineView


//---------------------------------------------------------------
//
// - [BetterOutlineView textDidEndEditing:]
//
//		Overridden to allow return to complete editing instead of
//		editing the next row in the same column
//
//---------------------------------------------------------------

- (void) textDidEndEditing: (NSNotification*) notification
{
	NSDictionary*	userInfo		= [notification userInfo];
	NSString*		textMovementKey = @"NSTextMovement";
	int				whyEnd			= [[userInfo objectForKey: textMovementKey] intValue];
	BOOL			calledSuper		= NO;
	
	if (whyEnd == NSReturnTextMovement)
	{
		NSNotification* newNotification = nil;
		
		{
			NSMutableDictionary* newUserInfo = [userInfo mutableCopy];
			[newUserInfo setObject: [NSNumber numberWithInt: NSOtherTextMovement] forKey: textMovementKey];

			newNotification = [NSNotification notificationWithName: [notification name] object: [notification object] userInfo: newUserInfo];
			
			[newUserInfo release];
		}

		[super textDidEndEditing: newNotification];
		
		calledSuper = YES;
		
		[[self window] makeFirstResponder: self];
	}
	
	
    if (!calledSuper)
    {
		[super textDidEndEditing: notification];
    }
}

- (void) editFirstColumnOfSelectedRow
{
	unsigned selectedRow	= [self selectedRow];
	unsigned numberOfRows	= [self numberOfRows];
	
	if (selectedRow != NSNotFound && selectedRow < numberOfRows)
	{
		int columnToEdit	= 0;
		int numberOfColumns	= [self numberOfColumns];
		
		if (columnToEdit >= 0 && columnToEdit < numberOfColumns)
		{
			[self editColumn: columnToEdit row: selectedRow withEvent: nil select: YES];
		}
	}
}


@end