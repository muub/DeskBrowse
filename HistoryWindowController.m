/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import "HistoryWindowController.h"

#import "BezelScroller.h"


@implementation HistoryWindowController


// Constructor/Destructor

- (id) initWithWindowNibName: (NSString*) windowNibName historyController: (HistoryController*) controller
{
	if(self = [super initWithWindowNibName: windowNibName])
	{
		historyController = [controller retain];
	}
	
	return self;
}

- (void) dealloc
{
	[historyController release];
	[super dealloc];
}

- (void) awakeFromNib
{
	[historyController	setView:		historyView];
	[historyView		setDelegate:	historyController];
	
	BezelScroller* scroller = [[BezelScroller alloc] init];

	[scrollView setVerticalScroller: scroller];
	[scroller	release];
		
	[historyView reloadData];
}


// Window

- (IBAction) closeWindow: (id) sender
{
	[[self window] close];
}


// UI

- (IBAction) clear: (id) sender
{
	[historyController clearHistory];
}

- (IBAction) load: (id) sender
{
	[historyController loadSelected];
}

- (IBAction) remove: (id) sender
{
	[historyController removeSelected];
}

- (void) windowDidResize: (NSNotification*) aNotification
{
	[historyView reloadData];
}


@end
