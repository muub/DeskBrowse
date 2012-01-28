/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import "PreferenceController.h"
#import "WebsposePassword.h"

#import "HotKeyController.h"

int stateFromBool(BOOL aBool); // declaration
int oppositeBoolInt(int bi);
int stateFromBool(BOOL aBool) {
	if (aBool) {
		return NSOnState;
	} else {
		return NSOffState;
	}
}

int oppositeBoolInt(int bi) {
	if (bi == 0)
		return 1;
	else if (bi == 1)
		return 0;
	return -1; // shouldnt ever get here
}

@implementation PreferenceController


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
		if(![NSBundle loadNibNamed: windowNibName owner: self])
		{
			NSLog(@"Failed to load nib: %@", windowNibName);
		}
		else
		{
			[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(handleNotification:) name: NSUserDefaultsDidChangeNotification object: nil];
			
//			sizeOfGeneralPane	= NSMakeSize(530, 460);
			sizeOfGeneralPane	= NSMakeSize(530, 448);
			sizeOfWebPane		= NSMakeSize(530, 380);
			sizeOfWebsposePane	= NSMakeSize(530, 230);
		}
	}
	
	return self;
}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[toolbar release];
	[super dealloc];
}

- (void) awakeFromNib
{	
	[self syncViewWithUserPrefs];
		
	toolbar = [[NSToolbar alloc] initWithIdentifier:@"com.sgs.prefswindow.toolbar"];
	
	[toolbar setAllowsUserCustomization: NO];
    [toolbar setAutosavesConfiguration: YES];
    [toolbar setDisplayMode: NSToolbarDisplayModeIconAndLabel];
	
	[toolbar setDelegate:self];
	
	NSRect winRect;
	winRect.origin = [[self window] frame].origin;
	winRect.size = NSMakeSize(530, 400);
	
	[[self window] setFrame:winRect display:YES];
	[[self window] setToolbar:toolbar];
	
	[toolbar setSelectedItemIdentifier:@"com.sgs.prefswindow.toolbar.general"];
}

#pragma mark -

- (void)showGeneralPane {
	[tabView selectTabViewItemAtIndex:3];
	
	NSRect winRect;
	
	NSSize	currentSize		= [[self window] frame].size;
	NSPoint	currentOrigin	= [[self window] frame].origin;
	
	winRect.origin			= NSMakePoint(currentOrigin.x, currentOrigin.y - (sizeOfGeneralPane.height - currentSize.height));
	winRect.size			= sizeOfGeneralPane;
	
	[[self window] setFrame:winRect display:YES animate:YES];
	[tabView selectTabViewItemAtIndex:0];
	[[self window] display];
}

- (void)showWebPane {
	[tabView selectTabViewItemAtIndex:3];
	
	NSRect winRect;
	
	NSSize	currentSize		= [[self window] frame].size;
	NSPoint	currentOrigin	= [[self window] frame].origin;
	
	winRect.origin			= NSMakePoint(currentOrigin.x, currentOrigin.y - (sizeOfWebPane.height - currentSize.height));
	winRect.size			= sizeOfWebPane;
	
	[[self window] setFrame:winRect display:YES animate:YES];
	[tabView selectTabViewItemAtIndex:1];
	[[self window] display];
}

- (void)showWebsposePane {
	[tabView selectTabViewItemAtIndex:3];
	
	NSRect winRect;
	
	NSSize	currentSize		= [[self window] frame].size;
	NSPoint	currentOrigin	= [[self window] frame].origin;
	
	winRect.origin			= NSMakePoint(currentOrigin.x, currentOrigin.y - (sizeOfWebsposePane.height - currentSize.height));
	winRect.size			= sizeOfWebsposePane;
	
	[[self window] setFrame:winRect display:YES animate:YES];
	[tabView selectTabViewItemAtIndex:2];
	[[self window] display];
}

#pragma mark -

// -----------------------------------
//
// NSToolbar delegate methods
//
// -----------------------------------

