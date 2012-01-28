/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import "HistoryController.h"


NSString* nameOfHistoryFile = @"History.plist";

@implementation HistoryController


// Constructor/Destructor

- (id) init
{
	if(self = [super init])
	{
		// Create WebHistory object, and load history file if it exists
		webHistory = [[WebHistory alloc] init];
		
		[self loadHistoryFile];
		[self saveHistoryFile];
		
		[WebHistory setOptionalSharedHistory: webHistory];
		
		// Register for WebHistory notifications
		NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
		
		[notificationCenter addObserver: self selector: @selector(historyDidAddItems:) name: WebHistoryItemsAddedNotification object: webHistory];
		[notificationCenter addObserver: self selector: @selector(historyDidRemoveItems:) name: WebHistoryItemsRemovedNotification object: webHistory];
		[notificationCenter addObserver: self selector: @selector(historyDidRemoveAllItems:) name: WebHistoryAllItemsRemovedNotification object: webHistory];
	}
	
	return self;
}

- (void) dealloc
{
	[webHistory release];
	[view release];
	
	[super dealloc];
}

- (void) setView: (id) newView
{
	[view release];
	view = [newView retain];
	[view setNeedsDisplay: YES];
}


// Save/Load

- (void) loadHistoryFile
{
	if(webHistory)
	{
		NSString*		fullPathOfDeskBrowseFolder	= nil;
		NSString*		fullHistoryPath				= nil;
		NSFileManager*	fileManager					= nil;
		NSError*		error						= nil;
		
		fileManager					= [NSFileManager				defaultManager];
		fullPathOfDeskBrowseFolder	= [kPathOfDeskBrowseFolder		stringByExpandingTildeInPath];
		fullHistoryPath				= [fullPathOfDeskBrowseFolder	stringByAppendingPathComponent: nameOfHistoryFile];
			
		[fileManager createPath: fullPathOfDeskBrowseFolder];

		if([fileManager fileExistsAtPath: fullPathOfDeskBrowseFolder])
		{
			if([fileManager fileExistsAtPath: fullHistoryPath])
			{
				if(![webHistory loadFromURL: [NSURL fileURLWithPath: fullHistoryPath] error: &error])
				{
					NSLog(@"*** -[HistoryController loadHistoryFile] : Failed to load history file");
					
					if(error)
					{
						NSLog(@"\tError: %@", [error localizedDescription]);
					}
				}
			}
			else
			{
				NSLog(@"*** -[HistoryController loadHistoryFile] : History file does not exist");
			}
		}
		else
		{
			NSLog(@"*** -[HistoryController loadHistoryFile] : DeskBrowse file does not exist");
		}
	}
	else
	{
		NSLog(@"*** -[HistoryController loadHistoryFile] : webHistory object does not exist");
	}
}

- (void) saveHistoryFile
{
	if(webHistory)
	{
		NSString*		fullPathOfDeskBrowseFolder	= nil;
		NSString*		fullHistoryPath				= nil;
		NSFileManager*	fileManager					= nil;
		NSError*		error						= nil;
		
		fileManager					= [NSFileManager				defaultManager];
		fullPathOfDeskBrowseFolder	= [kPathOfDeskBrowseFolder		stringByExpandingTildeInPath];
		fullHistoryPath				= [fullPathOfDeskBrowseFolder	stringByAppendingPathComponent: nameOfHistoryFile];
			
		[fileManager createPath: fullPathOfDeskBrowseFolder];

		if([fileManager fileExistsAtPath: fullPathOfDeskBrowseFolder])
		{
			if(![webHistory saveToURL: [NSURL fileURLWithPath: fullHistoryPath] error: &error])
			{
				NSLog(@"*** -[HistoryController saveHistoryFile] : Failed to save history file");
				
				if(error)
				{
					NSLog(@"\tError: %@", [error localizedDescription]);
				}
			}
		}
		else
		{
			NSLog(@"*** -[HistoryController saveHistoryFile] : DeskBrowse folder does not exist");
		}
	}
	else
	{
		NSLog(@"*** -[HistoryController saveHistoryFile] : webHistory object does not exist");
	}
}


// Notifications

- (void) historyDidAddItems: (NSNotification*) notification
{
	[self saveHistoryFile];
	//NSArray* items = [notification userInfo];
	
	//if(items)
	{
	}
	
	if(view)
	{
		[view updateSelectedRow];
		[view reloadData];
	}
}

- (void) historyDidRemoveItems: (NSNotification*) notification
{
	[self saveHistoryFile];
	
	//NSArray* items = [notification userInfo];
	
	//if(items)
	{
	}
	
	if(view)
	{
		[view updateSelectedRow];
		[view reloadData];
	}
}

- (void) historyDidRemoveAllItems: (NSNotification*) notification
{
	[self saveHistoryFile];
	
	if(view)
	{
		[view updateSelectedRow];
		[view reloadData];
	}
}


// UI

- (void) clearHistory
{
    [webHistory removeAllItems];
}

- (void) loadSelected
{
	int selectedRow = [view selectedRow];

	if(selectedRow > -1)
	{
		WebHistoryItem*			itemToLoad	= [self itemAtIndex: selectedRow - 1];
		NSString*				URLString	= [itemToLoad URLString];
		NSMutableDictionary*	userInfo	= [[NSMutableDictionary alloc] init];
		
		[userInfo setObject: URLString forKey: @"URLString"];
		
		[[NSNotificationCenter defaultCenter] postNotificationName: @"DBLoadURLNotification" object: self userInfo: userInfo];
		
		[userInfo release];
	}
}

