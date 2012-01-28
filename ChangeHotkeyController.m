/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import "ChangeHotkeyController.h"


@implementation ChangeHotkeyController


// -----------------------------------
//
// Constructor and destructor methods
//
// -----------------------------------

- (id) init
{
	self = [self initWithWindowNibName: @"Preferences"];
	
	return self;
}

- (id) initWithWindowNibName: (NSString*) windowNibName
{
	if(self = [super initWithWindowNibName: windowNibName])
	{
		if(![NSBundle loadNibNamed: @"ChangeHotkey" owner: self])
		{
			NSLog(@"Failed to load hotkey nib");
		}
		else
		{
		}
	}
	
	return self;
}

- (void) dealloc
{
	[super dealloc];
}

- (void) awakeFromNib
{
}


- (IBAction) showWindow: (id) sender
{
	int					response;
	NSPanel*			panel;
	NSModalSession		modalSession;

	panel				= (NSPanel*)[self window];
	[panel orderFront: self];
	
	modalSession		= [[NSApplication sharedApplication] beginModalSessionForWindow: panel];
	
	do
	{
		response		= [[NSApplication sharedApplication] runModalSession: modalSession];
	}
	while(response == NSRunContinuesResponse);

	[[NSApplication sharedApplication] endModalSession: modalSession];
	
	[panel orderOut: self];
}

// -----------------------------------
//
// Interface methods
//
// -----------------------------------

- (IBAction) ok: (id) sender
{
	[[NSApplication sharedApplication] stopModal];
//	[[self window] close];
}

- (IBAction) cancel: (id) sender
{
	[[NSApplication sharedApplication] stopModal];
//	[[self window] close];
}


@end