- (NSToolbarItem*) toolbar: (NSToolbar*) toolbar
	 itemForItemIdentifier: (NSString*) identifier 
 willBeInsertedIntoToolbar: (BOOL) willBeInserted {
	
	NSToolbarItem* toolbarItem = [[[NSToolbarItem alloc] initWithItemIdentifier: identifier] autorelease];
	
	if ([identifier isEqualToString:@"com.sgs.prefswindow.toolbar.general"]) {
		[toolbarItem setLabel:@"General"];
		[toolbarItem setPaletteLabel:@"General"];
		[toolbarItem setImage:[NSImage imageNamed:@"gen"]];
		[toolbarItem setTarget:self];
		[toolbarItem setAction:@selector(showGeneralPane)];
	} else if ([identifier isEqualToString:@"com.sgs.prefswindow.toolbar.webcontent"]) {
		[toolbarItem setLabel:@"Web Content"];
		[toolbarItem setPaletteLabel:@"Web Content"];
		[toolbarItem setImage:[NSImage imageNamed:@"web_cont"]];
		[toolbarItem setTarget:self];
		[toolbarItem setAction:@selector(showWebPane)];
	} else if ([identifier isEqualToString:@"com.sgs.prefswindow.toolbar.webspose"]) {
		[toolbarItem setLabel:@"Webspose"];
		[toolbarItem setPaletteLabel:@"Webspose"];
		[toolbarItem setImage:[NSImage imageNamed:@"wbsps"]];
		[toolbarItem setTarget:self];
		[toolbarItem setAction:@selector(showWebsposePane)];
	}
	
	return toolbarItem;
}

- (NSArray*) toolbarDefaultItemIdentifiers: (NSToolbar*) toolbar {
	NSArray* identifiers = [NSArray arrayWithObjects:@"com.sgs.prefswindow.toolbar.general", NSToolbarSeparatorItemIdentifier, @"com.sgs.prefswindow.toolbar.webcontent", @"com.sgs.prefswindow.toolbar.webspose", nil];
	
    return identifiers;
}

- (NSArray*) toolbarAllowedItemIdentifiers: (NSToolbar*) toolbar {
	NSArray* identifiers = [NSArray arrayWithObjects:@"com.sgs.prefswindow.toolbar.general", @"com.sgs.prefswindow.toolbar.webcontent", @"com.sgs.prefswindow.toolbar.webspose", NSToolbarSpaceItemIdentifier, NSToolbarFlexibleSpaceItemIdentifier, NSToolbarSeparatorItemIdentifier, nil];
	
    return identifiers;
}

- (BOOL) validateToolbarItem: (NSToolbarItem*) toolbarItem {
    return YES;
}

- (NSArray *)toolbarSelectableItemIdentifiers: (NSToolbar *)toolbar {
	NSArray* identifiers = [NSArray arrayWithObjects:@"com.sgs.prefswindow.toolbar.general", @"com.sgs.prefswindow.toolbar.webcontent", @"com.sgs.prefswindow.toolbar.webspose", nil];
	
	return identifiers;
}

#pragma mark -


// -----------------------------------
//
// NSNotification methods
//
// -----------------------------------

- (void) handleNotification: (NSNotification*) note
{
	if([note name] == NSUserDefaultsDidChangeNotification)
	{
	}
}

#pragma mark -


// -----------------------------------
//
// NSWindowController methods
//
// -----------------------------------

- (IBAction) showWindow: (id) sender
{
	[self syncViewWithUserPrefs];
	[[self window] center];
	
	[super showWindow: sender];
}

#pragma mark -


// -----------------------------------
//
// Interface methods
//
// -----------------------------------

- (IBAction) closeWindow: (id) sender
{
	[[self window] close];
}

- (IBAction) savePreferences: (id) sender
{	
	NSUserDefaults*	defaults	= [NSUserDefaults standardUserDefaults];
	WebPreferences*	preferences	= [WebPreferences standardPreferences];
	
	[PlistUtils setIsBackgroundApp:				[showMenuBarAndDock state]];
	[defaults setBool:							[showMenuExtra state]				forKey: kShowMenuExtra];
	[defaults setBool:							[selectNewTabs state]				forKey: kSelectNewTabs];
	[defaults setBool:							[checkForUpdates state]				forKey: kCheckForUpdates];
	[defaults setObject:						[homePage stringValue]				forKey: kHomePage];
	[defaults setBool:							[loadHomePageOnLaunch state]		forKey: kLoadHomePageOnLaunch];
	[defaults setInteger:						[browserMode indexOfSelectedItem]	forKey: kBrowserMode];
	[defaults setObject:						[[downloadPathField stringValue] stringByAbbreviatingWithTildeInPath] forKey: kDownloadLocation];
	[preferences setJavaScriptEnabled:			[allowJavaScript state]];
	[preferences setJavaEnabled:				[allowJava state]];
	[preferences setLoadsImagesAutomatically:	[allowImages state]];
	[preferences setAllowsAnimatedImages:		[allowAnimatedImages state]];
	[preferences setPlugInsEnabled:				[allowPluginMedia state]];
	[preferences setJavaScriptCanOpenWindowsAutomatically:oppositeBoolInt([blockPopupWindows state])];
	[preferences setUserStyleSheetEnabled:		[blockWebAds state]];
	
	[self closeWindow: self];
}