- (void) removeSelected
{
	int			selectedRow		= [view selectedRow] - 1;
	NSArray*	itemsToRemove	= nil;
	
	if(selectedRow > -1)
	{
		if([self isDateAtIndex: selectedRow])
		{
			NSCalendarDate* selectedDate = [self dateAtIndex: selectedRow];
			
			if(selectedDate != nil)
			{
				itemsToRemove = [webHistory orderedItemsLastVisitedOnDay: selectedDate];
			}
		}
		else
		{
			WebHistoryItem* itemToRemove = [self itemAtIndex: selectedRow];
			
			if(itemToRemove != nil)
			{
				itemsToRemove = [NSArray arrayWithObject: itemToRemove];
			}
		}
		
		if(itemsToRemove != nil)
		{
			[webHistory removeItems: itemsToRemove];
		}
	}
	
	[view reloadData];
}

- (NSMenu*) menuForHistory
{
	NSMenu*			historyMenu		= [[[NSMenu alloc] initWithTitle: @"Back"] autorelease];
	NSArray*		lastVisitedDays = [webHistory orderedLastVisitedDays];
	
	if ([lastVisitedDays count] > 0)
	{
		NSCalendarDate*	lastVisitedDate			= [lastVisitedDays objectAtIndex: 0];
		NSArray*		sitesVisitedLastDate	= [webHistory orderedItemsLastVisitedOnDay: lastVisitedDate];
		
		NSEnumerator*	siteEnumerator			= [sitesVisitedLastDate objectEnumerator];
		WebHistoryItem*	currentSite				= nil;
		unsigned		siteIndex				= 0;
		
		while ((currentSite = [siteEnumerator nextObject]) != nil && siteIndex++ < 5)
		{
			NSString* menuItemTitle = [currentSite title];
			
			if (menuItemTitle == nil)
			{
				menuItemTitle = [currentSite URLString];
			}
			
			NSMenuItem* menuItemForSite = [[NSMenuItem alloc] initWithTitle: menuItemTitle action: nil keyEquivalent: @""];
			
			[historyMenu addItem: menuItemForSite];
			
			[menuItemForSite release];
		}
	}
	
	return historyMenu;
}


// History View


//
// numberOfDates
//

- (int) numberOfDates
{
	int number;
	
	number = [[webHistory orderedLastVisitedDays] count];
	
	return number;
}


//
// numberOfRows
//

- (int) numberOfRows
{
	int				number		= 0;
	NSArray*		dates		= [webHistory orderedLastVisitedDays];
	NSCalendarDate*	currentDate	= nil;
	
	int i;
	for(i = 0; i < [dates count]; i++)
	{
		currentDate = [dates objectAtIndex: i];
		
		number++;
		number += [[webHistory orderedItemsLastVisitedOnDay: currentDate] count];
	}
	
	return number;
}


//
// numberOfItemsForDate:
//

- (int) numberOfItemsForDate: (NSCalendarDate*) date
{
	int number;
	
	number = [[webHistory orderedItemsLastVisitedOnDay: date] count];
	
	return number;
}


//
// isDateAtIndex:
//

- (BOOL) isDateAtIndex: (int) index
{
	BOOL isDate			= NO;
	
	NSMutableArray* dateIndexes = [[NSMutableArray alloc] init];
	int currentIndex		= 0;
	
	int i;
	for(i = 0; i < [self numberOfDates]; i++)
	{
		[dateIndexes addObject: [NSNumber numberWithInt: currentIndex]];
		
		int j;		
		for(j = 0; j < [self numberOfItemsForDate: [self dateAtIndex: i]]; j++)
		{
			currentIndex++;
		}
		
		currentIndex++;
	}
	
	for(i = 0; i < [dateIndexes count]; i++)
	{
		if([[dateIndexes objectAtIndex: i] intValue] == index)
		{
			isDate	= YES;
			break;
		}
	}
		
	return isDate;
}


//
// dateAtIndex:
//

- (NSCalendarDate*) dateAtIndex: (int) index
{
	NSCalendarDate*	date	= nil;
	NSArray*		dates	= [webHistory orderedLastVisitedDays];
	
	date					= [dates objectAtIndex: index];
	
	return date;
}


//
// itemAtIndex:
//

- (id) itemAtIndex: (int) index
{
	id				item			= nil;
	
	int				currentIndex	= -1;
	NSArray*		dates			= [webHistory orderedLastVisitedDays];
	NSArray*		currentItems	= nil;
	NSCalendarDate*	currentDate		= nil;
	WebHistoryItem*	currentItem		= nil;

	if(index > -1)
	{
		int i;
		for(i = 0; i < [dates count]; i++)
		{
			currentIndex++;
			currentDate		= [dates objectAtIndex: i];
			
			if(currentIndex == index)
			{
				item = currentDate;
				break;
			}
			
			currentItems	= [webHistory orderedItemsLastVisitedOnDay: currentDate];
			
			int j;
			for(j = 0; j < [currentItems count]; j++)
			{
				currentIndex++;
				currentItem = [currentItems objectAtIndex: j];
				
				if(currentIndex == index)
				{
					item = currentItem;
					break;
				}
			}
		}
	}
	
	return item;
}


//
// objectForDate:index:
//

- (id) objectForDate: (NSCalendarDate*) date index: (int) index
{
	NSArray*		items		= nil;
	WebHistoryItem*	item		= nil;
	NSString*		object		= nil;
	NSString*		title		= nil;
	NSString*		URLString	= nil;
	
	items		= [webHistory orderedItemsLastVisitedOnDay: date];
	item		= [items objectAtIndex: index];
	
	title		= [item title];
	URLString	= [item URLString];
	
	if(title)
	{
		object	= title;
	}
	else
	{
		object = URLString;
	}
	
	return object;
}


//
// rowClicked:
//

- (void) rowClicked: (int) row
{
	if(row > -1 && ![self isDateAtIndex: row])
	{
	}
}


@end
