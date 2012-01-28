/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

#import "DeskBrowseConstants.h"
#import	"HistoryView.h"
#import	"KeyStuff.h"
#import "NSFileManagerSGSAdditions.h"


@interface HistoryController : NSObject
{
	id			view;
	WebHistory*	webHistory;
	int			numberOfDaysToDisplay;
}

- (void) setView: (id) newView;

// Save/Load
- (void) loadHistoryFile;
- (void) saveHistoryFile;

// Notifications
- (void) historyDidAddItems: (NSNotification*) notification;
- (void) historyDidRemoveItems: (NSNotification*) notification;
- (void) historyDidRemoveAllItems: (NSNotification*) notification;

// UI
- (void) clearHistory;
- (void) loadSelected;
- (void) removeSelected;

// History View
- (int) numberOfDates;
- (int) numberOfItemsForDate: (NSCalendarDate*) date;
- (int) numberOfRows;
- (BOOL) isDateAtIndex: (int) index;
- (NSCalendarDate*) dateAtIndex: (int) index;
- (id) itemAtIndex: (int) index;
- (id) objectForDate: (NSCalendarDate*) date index: (int) index;
- (void) rowClicked: (int) row;

- (NSMenu *)menuForHistory;

@end