- (IBAction) resetPreferences: (id) sender
{
	NSDictionary*	defaultPrefs;
	NSUserDefaults*	userDefaults;
	NSBundle*		mainBundle;
	
	mainBundle		= [NSBundle mainBundle];
	defaultPrefs	= [NSDictionary dictionaryWithContentsOfFile: [[mainBundle bundlePath] stringByAppendingString: kPathToDefaultPrefsFile]];
	
	if(defaultPrefs)
	{
		userDefaults = [NSUserDefaults standardUserDefaults];
		
		[showMenuBarAndDock setState:	[[defaultPrefs valueForKey: kShowMenuBarAndDock] boolValue]];
		[showMenuExtra setState:		[[defaultPrefs valueForKey: kShowMenuExtra] boolValue]];
		[selectNewTabs setState:		[[defaultPrefs valueForKey: kSelectNewTabs] boolValue]];
		[checkForUpdates setState:		[[defaultPrefs valueForKey: kCheckForUpdates] boolValue]];
		[homePage setStringValue:		[defaultPrefs objectForKey: kHomePage]];
		[loadHomePageOnLaunch setState: [[defaultPrefs valueForKey: kLoadHomePageOnLaunch] boolValue]];
		[browserMode selectItemAtIndex: [[defaultPrefs valueForKey: kBrowserMode] intValue]];
		//[hotkey setIntValue:			[[defaultPrefs valueForKey: kHotkey] intValue]];
		[allowJavaScript setState:		[[defaultPrefs valueForKey: kAllowJavaScript] boolValue]];
		[allowJava setState:			[[defaultPrefs valueForKey: kAllowJava] boolValue]];
		[allowImages setState:			[[defaultPrefs valueForKey: kAllowImages] boolValue]];
		[allowAnimatedImages setState:	[[defaultPrefs valueForKey: kAllowAnimatedImages] boolValue]];
		[allowPluginMedia setState:		[[defaultPrefs valueForKey: kAllowPluginMedia] boolValue]];
		[blockPopupWindows setState:	[[defaultPrefs valueForKey: kBlockPopupWindows] boolValue]];
		[blockWebAds setState:			[[defaultPrefs valueForKey: kBlockWebAds] boolValue]];
	}
	else
	{
		NSLog(@"PreferenceController: Default preferences not found");
	}
}


// --------------------------------------
//
//	checkForUpdates:
//
// --------------------------------------

- (IBAction) checkForUpdates: (id) sender
{
	[checkForUpdatesIndicator startAnimation: self];
	
	//
	// check for updates here or post notification to check for updates
	//
	
	[checkForUpdatesIndicator stopAnimation: self];
}


// --------------------------------------
//
//	changeSBHotKey:
//
// --------------------------------------

- (IBAction) changeSBHotKey: (id) sender
{
	[[NSApp hotKeyController] getNewSlideBrowseHotKey];
	[self syncViewWithUserPrefs];
}


// --------------------------------------
//
//	changeWBHotKey:
//
// --------------------------------------

- (IBAction) changeWBHotKey: (id) sender
{
	[[NSApp hotKeyController] getNewWebsposeHotKey];
	[self syncViewWithUserPrefs];
}


// -----------------------------------
//
// Interface methods - Websposé
//
// -----------------------------------

- (IBAction) changePassword: (id) sender
{
	[changePasswordOld		setStringValue: @""];
	[changePasswordNew		setStringValue: @""];
	[changePasswordVerify	setStringValue: @""];
	[changePasswordStatus	setStringValue: @""];
	
	[changePasswordOld		selectText: self];
	
	NSLog(@"Change PW: %@", changePasswordWindow);
	
	[NSApp beginSheet: changePasswordWindow modalForWindow: [self window] modalDelegate: nil didEndSelector: nil contextInfo: nil];
}

- (IBAction) savePassword: (id) sender
{
	NSString*		oldPassword		= [WebsposePassword websposePassword];
	
	NSString*		oldString		= [changePasswordOld	stringValue];
	NSString*		newString		= [changePasswordNew	stringValue];
	NSString*		verifyString	= [changePasswordVerify	stringValue];
	
	if (oldPassword == nil || [oldString isEqualToString: oldPassword])
	{
		if ([newString isEqualToString: verifyString])
		{
			[WebsposePassword setWebsposePassword: newString];
			
			[changePasswordStatus setStringValue: @""];
			[NSApp endSheet: changePasswordWindow];
		}
		else
		{
			[changePasswordStatus setStringValue: @"New and verify do not match"];
		}
	}
	else
	{
		[changePasswordStatus setStringValue: @"Old password is incorrect"];
	}
}

- (IBAction) cancelPassword: (id) sender
{
	[NSApp endSheet: changePasswordWindow];
}

#pragma mark -


// -----------------------------------
//
// Other methods
//
// -----------------------------------

- (void) setLevel: (int) newLevel
{
	[[self window]			setLevel: newLevel];
	[changePasswordWindow	setLevel: newLevel];
}

- (IBAction) changeDownloadLocation: (id) sender
{
	NSOpenPanel*	openPanel			= [NSOpenPanel openPanel];
	NSString*		startingDirectory	= [[downloadPathField stringValue] stringByExpandingTildeInPath];
	
	if (startingDirectory == nil || ![[NSFileManager defaultManager] fileExistsAtPath: startingDirectory])
	{
		startingDirectory = NSHomeDirectory();
	}
	
	[openPanel setCanChooseFiles: NO];
	[openPanel setCanChooseDirectories: YES];
	[openPanel setCanCreateDirectories: YES];
	[openPanel setAllowsMultipleSelection: NO];
	
	[openPanel beginSheetForDirectory: startingDirectory file: nil types: nil modalForWindow: [self window] modalDelegate: self didEndSelector: @selector(openPanelDidEnd:returnCode:contextInfo:) contextInfo: nil];
}

- (void) openPanelDidEnd: (NSOpenPanel*) sheet returnCode: (int) returnCode contextInfo: (void*) contextInfo
{
	if (sheet != nil && returnCode == NSOKButton)
	{
		NSString*	filePath			= [sheet filename];
		NSString*	abbreviatedFilePath	= [filePath stringByAbbreviatingWithTildeInPath];
		
		if (abbreviatedFilePath != nil)
		{
			[downloadPathField setStringValue: abbreviatedFilePath];
		}
	}
}

- (void) syncViewWithUserPrefs
{
	NSUserDefaults*	defaults	= [NSUserDefaults standardUserDefaults];
	WebPreferences*	preferences = [WebPreferences standardPreferences];
	
	[showMenuBarAndDock setState:	stateFromBool([PlistUtils isBackgroundApp])];
	[showMenuExtra setState:		[defaults boolForKey:		kShowMenuExtra]];
	[selectNewTabs setState:		[defaults boolForKey:		kSelectNewTabs]];
	[checkForUpdates setState:		[defaults boolForKey:		kCheckForUpdates]];
	[homePage setStringValue:		[defaults objectForKey:		kHomePage]];
	[loadHomePageOnLaunch setState:	[defaults boolForKey:		kLoadHomePageOnLaunch]];
	[browserMode selectItemAtIndex:	[defaults integerForKey:	kBrowserMode]];
	[allowJavaScript setState:		[preferences isJavaScriptEnabled]];
	[allowJava setState:			[preferences isJavaEnabled]];
	[allowImages setState:			[preferences loadsImagesAutomatically]];
	[allowAnimatedImages setState:	[preferences allowsAnimatedImages]];
	[allowPluginMedia setState:		[preferences arePlugInsEnabled]];
	[blockPopupWindows setState:	oppositeBoolInt([preferences javaScriptCanOpenWindowsAutomatically])];
	[blockWebAds setState:			[preferences userStyleSheetEnabled]];
	
	[sbHotKeyField setStringValue: [[NSApp hotKeyController] currentSBKeyString]];
	[wbHotKeyField setStringValue: [[NSApp hotKeyController] currentWBKeyString]];
	
	[downloadPathField setStringValue: [defaults objectForKey: kDownloadLocation]];
	
}

@end
