/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import "DeskBrowseController.h"

#import "DBApplication.h"
#import "DeskBrowseConstants.h"

#import "ActionMenuView.h"
#import "ActionMenuWindow.h"
#import "BookmarkBar.h"
#import "BookmarkController.h"
#import "BookmarkImportWindowController.h"
#import "BookmarkWindowController.h"
#import "DownloadController.h"
#import "HistoryController.h"
#import "HistoryWindowController.h"
#import "HotKeyController.h"
#import "LocationTextField.h"
#import "NSFileManagerSGSAdditions.h"
#import "NSWindowFade.h"
#import "PlistUtils.h"
#import "PreferenceController.h"
#import "QuickDownload.h"
#import "SlideWindow.h"
#import "Tab.h"
#import "TabBar.h"
#import "TabController.h"
#import "URLFormatter.h"
#import "ViewSourceWindowController.h"
#import "WebKitEx.h"
#import "WebsposePassword.h"
#import "WebsposeWindow.h"
#import "WindowLevel.h"
#import "StatusItemController.h"
#import "SymbolicHotKeyController.h"

#include <netdb.h>
#include <netinet/in.h>
#include <arpa/inet.h>

char *GetPrivateIP();
char *GetPrivateIP() {
	struct hostent *h;
	char hostname[100];
	gethostname(hostname, 99);
	if ((h=gethostbyname(hostname)) == NULL) {
        perror("Error: ");
        return "(Error locating Private IP Address)";
    }
    return inet_ntoa(*((struct in_addr *)h->h_addr));
}

static NSURL *urlTemp = nil;
static NSString *strTemp = nil;


@implementation DeskBrowseController


+ (void) initialize
{
	// This is called before any other method in this class.
	// Register the user defaults here so they are set
	// when they are requested. If there are no defaults
	// set when someone requests them, these are the ones
	// that they will receive.
	
	if (self = [DeskBrowseController class])
	{
		NSUserDefaults*			userDefaults	= [NSUserDefaults standardUserDefaults];
		NSBundle*				mainBundle		= [NSBundle mainBundle];
		NSMutableDictionary*	defaultPrefs	= [NSMutableDictionary dictionaryWithContentsOfFile: [[mainBundle bundlePath] stringByAppendingString: kPathToDefaultPrefsFile]];
		
		if (defaultPrefs != nil)
		{							
			[userDefaults registerDefaults: defaultPrefs];
		}
		else
		{
			NSLog(@"*** DeskBrowseController: Default preferences not found ***");
		}
		
		[NSApp initHotKeyController];
	}
}

- (id)init
{
	if (self = [super init])
	{
		// Check to see if someone has messed with the binary
		//
		// I took this out of a thread, because sometimes it runs a modal window when another is up, which causes problems.
		// It seems to be fast enough to not need a thread, anyway.
		
		//[self checkTampering];
		
		
		// Make sure instance variables match user prefs
		
		[self syncVariablesWithUserPrefs];
		
		
		// Set up web preferences
		
		WebPreferences*	webPrefs = [WebPreferences standardPreferences];
		
		[webPrefs setUserStyleSheetLocation:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"userContent" ofType:@"css"]]];
		
		
		// Set up delegation
		
		[NSApp			setDelegate: self];
		[slideWindow	setDelegate: self];
		[websposeWindow setDelegate:self];
		
		
		// Register for notifications
		
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(handleNotification:) name: @"DBNotification" object: nil];
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(handleNotification:) name: NSUserDefaultsDidChangeNotification object: nil];
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(handleNotification:) name: @"DBToggleSplitView" object: nil];
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(handleNotification:) name: @"DBWebSearch" object: nil];
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(handleNotification:) name: @"DBActionMenuItemNotification" object: nil];
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(tabChanged:) name: @"DBTabSelected" object: nil];
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(slideWindowResized:) name: @"DBSlideWindowResized" object: nil];
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(loadURLNotification:) name: @"DBLoadURLNotification" object: nil];
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(windowDidResize:) name:NSWindowDidResizeNotification  object:nil];
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(handleNewTabRequest:) name:@"DBNewBlankTab" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(windowDidMove:) name: NSWindowDidMoveNotification object: nil];
		//[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(registrationStatusChanged) name: kRegistrationStatusChangedNotification object: nil];
		
		
		// Assign values to instance variables
		
		historyController	= [[HistoryController alloc] init];
		downloadController	= [[DownloadController alloc] init];
		
		windowIsVisible		= NO;
		actionMenuVisible	= NO;
		stopEnabled			= NO;
		
		
		// Set up action menu
		
		actionMenuWindow	= [[ActionMenuWindow alloc] initWithContentRect:NSMakeRect(-4, 90, 153, 135)
														   styleMask:NSBorderlessWindowMask
															 backing:NSBackingStoreRetained
															   defer:NO];
															   
		actionMenu			= [[ActionMenuView alloc] initWithFrame:NSMakeRect(0,0,153,135)];
		
		if (!inWebsposeMode) {
			[actionMenuWindow setFrame: NSMakeRect([actionMenuWindow frame].origin.x, [slideWindow frame].origin.y + 47, [actionMenuWindow frame].size.width, [actionMenuWindow frame].size.height) display: YES];
		} else {
			[actionMenuWindow setFrame: NSMakeRect([actionMenuWindow frame].origin.x, [websposeWindow frame].origin.y + 47, [actionMenuWindow frame].size.width, [actionMenuWindow frame].size.height) display: YES];
		}
		[[actionMenuWindow contentView] addSubview:actionMenu];
		[actionMenuWindow setDelegate:self];
		[actionMenuWindow setAcceptsMouseMovedEvents: YES];
	}
	
	return self;
}

- (IBAction)showDocumentation:(id)sender {
	[self loadURLString:@"http://deskbrowse.com/wiki/HowToUse"];
}

- (void)awakeFromNib {
	// first run?
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	// check to see if this is the first run of DeskBrowse
	BOOL firstRun = [userDefaults boolForKey: kFirstRun];
	if (firstRun) {
		// if it is, open the documenatation included in the app bundle
		[self showDocumentation:self];
		// now it isnt the first run, so set the preference
		[userDefaults setBool:NO forKey:kFirstRun];
	}
	
	// check for deskbrowse updates
	// NOTE: the 'checkForUpdate' selector deals with looking at the NSUserDefaults
	//	     and only checking if the user is allowing it too
	//
	// we do this in awakeFromNib because we need the interface to be active
	//
	
	
	// Set up bookmark bar
	
	bookmarkController = [[BookmarkController alloc] init];	
	[bookmarkBar setBookmarkController: bookmarkController];
	
	
	// Set up slide window
	
	[slideWindow setSticky:YES];
	[slideWindow setController:self];
	
	
	// Set window level
	
	[WindowLevel setWindowLevel: [slideWindow level]];
	
	
	// Set up tab view
	
	[self setupTabView];
	
	tabController = [[TabController alloc] initWithTabBar: tabBar tabView: tabView];
	
	[tabController setDefaultWebView: [self newWebView]];
	
	
	// Clear status and title text
	
	[self setStatusText:@""];
	[self setTitleText:@""];
	
	
	// Set URL field's target and action
	
	[urlField setTarget: self];
	[urlField setAction: @selector(loadURL:)];
	[websposeURLField setTarget: self];
	[websposeURLField setAction: @selector(loadURL:)];
	[websposeURLField setFont: [NSFont fontWithName: [[websposeURLField font] fontName] size: 11]];
	
	
	// Load slide window size
	
	[slideWindow loadFrame];
	
	[back setToolTip:@"Go Back"];
	[forward setToolTip:@"Go Forward"];
	[stop setToolTip:@"Stop Loading"];
	[reload setToolTip:@"Reload The Current Page"];
	[home setToolTip:@"Go Home"];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	if (statusController) [statusController	release];
	
	[loadingState				release];
	[homePage					release];
	[downloadController			release];
	[historyController			release];
	[bookmarkController			release];
	[historyWindowController	release];
	[prefController				release];
	[tabController				release];
	[currentWebView				release];
	[currentStatus				release];
	[currentTitle				release];
	[actionMenu					release];
	[symbolicHotKeyController	release];
	
	[super dealloc];
}

#pragma mark -

- (void) setupTabView
{
	NSTabViewItem*	firstTab	= [tabView tabViewItemAtIndex: 0];
	WebView*		newWebView	= [self newWebView];
	
	[firstTab setView: newWebView];
	
	[currentWebView release];
	currentWebView = [newWebView retain];
}

- (NSWindow*) currentWindow
{
	NSWindow* currentWindow = nil;
	
	if(inWebsposeMode)
	{
		currentWindow = websposeWindow;
	}
	else
	{
		currentWindow = slideWindow;
	}
	
	return currentWindow;
}

- (void)handleNewTabRequest:(NSNotification *)notification {
	WebView *newWebView = [self newWebView];
	if ([[NSUserDefaults standardUserDefaults] boolForKey:kSelectNewTabs])
		[tabController newTabWithWebView:newWebView select:YES];
	else
		[tabController newTabWithWebView:newWebView select:NO];
}

- (void)handleNotification:(NSNotification *)note {
	NSString *type = ((NSString *)[[note userInfo] objectForKey:@"notificationType"]);
	NSString *name = ((NSString *)[note name]);
	
	if(name == NSUserDefaultsDidChangeNotification)
	{
		[self syncVariablesWithUserPrefs];
		return;
	}
	
	if ([name isEqualToString:@"DBToggleSplitView"]) {
		if (!inWebsposeMode) {
			if ([urlField isHidden]) {
				[searchField setHidden:NO];
				[urlField setHidden:NO];
				[urlField selectText:self];
			} else {
				[searchField setHidden:YES];
				[urlField setHidden:YES];
			}
		} else {
			if ([websposeURLField isHidden]) {
				[websposeURLField setHidden:NO];
				[websposeSearchField setHidden:NO];
				[websposeSpinner setHidden:NO];
				[websposeURLField selectText:self];
			} else {
				[websposeURLField setHidden:YES];
				[websposeSearchField setHidden:YES];
				[websposeSpinner setHidden:YES];
			}
		}
		return;
	}
	
	if ([name isEqualToString:@"DBWebSearch"]) {
		NSString *search     = [[note userInfo] objectForKey:@"searchString"];
		NSNumber *cs_num     = [[note userInfo] objectForKey:@"caseSensitive"];
		NSNumber *bkwds_num  = [[note userInfo] objectForKey:@"backwards"];
		BOOL cs = NO;
		BOOL bkwds = NO;
		switch ([cs_num intValue]) {
			case NSOnState:  cs = YES; break;
			case NSOffState: cs = NO;  break;
		}
		switch ([bkwds_num intValue]) {
			case 0: bkwds = YES; break;
			case 1: bkwds = NO;  break;
		}
		BOOL srch = [currentWebView searchFor:search direction:bkwds caseSensitive:cs wrap:YES];
		if (!srch) { NSBeep(); }
	}
	if ([name isEqualToString:@"DBActionMenuItemNotification"]) {
		NSString *sender = [[note userInfo] objectForKey:@"sender"];
		if ([sender isEqualToString:@"Webspose"]) {
				[self toggleWebspose];
		} else if ([sender isEqualToString:@"Downloads"]) {
			[self showDownloadWindow:nil];
		} else if ([sender isEqualToString:@"History"]) {
			[self showHistoryWindow:nil];
		} else if ([sender isEqualToString:@"Bookmarks"]) {
			[self showBookmarkWindow:nil];
		}
		
		if(actionMenuVisible)
		{
			[self toggleActionMenu: nil];
		}
	}
	if ([type isEqualToString:@"loadURL"]) {
		NSString *targetURL = ((NSString *)[[note userInfo] objectForKey:@"targetURL"]);
		[currentWebView stopLoading:self];
		if (!windowIsVisible) {
			[self slideInForcingToFront: YES];
		}
		[self setURLText:targetURL];
		WebView *w = [self newWebView];
		[tabController newTabWithWebView:w select:YES];
		Tab* tab = [tabController tabWithWebView:w];
	
		if(tab)
		{
			[tab setURLString: targetURL];
		}
		
		[self loadURL:nil];
	}
	if ([type isEqualToString:@"viewSourceRequest"]) {
		NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
		NSString *codeString = [[[[currentWebView mainFrame] dataSource] representation] documentSource];
		NSString *title = [[[currentWebView mainFrame] dataSource] pageTitle];
		if (!title) {
			title = @"";
		}
		[dic setValue:@"viewSourceResponse" forKey:@"notificationType"];
		[dic setValue:title forKey:@"sourceTitle"];
		[dic setValue:codeString forKey:@"sourceCode"];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"DBSourceNotification" object:self userInfo:dic];
		[dic release];
	}
	if ([type isEqualToString:@"saveWindowPosition"]) {
		[[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithFloat:([slideWindow frame].origin.y)] forKey:@"slideWindowY"];
		[[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithFloat:([slideWindow frame].size.width)] forKey:@"slideWindowWidth"];
	}
}

- (void)openURL:(NSAppleEventDescriptor*)event withReplyEvent:(NSAppleEventDescriptor*)replyEvent {
//
//	Called when a link is opened from another app (if DeskBrowse is the default browser)
//
	[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
	
    NSString *urlString = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
    NSURL *URL = [NSURL URLWithString:urlString];
	NSURLRequest* URLRequest = [NSURLRequest requestWithURL: URL];
	WebView* webViewToLoadURL = currentWebView;
		
	if ([[currentWebView mainFrame] dataSource] != nil || [[currentWebView mainFrame] provisionalDataSource] != nil)
	{
		webViewToLoadURL = [self newWebView];
		
		[tabController newTabWithWebView: webViewToLoadURL select: YES URLString: urlString];
	}
	
	if (!windowIsVisible) {
		[self slideInForcingToFront: YES];
	}
	
	[[webViewToLoadURL mainFrame] loadRequest: URLRequest];
}

- (IBAction)toggleActionMenu:(id)sender {
	if (actionMenuVisible)
	{
		// Action menu is visible
		
		[actionMenuWindow fadeOut];
		
		actionMenuVisible = NO;
	} 
	else
	{
		// Action menu is not visible
		if (inWebsposeMode) {
			[actionMenuWindow setFrame: NSMakeRect([actionMenuWindow frame].origin.x, [websposeWindow frame].origin.y + 15, [actionMenuWindow frame].size.width, [actionMenuWindow frame].size.height) display: YES];
		} else {
			[actionMenuWindow setFrame: NSMakeRect([actionMenuWindow frame].origin.x, [slideWindow frame].origin.y + 47, [actionMenuWindow frame].size.width, [actionMenuWindow frame].size.height) display: YES];
		}
		
		[actionMenuWindow orderFront: self];
		[actionMenuWindow fadeIn];
		
		actionMenuVisible = YES;
	}
}

- (IBAction) toggleBookmarkBar: (id) sender
{
	//
	// ---------------------------------------------
	// FIX THIS - move the webview up when removing
	// ---------------------------------------------
	//
	
	BOOL isHidden = [bookmarkBar isHidden];
	
	float height = [bookmarkBar frame].size.height;
	NSRect wvf = [currentWebView frame];
	
	if (isHidden)
	{
		[bookmarkBar setHidden: NO];
		//wvf.origin.y += height;
		wvf.size.height += height;
		[currentWebView setFrame:wvf];
	}
	else
	{
		[bookmarkBar setHidden: YES];
		[bookmarkBar removeFromSuperview];
		//wvf.origin.y -= height;
		wvf.size.height -= height;
		[currentWebView setFrame:wvf];
		[[slideWindow contentView] setNeedsDisplay:YES];
	}
}

- (void)windowDidResignKey:(NSNotification *)aNotification {
	if ([aNotification object] == actionMenuWindow) { // if we are talking about the action menu
		if ([NSApp keyWindow] != actionMenuWindow) {  // see if it really did resign
			if (actionMenuVisible) {				  // if its visible
				[self toggleActionMenu:nil];			  // hide it!
			}
		}
	}
}

- (BOOL)inWebspose {
	return inWebsposeMode;
}

- (void) toggleWebspose
{	
	if (!inWebsposeMode) // Enter Websposé
	{
		if (actionMenuVisible)
		{
			[self toggleActionMenu: nil];
		}
		
		[websposeWindow setAlphaValue:0.0];
		[NSApp activateIgnoringOtherApps: YES];
		[self lock: YES];
		
		NSRect screenRect = [[NSScreen mainScreen] frame];
		
		[websposeWindow setFrame: screenRect display: YES];
		[websposeWindow makeKeyAndOrderFront: self];
		[websposeWindow fadeIn];
		
		[WindowLevel setWindowLevel: [websposeWindow level]];
		
		[bookmarkBar setBookmarkController: nil];
		[websposeBookmarkBar setBookmarkController: bookmarkController];
		
		[websposeWebViewBox setContentView: tabView];
		[websposeTabBarBox	setContentView: tabBar];
				
		[self setStatusText:	[self statusText]];
		[self setTitleText:		[self titleText]];
		
		[websposeURLField selectText:self];
		
		inWebsposeMode = YES;
	}
	else // Exit Websposé
	{
		NSString* password = [WebsposePassword websposePassword];
				
		BOOL shouldToggle = NO;
		
		if (password != nil && [password length] > 0)
		{
			[websposePasswordField		setStringValue: @""];
			[websposePasswordStatus		setStringValue: @""];
			
			[NSApp beginSheet:			websposePasswordWindow modalForWindow: websposeWindow modalDelegate: nil didEndSelector: nil contextInfo: nil];
			[NSApp runModalForWindow:	websposePasswordWindow];
			
			// Modal is running now...
			
			[NSApp endSheet: websposePasswordWindow];
			
			[websposePasswordWindow orderOut: self];
			
			NSString* enteredString = [websposePasswordField stringValue];
			
			if ([enteredString isEqualToString: password]/* || [enteredString caseInsensitiveCompare: NSUserName()] == NSOrderedSame*/)
			{
				shouldToggle = YES;
			}
			else
			{
				shouldToggle = NO;
			}
		}
		else
		{
			shouldToggle = YES;
		}
		
		if(shouldToggle)
		{
			if (actionMenuVisible)
			{
				[self toggleActionMenu: nil];
			}
			
			// I stopped using fadeOut here (1-3-06) because it looks odd with the view switching and all,
			// but feel free to switch back if you think it looks better.
			//
			[websposeWindow orderOut: nil]; //fadeOut];
			//
			
			if (windowIsVisible)
			{
				[slideWindow makeKeyAndOrderFront: self];
			}
			
			[WindowLevel setWindowLevel: [slideWindow level]];
						
			[webViewBox setContentView: tabView];
			[tabBarBox	setContentView: tabBar];
			
			[self setStatusText:	[self statusText]];
			[self setTitleText:		[self titleText]];
						
			[websposeBookmarkBar setBookmarkController: nil];
			[bookmarkBar setBookmarkController: bookmarkController];
			[bookmarkBar reloadData];
			
			[self lock: NO];

			inWebsposeMode = NO;
		}
	}
}

- (void) lock: (BOOL) shouldLock
{
    if (shouldLock) // LOCK
    {
        if (symbolicHotKeyController == nil)
        {
            symbolicHotKeyController = [[SymbolicHotKeyController alloc] init];
        }
        
        [symbolicHotKeyController saveHotKeyState];
        
        
        // Disable Force-Quit, Application switch, and hide menubar and dock
        SetSystemUIMode(kUIModeAllHidden, kUIOptionDisableForceQuit | kUIOptionDisableSessionTerminate | kUIOptionDisableProcessSwitch | kUIOptionDisableAppleMenu);
        
        // Disable hide and quit
        NSMenu*        mainMenu        = [NSApp mainMenu];
        NSMenu*        appMenu            = [[mainMenu itemAtIndex: 0]  submenu];
        int            indexOfQuitItem = [appMenu indexOfItemWithTarget: NSApp andAction: @selector(terminate:)];
		int            indexOfHideItem = [appMenu indexOfItemWithTarget: NSApp andAction: @selector(hide:)];
		NSMenuItem*    quitMenuItem    = [appMenu itemAtIndex: indexOfQuitItem];
		NSMenuItem*    hideMenuItem    = [appMenu itemAtIndex: indexOfHideItem];
		
		[quitMenuItem setKeyEquivalent: @""];
		[hideMenuItem setKeyEquivalent: @""];
    }
	else // UNLOCK
	{
        // Enable all that was disabled
        SetSystemUIMode(kUIModeNormal, 0);
        
        
        [symbolicHotKeyController restoreHotKeyState];
        
        
        // Enable hide and quit
        NSMenu*        mainMenu        = [NSApp mainMenu];
        NSMenu*        appMenu            = [[mainMenu itemAtIndex: 0]  submenu];
        int            indexOfQuitItem = [appMenu indexOfItemWithTarget: NSApp andAction: @selector(terminate:)];
		int            indexOfHideItem = [appMenu indexOfItemWithTarget: NSApp andAction: @selector(hide:)];
		NSMenuItem*    quitMenuItem    = [appMenu itemAtIndex: indexOfQuitItem];
		NSMenuItem*    hideMenuItem    = [appMenu itemAtIndex: indexOfHideItem];
		
		[quitMenuItem setKeyEquivalent: @"q"];
		[hideMenuItem setKeyEquivalent: @"h"];
    }
}


- (void) loadURLNotification: (NSNotification*) notification
{
	NSString* URLString = [[notification userInfo] objectForKey: @"URLString"];
	
	if(URLString != nil)
	{
		[self loadURLString: URLString];
	}
}

- (void) loadURLString: (NSString*) URLString
{
	if (URLString != nil)
	{
		Tab*			tab			= [tabController tabWithWebView: currentWebView];
		NSTextField*	field		= [self URLField];
		NSURL*			URL			= [NSURL URLWithString: [URLFormatter formatAndReturnStringWithString: URLString]];
		NSURLRequest*	URLRequest	= [NSURLRequest requestWithURL: URL cachePolicy: NSURLRequestUseProtocolCachePolicy timeoutInterval: 60.0];

		if(tab != nil)
		{
			[tab setURLString: URLString];
		}
		
		if (!windowIsVisible && !inWebsposeMode) {
			[self slideInForcingToFront: YES];
		}
		
		[[currentWebView mainFrame] loadRequest: URLRequest];
		
		[self updateButtons];
	}
}

- (void)viewPageSource {
	[self showSourceWindow:self];
}

- (void) slideWindowResized: (NSNotification*) notification
{
	[self setStatusText:	[self statusText]];
	[self setTitleText:		[self titleText]];
}

- (void)setStatusText:(NSString *)status
{
	if (status != currentStatus)
	{
		[status			retain];
		[currentStatus	release];
		
		currentStatus = status;
	}
		
	[statusField			setStringValue: currentStatus];
	[websposeStatusField	setStringValue: currentStatus];
}

- (NSString *)statusText {
	return currentStatus;
}

- (void)setTitleText:(NSString *)title
{
	if(title != currentTitle)
	{
		[title			retain];
		[currentTitle	release];
		
		currentTitle = title;
	}
	
	[titleField			setStringValue: currentTitle];
	[websposeTitleField	setStringValue: currentTitle];
}

- (NSString *)titleText {
	return currentTitle;
}

- (LocationTextField*) URLField
{
	return inWebsposeMode ? websposeURLField : urlField;
}

- (void)setURLText:(NSString *)url
{
	if(url == nil)
	{
		[urlField			setStringValue: @""];
		[websposeURLField	setStringValue: @""];
	}
	else
	{
		[urlField			setStringValue: url];
		[websposeURLField	setStringValue: url];
	}
}

- (NSString *)URLText {
	return [[self URLField] stringValue];
}

- (NSString*) searchFieldText
{
	NSTextField* field = inWebsposeMode ? websposeSearchField : searchField;
	return [field stringValue];
}

- (void) setFavicon: (NSImage*) favicon
{
	[urlField setImage: favicon];
	[websposeURLField setImage: favicon];
}

- (void) syncVariablesWithUserPrefs
{
	NSUserDefaults*	userDefaults;
	
	userDefaults		= [[NSUserDefaults standardUserDefaults] retain];
	
	homePage			= [[userDefaults objectForKey: kHomePage] retain];
	
	BOOL showMenuExtra	= [userDefaults boolForKey: kShowMenuExtra];
	if (showMenuExtra) {
		if (!statusController) {
			statusController = [[StatusItemController alloc] initWithController:self];
		}
	} else {
		if (statusController) {
			[statusController release];
			statusController = nil;
		}
	}
	
	[userDefaults release];
}

- (void)syncLoadingStateWithStatus {
	NSString* statusText = [self statusText];
	if(loadingState != statusText)
	{
		[loadingState release];
		loadingState = [statusText retain]; // set the loading state to the status text
	}
}

/*- (void) registrationStatusChanged
{
	RegistrationController* registrationController = [RegistrationController globalInstance];
	
	[registrationMenuItem setTitle: [registrationController titleOfRegistrationMenuItem]];
}*/

#pragma mark -

#pragma mark IBActions

- (IBAction)loadURL:(id)sender {
	Tab*			tab		= [tabController tabWithWebView: currentWebView];
	NSTextField*	field	= [self URLField];
	NSString *URLString;
	if ([[field stringValue] hasPrefix:@":"]) {
		URLString = [field stringValue];
	} else {
		URLString = [URLFormatter formatAndReturnStringWithString:[field stringValue]];
	}
	if (![[URLString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
		// if the url is not nothing, then: check to see if its a javascript statement
		if ([URLString hasPrefix:@"javascript:"]) {
			NSString *js = [URLString substringFromIndex:11];
			[currentWebView stringByEvaluatingJavaScriptFromString:js];
			return;
		} else if ([URLString hasPrefix:@"file://"]) {
			NSString *filePath = [URLString substringFromIndex:7];
			
			// is it a directory or a file?
			if ([[NSFileManager defaultManager] fileExistsAtPath: [filePath stringByReplacingPercentEscapesUsingEncoding: NSASCIIStringEncoding]])
			{
				NSDictionary *fileAtts = [[NSFileManager defaultManager] fileAttributesAtPath:filePath traverseLink:YES];
				if ([[fileAtts objectForKey:@"NSFileType"] isEqualTo:@"NSFileTypeDirectory"]) {
					[[NSWorkspace sharedWorkspace] selectFile:filePath inFileViewerRootedAtPath:[filePath stringByDeletingLastPathComponent]];
					return;
				}
			}
		} else if ([URLString hasPrefix:@":"]) {
			/* scan for some commands:
			:apache {args} - load default apache root (plus args)
			:home - go to user's home page
			:help - sgs forums
			:useragent - show deskbrowse user agent info
			:ip - user's ip address information
			:clear, :cls - loads about:blank (clears the page)
			:wikip {args} - performs a wikipedia search
			*/
			
			if ([URLString hasPrefix:@":apache"]) {
				// apache command
				NSString *root = [NSString stringWithFormat:@"http://localhost/~%@/", NSUserName()];
				// check for command arguments
				NSRange spc = [URLString rangeOfString:@" "];
				if (spc.location != NSNotFound && [URLString length] > 8) {
					// there are other arguments, stick those to the end
					NSString *_args = [URLString substringFromIndex:spc.location + 1];
					NSString *args = [_args stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
					root = [NSString stringWithFormat:@"%@%@", root, args];
				}
				[self loadURLString:root];
				return;
			} else if ([URLString isEqualToString:@":home"]) {
				// load home page
				[self goHome:self];
				return;
			} else if ([URLString isEqualToString:@":help"]) {
				// sgs forums
				[self loadURLString:@"http://bb.sgs-international.com"];
				return;
			} else if ([URLString isEqualToString:@":useragent"]) {
				// user agent
				[self loadURLString:@"about:blank"];
				NSString *javascript = @"javascript:document.open();document.write(\"<html><head><title>User Agent Information</title></head><body><font size='-1'>\"+navigator.userAgent+\"</font></body></html>\");document.close();";
				[currentWebView stringByEvaluatingJavaScriptFromString:javascript];
				return;
			} else if ([URLString isEqualToString:@":ip"]) {
				// ip address
				[self loadURLString:@"about:blank"];
				NSString *privateip = [NSString stringWithCString:GetPrivateIP()];
				NSString *tmpFile = [NSString stringWithFormat:@"/Users/%@/.dbiptmp", NSUserName()];
				NSString *command = [NSString stringWithFormat:@"curl http://www.whatismyip.org -o \"%@\"", tmpFile];
				system([command UTF8String]);
				NSString *contents = [NSString stringWithContentsOfFile:tmpFile];
				[[NSFileManager defaultManager] removeFileAtPath:tmpFile handler:nil];
				NSString *publicip;
				if (!contents || [contents isEqualToString:@""]) {
					publicip = @"(Error locating public IP Address)";
				} else {
					publicip = contents;
				}
				NSString *javascript = [NSString stringWithFormat:@"javascript:document.open();document.write(\"<html><head><title>IP Address Information</title></head><body><font size='-1'>Public IP: %@<br>Private IP: %@</font></body></html>\");document.close();", publicip, privateip];
				[currentWebView stringByEvaluatingJavaScriptFromString:javascript];
				return;
			} else if ([URLString isEqualToString:@":clear"] || [URLString isEqualToString:@":cls"]) {
				// clear the webpage
				[self loadURLString:@"about:blank"];
				return;
			} else if ([URLString hasPrefix:@":wikip"]) {
				// wikipedia search command
				NSString *url = @"http://www.wikipedia.com";
				NSRange spc = [URLString rangeOfString:@" "];
				if (spc.location != NSNotFound && [URLString length] > 7) {
					// there are other arguments, make a search url
					// TODO: replace " " with "+"
					NSString *_args = [URLString substringFromIndex:spc.location + 1];
					NSString *args = [_args stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
					url = [NSString stringWithFormat:@"http://www.wikipedia.com/search-redirect.php?search=%@&language=en&go=++%3E++&go=Go", args];
				}
				[self loadURLString:url];
				return;
			} else if ([URLString hasPrefix:@":"]) {
				// unknown command
				NSBeep();
				return;
			}
		}

		[self loadURLString: URLString];
	}
}

- (IBAction) websposeEnterPassword: (id) sender
{
	NSString*		password		= [WebsposePassword websposePassword];
	NSString*		enteredString	= [websposePasswordField stringValue];
	
	if (password == nil || [enteredString isEqualToString: password]/* || [enteredString caseInsensitiveCompare: NSUserName()] == NSOrderedSame*/)
	{
		[NSApp stopModal];
	}
	else
	{
		[websposePasswordStatus setStringValue: @"Incorrect password"];
	}
}

- (IBAction) websposeCancelPassword: (id) sender
{
	[NSApp stopModal];
}

- (IBAction)saveCurrentPage:(id)sender {
	NSWindow *kw = [NSApp keyWindow];
	if ([kw isEqualTo:slideWindow] || [kw isEqualTo:websposeWindow]) {
		NSSavePanel *sp = [NSSavePanel savePanel];
		int result = NSCancelButton;
		NSString *file = nil;
		NSString *source = nil;
		result = [sp runModal];
		if (result == NSOKButton) {
			file = [sp filename];
			source = [[[[currentWebView mainFrame] dataSource] representation] documentSource];
			[source writeToFile:file atomically:YES];
		}
	} else {
		if ([kw isEqual:[sourceWindowController window]]) {
			[sourceWindowController saveCode:nil];
		}
	}
}

- (IBAction) showBookmarkWindow: (id) sender
{
	if(!bookmarkWindowController)
	{
//		bookmarkWindowController = [[BookmarkWindowController alloc] initWithWindowNibName: @"Bookmarks" bookmarkController: bookmarkController];
	}
		
//	[bookmarkWindowController showWindow: self];
	[bookmarkController showWindow: nil];
}

- (IBAction) showBookmarkImportWindow: (id) sender
{
	if (bookmarkImportWindowController == nil)
	{
		bookmarkImportWindowController = [[BookmarkImportWindowController alloc] initWithWindowNibName: @"ImportBookmarks" bookmarkController: bookmarkController];
	}
	
	[bookmarkImportWindowController showWindow: self];
}

- (IBAction)showDownloadWindow:(id)sender {	
	[downloadController showWindow: self];
}

- (IBAction) showHistoryWindow: (id) sender
{
	if(!historyWindowController)
	{
		historyWindowController = [[HistoryWindowController alloc] initWithWindowNibName: @"History" historyController: historyController];
	}
	
	[historyWindowController showWindow: self];
}

/*- (IBAction) showRegistrationWindow: (id) sender
{
	RegistrationController* registrationController = [RegistrationController globalInstance];
	
	[registrationController displayUserInterface];
}*/

- (IBAction) addBookmark: (id) sender
{
	NSWindow*	currentWindow	= [self currentWindow];
	NSURL*		bookmarkURL		= nil;
	NSString*	bookmarkTitle	= nil;
		
	Tab*		currentTab	= [tabController selectedTab];
	NSString*	URLString	= [currentTab URLString];
	
	if (!URLString)
	{
		URLString = @"";
	}
	
	bookmarkURL		= [NSURL URLWithString: URLString];
	bookmarkTitle	= [currentTab title];
	
	[self showBookmarkWindow: nil];
	
	[bookmarkController newBookmarkWithURL: bookmarkURL title: bookmarkTitle window: [bookmarkWindowController window]];
}

- (IBAction) showPrefWindow: (id) sender
{
	if(!prefController)
	{
		prefController = [[PreferenceController alloc] initWithWindowNibName: @"Preferences"];
	}
	
	[prefController showWindow: self];
}

- (IBAction) showSourceWindow: (id) sender
{
	NSString *resPath = [[[NSBundle mainBundle] resourcePath] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
	NSString *req = [[[[[currentWebView mainFrame] dataSource] request] URL] absoluteString];
	
	NSString *code = @"";
	if ([req rangeOfString:resPath].location != NSNotFound)
	{
		NSBeep();
	}
	else
	{
		if(!sourceWindowController)
		{
			sourceWindowController = [[ViewSourceWindowController alloc] initWithWindowNibName: @"Source"];
		}
		
		code = [[[[currentWebView mainFrame] dataSource] representation] documentSource];
		NSString *title = [[[currentWebView mainFrame] dataSource] pageTitle];
		[sourceWindowController setTitle:[NSString stringWithFormat:@"Source of \"%@\"", title]];
		[sourceWindowController	setSourceCode:code];
		[sourceWindowController	showWindow:self];
	}
}

- (IBAction)stopLoading:(id)sender {
	[currentWebView stopLoading:sender];
}

- (IBAction) selectTabRight: (id) sender
{
	[tabController selectTabRight];
}

- (IBAction) selectTabLeft: (id) sender
{
	[tabController selectTabLeft];
}

- (IBAction)googleSearch:(id)sender {
	NSString* searchString = [self searchFieldText];
	
	[searchField			setStringValue: searchString];
	[websposeSearchField	setStringValue: searchString];
	
	if (![[searchString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
		// if the search is not nothing, then:
		NSString *query = [[NSString alloc] init];
		query = [[searchString componentsSeparatedByString:@" "] componentsJoinedByString:@"+"]; // replace spaces with pluses
		query = [query stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
		query = [NSString stringWithFormat:@"http://www.google.com/search?q=%@", query];
		
		[self loadURLString: query];
	}
}

- (IBAction)back:(id)sender
{
	if([currentWebView canGoBack])
	{
		[currentWebView goBack];
		[self updateButtons];
	}
}

- (IBAction)forward:(id)sender
{
	if([currentWebView canGoForward])
	{
		[currentWebView goForward];
		[self updateButtons];
	}
}

- (IBAction)reload:(id)sender
{
	if(reloadEnabled)
	{
		WebDataSource*	dataSource				= [[currentWebView mainFrame] dataSource];
		WebDataSource*	provisionalDataSource	= [[currentWebView mainFrame] provisionalDataSource];
		NSURL*			URL						= [[dataSource request] URL];
		NSURL*			pURL					= [[provisionalDataSource request] URL];
		
		Tab* tab = [tabController tabWithWebView: currentWebView];
		
		NSString *resPath = [[[NSBundle mainBundle] resourcePath] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
		NSString *req = [[[[[currentWebView mainFrame] dataSource] request] URL] absoluteString];
		
		if ([req rangeOfString:resPath].location != NSNotFound) {
			// trying to reload an error page
			// setting these to null will cause it to reload based on the tab's url
			URL = nil;
			pURL = nil;
		}
		
		if(URL || pURL)
		{
			[currentWebView reload: sender];
			[self setURLText: URL ? [URL absoluteString] : [pURL absoluteString]];
		}
		else
		{	
			if(tab)
			{
				NSString* URLString = [tab URLString];
				
				if(URLString)
				{
					[self loadURLString: URLString];
				}
			}
		}
	}
}

- (IBAction)goHome:(id)sender {
	// load the home page
	NSString *hp = (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:kHomePage];
	[self loadURLString: hp];
}

- (IBAction)makeTextLarger:(id)sender {
	[currentWebView makeTextLarger:sender];
}

- (IBAction)makeTextSmaller:(id)sender {
	[currentWebView makeTextSmaller:sender];
}

- (IBAction)showQDownloadWindow:(id)sender {
	[quickDownloadWindow makeKeyAndOrderFront:self];
}

- (void)toggleSlideBrowse {
	if(!inWebsposeMode)
	{
		if (!windowIsVisible) {
			// window is off the screen
			[self slideInForcingToFront: YES]; // slide in
			[currentWebView setHostWindow:slideWindow];
		} else if (windowIsVisible) {
			// window is on the screen
			[self slideOut]; // slide out
		}
	}
}

- (void)slideInForcingToFront: (BOOL) forceToFront {
	// [regs
	//RegistrationController* registrationController	= [RegistrationController globalInstance];
	//BOOL					registered				= [registrationController registered];
	[NSApp activateIgnoringOtherApps: forceToFront];
	[slideWindow setOnScreen: YES];
	windowIsVisible = YES; // make our window visible variable YES
}

- (void)slideOut {
	[slideWindow setOnScreen: NO];
	
	windowIsVisible = NO;
}

- (void)filterErrorMessage:(NSString *)msg forWebView: (WebView*) webView
{
//	Tab* tab = [tabController tabWithWebView: webView];
//	
//	if ([msg isEqualTo:@"Frame Load Interrupted"])
//	{
//		if ([[self URLText] hasPrefix:@"http://"])
//		{
//			// download should have started from the mime type check
//			msg = @"Done";
//		} else if ([[self URLText] hasPrefix:@"file://"]) {
//			if ([self handleFileProtocolForPath:[[self URLText] substringFromIndex:7]]) {
//				msg = @"Done";
//			}
//		}
//	}
//
//	if(tab)
//	{
//		[tab setStatus: msg];
//	}
//	
//	if(webView == currentWebView)
//	{
//		[self setStatusText:msg];
//	}
}

- (IBAction)close:(id)sender {
	NSWindow* keyWindow = [NSApp keyWindow];

	if(keyWindow)
	{
		if(keyWindow == slideWindow || keyWindow == websposeWindow)
		{
			[tabController removeTab: [tabController selectedTab] redraw: YES resize: YES];
		}
		else
		{
			[keyWindow close];
		}
	}
}

- (IBAction) closeAllTabs: (id) sender
{
	[tabController removeAllTabs]; // This will close all tabs except the selected one
}

- (IBAction)newBlankTab:(id)sender {
	WebView*		newView		= [self newWebView];
	NSUserDefaults* defaults	= [NSUserDefaults standardUserDefaults];
	
	if([defaults boolForKey: kSelectNewTabs])
	{
		[tabController newTabWithWebView: newView select: YES];
	}
	else
	{
		[tabController newTabWithWebView: newView select: NO];
	}
}

- (IBAction)openLocation:(id)sender {
	if ([urlField isHidden]) {
		[searchField setHidden:NO];
		[urlField setHidden:NO];
	}
	[[self URLField] selectText:self];
}

/*
 
 *****************************************************************************************************
 *****************************************************************************************************
 *****************************************************************************************************
 
 */


// Set button visibility

- (void) updateButtons
{
	/* Back */
	
	if ([currentWebView canGoBack])
	{
		[backMenuItem	setState: NSOnState];
		
		[back			setEnabled:YES];
		
		[websposeBack	setEnabled:YES];
	}
	else
	{
		[backMenuItem	setEnabled: NO];
		
		[back			setEnabled:NO];
		
		[websposeBack	setEnabled:NO];
	}

	
	/* Forward */
	
	if ([currentWebView canGoForward])
	{
		[forwardMenuItem	setEnabled: YES];
		
		[forward			setEnabled:YES];
		
		[websposeForward	setEnabled:YES];
	}
	else
	{
		[forwardMenuItem	setEnabled: NO];
		
		[forward			setEnabled:NO];
		
		[websposeForward	setEnabled:NO];
	}

	
	/* Stop */
	
	if (stopEnabled)
	{
		[stopMenuItem	setEnabled: YES];
		
		[stop			setEnabled:YES];
		
		[websposeStop	setEnabled:YES];
	}
	else
	{
		[stopMenuItem	setEnabled: NO];
		
		[stop			setEnabled:NO];
		
		[websposeStop	setEnabled:NO];
	}

	
	/* Reload */
	
	if (reloadEnabled)
	{
		[reloadMenuItem	setEnabled: YES];
		
		[reload			setEnabled:YES];
		
		[websposeReload	setEnabled:YES];
	}
	else
	{
		[reloadMenuItem	setEnabled: NO];
		
		[reload			setEnabled:NO];
		
		[websposeReload	setEnabled:NO];
	}

	
	/* Spinner */
	
	if (spinnerEnabled)
	{
		[urlField animate: YES];
		[websposeURLField animate: YES];
	}
	else
	{
		[urlField animate: NO];
		[websposeURLField animate: NO];
	}
	
	// back button menu
	[back setMenu:[historyController menuForHistory]];
}

/*
 
 *****************************************************************************************************
 *****************************************************************************************************
 *****************************************************************************************************
 
 */

- (void)webView:(WebView *)sender
		decidePolicyForNavigationAction:(NSDictionary *)info
		request:(NSURLRequest *)request
		  frame:(WebFrame *)frame
		decisionListener:(id<WebPolicyDecisionListener>)listener {
	
	int modifierKeys = [[info objectForKey:WebActionModifierFlagsKey] intValue];
	int actionType = [[info objectForKey:WebActionNavigationTypeKey] intValue];
	
	if (actionType == WebNavigationTypeLinkClicked) {
		WebView *new = [self newWebView];
		if (modifierKeys & NSCommandKeyMask) {
			[tabController newTabWithWebView:new select:YES];
			[[new mainFrame] loadRequest:request];
			[listener ignore];
		} else if (modifierKeys & NSAlternateKeyMask) {
			[tabController newTabWithWebView:new select:NO URLString:[[request URL] absoluteString]];
			[[new mainFrame] loadRequest:request];
			[listener ignore];
		} else if (![NSURLConnection canHandleRequest:request]) {
			[[NSWorkspace sharedWorkspace] openURL:[request URL]];
			[listener ignore];
		} else {
			[listener use];
		}
	} else {
		[listener use];
	}
}

- (void)webView:(WebView*)webView 
        decidePolicyForMIMEType:(NSString*)type 
        request:(NSURLRequest*)request 
		  frame:(WebFrame*)frame 
        decisionListener:(id<WebPolicyDecisionListener>)listener
{
    NSString *extension = [[[request URL] path] pathExtension];
    if ([extension isEqualToString:@"html"] || [extension isEqualToString:@"htm"]) {
        [listener use];
        return;
    }
    if ([WebView canShowMIMEType:type] || [WebView canShowMIMETypeAsHTML:type]) {
        [listener use];
        return;
    }
	NSString *currentPage = [[[[frame dataSource] request] URL] absoluteString];
	[downloadController prepareForDownloadWithRequest:request];
	
	Tab* tab = [tabController tabWithWebView: webView];
	if(tab)
	{
		[tab setStatus: @"Done"];
		[tab setLoading: NO];
		[tab setURLString:currentPage];
	}
	
	[self setStatusText:@"Done"];
	[self setURLText:currentPage];
	[self syncLoadingStateWithStatus];
	spinnerEnabled  = NO;
	stopEnabled     = NO;
	reloadEnabled   = YES;
	[self updateButtons];
	
	[self showDownloadWindow:nil];
	
	
	[listener ignore];
}

/*

*****************************************************************************************************
*****************************************************************************************************
*****************************************************************************************************

*/

- (WebView*) newWebView
{
	WebView*		newWebView	= [[[WebView alloc] initWithFrame: [tabView frame]] autorelease];
	WebPreferences*	webPrefs	= [WebPreferences standardPreferences];
	[webPrefs setAutosaves: YES];
	
	[newWebView setFrameLoadDelegate:self];
	[newWebView setUIDelegate:self];
	[newWebView setPolicyDelegate:self];
	[newWebView setDownloadDelegate: self];
	
	if ([newWebView respondsToSelector:@selector(toggleSmartInsertDelete:)])
		[newWebView toggleSmartInsertDelete:nil];
	
	NSMutableString *localAgent = [NSMutableString stringWithString:[newWebView userAgentForURL:[NSURL URLWithString:@"http://localhost"]]];
	if ([localAgent rangeOfString:@"Safari"].location == NSNotFound) {
		[localAgent replaceOccurrencesOfString:@"Gecko" withString:@"Gecko, Safari" options:NSLiteralSearch range:NSMakeRange(0, [localAgent length])];
	}
	
	NSString *appName = [NSString stringWithFormat:@"DeskBrowse/%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
	
	[newWebView setApplicationNameForUserAgent:appName];
	[newWebView setCustomUserAgent:[NSString stringWithFormat:@"%@ DeskBrowse/%@", localAgent, [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
	[newWebView setPreferencesIdentifier:@"DeskBrowseWebPrefs"];
	[newWebView setHostWindow:slideWindow];
	[newWebView setGroupName:@"MyDocument"];
	
	[newWebView setPreferences: webPrefs];
	
	return newWebView;
}

- (void) tabChanged: (NSNotification*) notification
{
	// Change currentWebView
	[currentWebView release];	
	currentWebView = [[[notification  userInfo] objectForKey: @"WebView"] retain];
	
	// Get selected tab
	Tab*			tab						= [[notification  userInfo] objectForKey: @"Tab"];
	
	// Set up status stuff
	WebDataSource*	dataSource				= [[currentWebView mainFrame] dataSource];
	WebDataSource*	provisionalDataSource	= [[currentWebView mainFrame] provisionalDataSource];
	NSImage*		faviconImage			= [tab favicon];
	NSString*		URLString				= [tab URLString];
	NSString*		titleString				= [tab title];
	NSString*		statusString			= [tab status];
	BOOL			loading					= [tab loading];
	
	if(!statusString)
	{
		statusString = @"";
	}
	
	if(!titleString)
	{
		titleString = @"";
	}
	
	if(!URLString)
	{
		URLString = @"";
	}
	
	if(dataSource) // This will be nil if the page is not done loading
	{		
		/*// Loading
		if([dataSource isLoading])
		{
			loading = YES;
		}
		else
		{
			loading = NO;
		}*/
		
		// Page URL
		if(!URLString)
		{
			URLString = [[[dataSource request] URL] absoluteString];
			
			if(!URLString)
			{
				URLString = @"";
			}
		}
		
		// Page title
		if(!titleString)
		{
			titleString = [dataSource pageTitle];
			
			if(!titleString)
			{
				titleString = @"";
			}
		}
	}
	else if(provisionalDataSource)  // This will be nil if the page hasn't started loading or is done loading
	{		
		/*// Loading
		if([provisionalDataSource isLoading])
		{
			loading = YES;
		}
		else
		{
			loading = NO;
		}*/
		
		// Page URL
		if(!URLString)
		{
			URLString = [[[provisionalDataSource request] URL] absoluteString];
			
			if(!URLString)
			{
				URLString = @"";
			}
		}
		
		// Page title
		if(!titleString)
		{
			titleString = [provisionalDataSource pageTitle];
			
			if(!titleString)
			{
				titleString = @"";
			}
		}
	}
	else
	{
		// Put any last minute initializtions here if necessary
	}
	
	if(loading)
	{
		spinnerEnabled	= YES;
		stopEnabled		= YES;
		reloadEnabled	= NO;
	}
	else
	{
		spinnerEnabled	= NO;
		stopEnabled		= NO;
		reloadEnabled	= YES;
	}
	
	if([URLString length] > 0)
	{
		[[self currentWindow] makeFirstResponder: [[tabView selectedTabViewItem] view]];
	}
	else
	{
		[[self URLField] selectText: self];
	}
		
	[self setStatusText: statusString];
	[self setTitleText: titleString];
	[self setURLText: URLString];
	[self setFavicon: faviconImage];
	[self updateButtons];
	[self syncLoadingStateWithStatus];
}

- (BOOL)actionMenuVisible {
	return actionMenuVisible;
}


#pragma mark -

#pragma mark NSWindow Delegate Methods

- (void) windowDidMove: (NSNotification*) aNotification
{
	if ([aNotification object] == slideWindow && !inWebsposeMode)
	{
		[actionMenuWindow setFrame: NSMakeRect([actionMenuWindow frame].origin.x, [slideWindow frame].origin.y + 47, [actionMenuWindow frame].size.width, [actionMenuWindow frame].size.height) display: YES];
	}
}

- (void) windowDidResize:(NSNotification *)aNotification
{
	if ([aNotification object] == slideWindow && !inWebsposeMode)
	{
		[actionMenuWindow setFrame: NSMakeRect([actionMenuWindow frame].origin.x, [slideWindow frame].origin.y + 47, [actionMenuWindow frame].size.width, [actionMenuWindow frame].size.height) display: YES];
	}
}


#pragma mark -

#pragma mark NSApplication Delegate Methods

- (void) mouseDown: (NSEvent*) theEvent
{
	NSPoint location = [theEvent locationInWindow];
	
	if ([theEvent window] != actionMenuWindow && actionMenuVisible)
	{
		if (inWebsposeMode && !NSMouseInRect(location, [webpsoseActionMenuButton frame], NO))
		{
			[self toggleActionMenu: self];
		}
		else if (!inWebsposeMode && !NSMouseInRect(location, [actionMenuButton frame], NO))
		{
			[self toggleActionMenu: self];
		}
	}
}

- (void) keyCombinationPressed: (KeyCombination) keys
{
	NSWindow* keyWindow	= [NSApp keyWindow];
	
	if(keyWindow == slideWindow || keyWindow == websposeWindow)
	{
		NSResponder* firstResponder	= [keyWindow firstResponder];
		
		if([firstResponder class] != [NSTextView class])
		{
			switch(keys)
			{
				case kCommandRightArrow:
				{
					[self forward: self];
					break;
				}
				case kCommandLeftArrow:
				{
					[self back: self];
					break;
				}
				case kCommandShiftRightArrow:
				{
					[self selectTabRight: self];
					break;
				}
				case kCommandShiftLeftArrow:
				{
					[self selectTabLeft: self];
					break;
				}
				default:
				{
					break;
				}
			}
		}
	}
}


#pragma mark -

- (void)applicationWillFinishLaunching:(NSNotification*)notification
{	
	[[NSAppleEventManager sharedAppleEventManager] setEventHandler:self andSelector:@selector(openURL:withReplyEvent:) forEventClass:'GURL' andEventID:'GURL'];
}

- (void) applicationDidFinishLaunching: (NSNotification*) notification
{
	// ---------------------------------------------
	// Used to be in awakeFromNib	
	
	// Set up hot-key listening
	
	[[NSApp hotKeyController] setSlideBrowseListener: self selector: @selector(toggleSlideBrowse)];
	[[NSApp hotKeyController] setWebsposeListener: self selector: @selector(toggleWebspose)];
	
	// Load homepage if the user wants to, select the URL field text otherwise
	
	NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
	BOOL			loadHomePage = [userDefaults boolForKey: kLoadHomePageOnLaunch];
	
	if (loadHomePage)
	{
		if ([[currentWebView mainFrame] dataSource] != nil || [[currentWebView mainFrame] provisionalDataSource] != nil)
		{
			WebView*		newWebView			= [self newWebView];
			NSURL*			homePageURL			= [NSURL URLWithString: [URLFormatter formatAndReturnStringWithString: homePage]];
			NSURLRequest*	homePageURLRequest	= [NSURLRequest requestWithURL: homePageURL cachePolicy: NSURLRequestUseProtocolCachePolicy timeoutInterval: 60.0];
			
			[tabController newTabWithWebView: newWebView select: NO URLString: [homePageURL absoluteString]];
			
			Tab* newTab = [tabController tabWithWebView: newWebView];
			
			if (newTab != nil)
			{	
				[[newWebView mainFrame] loadRequest: homePageURLRequest];
			}
		}
		else
		{
			[self goHome: self];
		}
	}
	else
	{
		[[self URLField] selectText:self];
	}
	
	
	// Enter SlideBrowse or Webposé mode if the user wants to
	
	int browserMode	 = [userDefaults integerForKey: kBrowserMode];
	
	if(browserMode == 1) // SlideBrowse
	{
		[self slideInForcingToFront: NO];
	}
	else if(browserMode == 2) // Websposé
	{
		[self toggleWebspose];
	}
	
	
	// Set up status item
	
	BOOL extra = [userDefaults boolForKey: kShowMenuExtra];
	if (extra) {
		if (!statusController) {
			statusController = [[StatusItemController alloc] initWithController:self];
		}
	} else {
		if (statusController) {
			[statusController release];
			statusController = nil;
		}
	}
		
	//
	// ---------------------------------------------
}


#pragma mark -

- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename {/*
	NSURL *furl = [NSURL fileURLWithPath:filename];
	[[currentWebView mainFrame] loadRequest:[NSURLRequest requestWithURL:furl]];
	if (!inWebsposeMode) {
		if (!windowIsVisible) {
			[self slideInForcingToFront: YES];
		}
	}
	return YES;*/
}

- (BOOL)application:(NSApplication *)sender openFileWithoutUI:(NSString *)filename {
	return [self application:sender openFile:filename];
}

- (void) application: (NSApplication*) sender openFiles: (NSArray*) filenames
{
	if (!inWebsposeMode && !windowIsVisible)
	{
		[self slideInForcingToFront: YES];
	}
	
	NSEnumerator*	fileNameEnumerator	= [filenames objectEnumerator];
	NSString*		currentFileName		= nil;
	
	while ((currentFileName = [fileNameEnumerator nextObject]) != nil)
	{
		NSURL*			fileURL				= [NSURL fileURLWithPath: currentFileName];
		NSString*		formattedFileName	= [fileURL absoluteString];
		NSURLRequest*	URLRequest			= [NSURLRequest requestWithURL: fileURL];
		
		WebView*		webViewToLoadFile	= currentWebView;
		
		if ([[currentFileName pathExtension] isEqualToString:@"url"]) {
			// note to ian:
			// url files are cross-platform (they are originally made for windows) file
			// that have a link in them, kind of like .webloc files on the mac
			NSString *contents = [NSString stringWithContentsOfFile:currentFileName];
			// hacky replace-all to get rid of dos line break characters in case this came from windows
			contents = [[contents componentsSeparatedByString:@"\r"] componentsJoinedByString:@""];
			
			NSArray *lines = [contents componentsSeparatedByString:@"\n"];
			NSString *current = nil;
			int i;
			for (i=0; i<[lines count]; i++) {
				current = [lines objectAtIndex:i];
				if ([current hasPrefix:@"URL"]) {
					// the URL= definition in the file
					NSURL *tmp = [NSURL URLWithString:[current substringFromIndex:4]];
					URLRequest = [NSURLRequest requestWithURL:tmp];
				}
			}
		}
		
		if ([[currentWebView mainFrame] dataSource] != nil || [[currentWebView mainFrame] provisionalDataSource] != nil)
		{
			webViewToLoadFile = [self newWebView];
			
			[tabController newTabWithWebView: webViewToLoadFile select: YES URLString: formattedFileName];
		}
		
		[[webViewToLoadFile mainFrame] loadRequest: URLRequest];
	}
	
	[NSApp replyToOpenOrPrint: NSApplicationDelegateReplySuccess];

/*
	int i;
	NSString *file = nil;
	NSURL *furl = nil;
	if (!inWebsposeMode) {
		if (!windowIsVisible) {
			[self slideInForcingToFront: YES];
		}
	}
	for (i=0; i<[filenames count]; i++) {
		file = [filenames objectAtIndex:i];
		NSString *file2 = [NSString stringWithFormat:@"file://localhost%@", [file stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
		furl = [NSURL fileURLWithPath:file];
		WebView *wv = [self newWebView];
		if (i == 0)
			[tabController newTabWithWebView:wv select:YES URLString:file2];
		else
			[tabController newTabWithWebView:wv select:NO URLString:file2];
		[[wv mainFrame] loadRequest:[NSURLRequest requestWithURL:furl]];
	}
	[NSApp replyToOpenOrPrint:NSApplicationDelegateReplySuccess];*/
}


#pragma mark -

- (void) applicationWillResignActive: (NSNotification*) aNotification
{
	if (actionMenuVisible)
	{
		[actionMenuWindow orderOut: self];
		actionMenuVisible = NO;
	}
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
	NSApplicationTerminateReply shouldTerminate = NSTerminateCancel;
	
	if (!downloadController || [downloadController deskBrowseShouldTerminate]) {
		shouldTerminate = NSTerminateNow;
	}
	
	return shouldTerminate;
}

- (void) applicationWillTerminate: (NSNotification*) aNotification
{
	[bookmarkController save];
}


#pragma mark -

#pragma mark WebKit

- (void) showErrorPageForReason:(NSString *)reason title:(NSString *)title webview:(WebView *)wv {
	// load the template html file
	NSString *resourcesPath = [[NSBundle mainBundle] resourcePath];
	NSURL *resURL = [NSURL fileURLWithPath:resourcesPath];
	NSString *errorPagePath = [[NSBundle mainBundle] pathForResource:@"error" ofType:@"html"];
	
	// replace the template entries with the real entries
	NSMutableString *content = [NSMutableString stringWithContentsOfFile:errorPagePath];
	NSRange range = NSMakeRange(0, [content length]);
	[content replaceOccurrencesOfString:@"{error.title}" withString:title options:NSLiteralSearch range:range];
	range = NSMakeRange(0, [content length]); // the range changed, so get it again
	[content replaceOccurrencesOfString:@"{error.text}" withString:reason options:NSLiteralSearch range:range];
	
	Tab *tab = [tabController tabWithWebView:wv];
	NSString *url = [tab URLString];
	[[wv mainFrame] loadHTMLString:content baseURL:resURL];
	[self setURLText:url];
	[tab setURLString:url];
}

- (BOOL)handleFileProtocolForPath:(NSString *)path webview:(WebView *)wv {
	if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
		[[NSWorkspace sharedWorkspace] selectFile:[path stringByExpandingTildeInPath] inFileViewerRootedAtPath:@""]; // show file in finder
		[self setStatusText:@"Done"];
		[self syncLoadingStateWithStatus];
		return YES;
	} else {
		[self showErrorPageForReason:@"The requested file cannot be found.  Please make sure that the entered URL is correct and try again." title:@"File Not Found" webview:wv];
		return NO;
	}
}
 
- (void)webView:(WebView *)sender
didStartProvisionalLoadForFrame:(WebFrame *)frame {
	Tab* tab = [tabController tabWithWebView: sender];
	NSString *urlString = [[[[frame provisionalDataSource] request] URL] absoluteString];
	
	if(tab)
	{
		if (frame == [sender mainFrame]) {
			[tab setLoading: YES];
			[tab setURLString: urlString];
			[tab setStatus: @"Resolving Host..."];
		}
	}
	
	if(sender == currentWebView) // if this is the visible webview
	{
		if (frame == [currentWebView mainFrame]) {
			[self setURLText:urlString];
			[self setStatusText:@"Resolving Host..."];
			
			[self syncLoadingStateWithStatus];
			spinnerEnabled  = YES;
			stopEnabled     = YES;
			reloadEnabled   = NO;
			[self updateButtons];
			
			[[self currentWindow] makeFirstResponder: currentWebView];
		}
	}
}

- (void)webView:(WebView *)sender didReceiveTitle:(NSString *)title
	   forFrame:(WebFrame *)frame {
	Tab* tab = [tabController tabWithWebView: sender];
	if(tab)
	{
		if (frame == [sender mainFrame]) {
			[tab setLabel: title];
			[tab setTitle: title];
			[tabBar setNeedsDisplay: YES];
		}
	}
	// only show new title if it was set by the main frame
	if(sender == currentWebView)
	{
		if (frame == [currentWebView mainFrame]) {
			[self setTitleText:title];
		}
	}
}

- (void)webView:(WebView *)sender didReceiveIcon:(NSImage *)image
	   forFrame:(WebFrame *)frame {
	Tab* tab = [tabController tabWithWebView: sender];
	
	if(tab)
	{
		if (frame == [sender mainFrame]) {
			[tab setFavicon: image];
		}
	}
	if(sender == currentWebView) // if this is the visible webview
	{
		if (frame == [currentWebView mainFrame]) {
			[self setFavicon: image];
		}
	}
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame {
	Tab* tab = [tabController tabWithWebView: sender];
	if(tab)
	{
		[tab setStatus: @"Done"];
		[tab setLoading: NO];
	}
	if (sender == currentWebView) {
		[self setStatusText:@"Done"];
		[self syncLoadingStateWithStatus];
		spinnerEnabled  = NO;
		stopEnabled     = NO;
		reloadEnabled   = YES;
		[self updateButtons];
	}
}

//- (void)webView:(WebView *)sender didFinishProvisionalLoadForFrame:(WebFrame *)frame {
//	[self webView:sender didFinishLoadForFrame:frame];
//}

- (void)webView:(WebView *)sender didFailProvisionalLoadWithError:(NSError *)error forFrame:(WebFrame *)frame {
	Tab* tab = [tabController tabWithWebView: sender];
	
	int code = [error code];
	
	if(tab)
	{
		[tab setStatus: @"Done"];
		[tab setLoading:NO];
	}
	if(sender == currentWebView) // if this is the visible webview
	{
		[self setStatusText:@"Done"];
		[self syncLoadingStateWithStatus];
		spinnerEnabled	= NO;
		stopEnabled		= NO;
		reloadEnabled	= YES;
		[self updateButtons];
	}
	NSURL *url;
	NSAlert *msg;
	int result;
	
	switch (code) {
		case NSURLErrorFileDoesNotExist:
		case NSURLErrorFileIsDirectory:
			[self handleFileProtocolForPath:[[self URLText] substringFromIndex:7] webview:sender];
			break;
			
		case NSURLErrorServerCertificateHasBadDate:
			// certificate error
			url = [NSURL URLWithString:[tab URLString]];
			msg = [NSAlert alertWithMessageText:@"Server Certificate Expired"
								  defaultButton:@"Yes"
								alternateButton:@"No"
									otherButton:nil 
					  informativeTextWithFormat:[NSString stringWithFormat:@"The certificate from this server has expired.  Would you like to load the page anyway?", [url host]]];
			result = [msg runModal];
			if (result == NSOKButton) {
				[NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:[url host]];
				[frame loadRequest:[NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0]];
				[self webView:sender didStartProvisionalLoadForFrame:frame]; // tell the gui thats it's loading
			}
			break;
		case NSURLErrorServerCertificateHasUnknownRoot:
			// certificate error
			url = [NSURL URLWithString:[tab URLString]];
			msg = [NSAlert alertWithMessageText:@"Untrusted Server Certificate"
								  defaultButton:@"Yes"
								alternateButton:@"No"
									otherButton:nil 
					  informativeTextWithFormat:[NSString stringWithFormat:@"The certificate from this server has been signed by an unknown authority.  Would you like to load the page anyway?", [url host]]];
			result = [msg runModal];
			if (result == NSOKButton) {
				[NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:[url host]];
				[frame loadRequest:[NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0]];
				[self webView:sender didStartProvisionalLoadForFrame:frame]; // tell the gui thats it's loading
			}
			break;
		case NSURLErrorServerCertificateUntrusted:
			// certificate error
			url = [NSURL URLWithString:[tab URLString]];
			msg = [NSAlert alertWithMessageText:@"Untrusted Server Certificate"
								  defaultButton:@"Yes"
								alternateButton:@"No"
									otherButton:nil 
					  informativeTextWithFormat:[NSString stringWithFormat:@"The certificate from this server is invalid.  Would you like to load the page anyway?", [url host]]];
			result = [msg runModal];
			if (result == NSOKButton) {
				[NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:[url host]];
				[frame loadRequest:[NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0]];
				[self webView:sender didStartProvisionalLoadForFrame:frame]; // tell the gui thats it's loading
			}
			break;
		case NSURLErrorHTTPTooManyRedirects:
			[self showErrorPageForReason:@"Too many HTTP server redirects." title:@"Error" webview:sender];
			break;
		case NSURLErrorTimedOut:
			[self showErrorPageForReason:@"The connection timed out." title:@"Error" webview:sender];
			break;
		case NSURLErrorNotConnectedToInternet:
			[self showErrorPageForReason:@"The page could not be loaded because you are not connected to the internet.  Please check your connection settings and try again." title:@"Error" webview:sender];
			break;
		case 203:
		case -999:
			// this error is called when the webview tries to load a non-displayable element
			// ignore it
			break;
		case -1003:
			// called when the server can't be found
			[self showErrorPageForReason:@"The requested server could not be found." title:@"Error" webview:sender];
			break;
		default:
		{
/*			NSLog(@"error:%i", [error code]);
			// some other error, show our fancy error page
			if ([[[error localizedDescription] capitalizedString] rangeOfString:@"Frame Load Interrupted"].location == NSNotFound) {
				[self showErrorPageForReason:[[error localizedDescription] capitalizedString] title:@"Error" webview:sender];
			}
*/
			break;
		}
	}
	if(tab)
	{
		[tab setLoading: NO];
	}
	[self syncLoadingStateWithStatus];
	spinnerEnabled	= NO;
	stopEnabled		= NO;
	reloadEnabled	= YES;
	[self updateButtons];
}

- (void)webView:(WebView *)sender didFailLoadWithError:(NSError *)error forFrame:(WebFrame *)frame {
	Tab* tab = [tabController tabWithWebView: sender];
	int code = [error code];
	
	if(tab)
	{
		[tab setStatus: @"Done"];
		[tab setLoading:NO];
	}
	if(sender == currentWebView) // if this is the visible webview
	{
		[self setStatusText:@"Done"];
		[self syncLoadingStateWithStatus];
		spinnerEnabled	= NO;
		stopEnabled		= NO;
		reloadEnabled	= YES;
		[self updateButtons];
	}
	NSURL *url;
	NSAlert *msg;
	int result;
	
	switch (code) {
		case NSURLErrorFileDoesNotExist:
		case NSURLErrorFileIsDirectory:
			[self handleFileProtocolForPath:[[self URLText] substringFromIndex:7] webview:sender];
			break;
			
		case NSURLErrorServerCertificateHasBadDate:
			// certificate error
			url = [NSURL URLWithString:[tab URLString]];
			msg = [NSAlert alertWithMessageText:@"Server Certificate Expired"
								  defaultButton:@"Yes"
								alternateButton:@"No"
									otherButton:nil 
					  informativeTextWithFormat:[NSString stringWithFormat:@"The certificate from this server has expired.  Would you like to load the page anyway?", [url host]]];
			result = [msg runModal];
			if (result == NSOKButton) {
				[NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:[url host]];
				[frame loadRequest:[NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0]];
				[self webView:sender didStartProvisionalLoadForFrame:frame]; // tell the gui thats it's loading
			}
			break;
		case NSURLErrorServerCertificateHasUnknownRoot:
			// certificate error
			url = [NSURL URLWithString:[tab URLString]];
			msg = [NSAlert alertWithMessageText:@"Untrusted Server Certificate"
								  defaultButton:@"Yes"
								alternateButton:@"No"
									otherButton:nil 
					  informativeTextWithFormat:[NSString stringWithFormat:@"The certificate from this server has been signed by an unknown authority.  Would you like to load the page anyway?", [url host]]];
			result = [msg runModal];
			if (result == NSOKButton) {
				[NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:[url host]];
				[frame loadRequest:[NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0]];
				[self webView:sender didStartProvisionalLoadForFrame:frame]; // tell the gui thats it's loading
			}
			break;
		case NSURLErrorServerCertificateUntrusted:
			// certificate error
			url = [NSURL URLWithString:[tab URLString]];
			msg = [NSAlert alertWithMessageText:@"Untrusted Server Certificate"
								  defaultButton:@"Yes"
								alternateButton:@"No"
									otherButton:nil 
					  informativeTextWithFormat:[NSString stringWithFormat:@"The certificate from this server is invalid.  Would you like to load the page anyway?", [url host]]];
			result = [msg runModal];
			if (result == NSOKButton) {
				[NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:[url host]];
				[frame loadRequest:[NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0]];
				[self webView:sender didStartProvisionalLoadForFrame:frame]; // tell the gui thats it's loading
			}
			break;
		case NSURLErrorHTTPTooManyRedirects:
			[self showErrorPageForReason:@"Too many HTTP server redirects." title:@"Error" webview:sender];
			break;
		case NSURLErrorTimedOut:
			[self showErrorPageForReason:@"The connection timed out." title:@"Error" webview:sender];
			break;
		case NSURLErrorNotConnectedToInternet:
			[self showErrorPageForReason:@"The page could not be loaded because you are not connected to the internet.  Please check your connection settings and try again." title:@"Error" webview:sender];
			break;
		case 203:
		case -999:
			// this error is called when the webview tries to load a non-displayable element
			// ignore it
			break;
		case -1003:
			// called when the server can't be found
			[self showErrorPageForReason:@"The requested server could not be found." title:@"Error" webview:sender];
			break;
		default:
			NSLog(@"error:%i", [error code]);
			// some other error, show our fancy error page
			if ([[[error localizedDescription] capitalizedString] rangeOfString:@"Frame Load Interrupted"].location == NSNotFound) {
	//			[self showErrorPageForReason:[[error localizedDescription] capitalizedString] title:@"Error" webview:sender];
			}
			break;
	}
	if(tab)
	{
		[tab setLoading: NO];
	}
	[self syncLoadingStateWithStatus];
	spinnerEnabled	= NO;
	stopEnabled		= NO;
	reloadEnabled	= YES;
	[self updateButtons];
}

- (void)webView:(WebView *)sender didCommitLoadForFrame:(WebFrame *)frame {
	Tab* tab = [tabController tabWithWebView: sender];
	
	if(tab)
	{
		if (frame == [sender mainFrame]) {
			[tab setURLString:[[[[frame dataSource] request] URL] absoluteString]];
		}
		
		[tab setStatus: @"Receiving Data..."];
	}
	if(sender == currentWebView) // if this is the visible webview
	{
		if (frame == [sender mainFrame]) {
			[self setURLText:[[[[frame dataSource] request] URL] absoluteString]];
		}
		
		[self setStatusText:@"Receiving Data..."];
		[self syncLoadingStateWithStatus];
		[self updateButtons];
	}
}

- (void)webView:(WebView *)sender serverRedirectedForDataSource:(WebFrame *)frame {
	Tab* tab = [tabController tabWithWebView: sender];
	if(tab)
	{
		[tab setStatus: @"Redirected"];
	}
	if(sender == currentWebView) // if this is the visible webview
	{
		[self setStatusText:@"Redirected"];
		[self syncLoadingStateWithStatus];
	}
}

- (void)webView:(WebView *)sender didCancelClientRedirectForFrame:(WebFrame *)frame {
	Tab* tab = [tabController tabWithWebView: sender];
	if(tab)
	{
		[tab setStatus: @"Redirect Cancelled"];
		[tab setLoading: NO];
	}
	if(sender == currentWebView) // if this is the visible webview
	{
		
		[self setStatusText:@"Redirect Cancelled"];
		[self syncLoadingStateWithStatus];
		
		spinnerEnabled	= NO;
		stopEnabled		= NO;
		reloadEnabled	= YES;
		
		[self updateButtons];
	}
}

- (void)webView:(WebView *)sender willPerformClientRedirectToURL:(NSURL *)URL delay:(NSTimeInterval)seconds fireDate:(NSDate *)date forFrame:(WebFrame *)frame {
	Tab* tab = [tabController tabWithWebView: sender];
	
	if ([URL host] != nil) {
		if(tab)
		{
			[tab setStatus: [NSString stringWithFormat:@"Performing Redirect to %@...", [URL host]]];
		}
		
		if(sender == currentWebView) // if this is the visible webview
		{
			[self setStatusText:[NSString stringWithFormat:@"Performing Redirect to %@...", [URL host]]];
			[self setURLText:[URL absoluteString]];
			[self syncLoadingStateWithStatus];
		}
	} else {
		if(tab)
		{
			[tab setStatus: @"Performing Redirect..."];
		}
		
		if(sender == currentWebView) // if this is the visible webview
		{
			[self setStatusText:@"Performing Redirect..."];
			[self setURLText:[URL absoluteString]];
			[self syncLoadingStateWithStatus];
		}
	}
}


- (WebView *)webView:(WebView *)sender createWebViewWithRequest:(NSURLRequest *)request {
	WebView			*newView = [self newWebView];
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	
	if([defaults boolForKey: kSelectNewTabs])
	{
		[tabController newTabWithWebView: newView select: YES];
	}
	else
	{
		[tabController newTabWithWebView: newView select: NO];
	}
	
	[[newView mainFrame] loadRequest:request];
	
	return newView;
}

- (void)webViewShow:(WebView *)sender {}

- (void)webView:(WebView *)sender setStatusText:(NSString *)text {
	Tab* tab = [tabController tabWithWebView: sender];
	
	if(tab)
	{
		[tab setStatus: text];
	}
	
	if(sender == currentWebView) // if this is the visible webview
	{
		[self setStatusText:text];
	}
}

- (NSString *)webViewStatusText:(WebView *)sender {
	NSString*	status	= nil;	
	Tab*		tab		= [tabController tabWithWebView: sender];
	
	if(tab)
	{
		status = [tab status];
	}
	else
	{
		status = [self statusText];
	}
	
	return status;
}

- (NSRect)webViewFrame:(WebView *)sender {
	return [[sender window] frame];
}

- (void)webView:(WebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message {
	Tab *tab = [tabController tabWithWebView:sender];
	if(sender != currentWebView) // if this is the visible webview
	{
		[tabController selectTab:tab refresh:YES];
	}
	// Create alert panel
	NSAlert *alert;
	alert = [[NSAlert alloc] init];
	[alert autorelease];
	
	[[alert window] setLevel: [WindowLevel windowLevel] + 1];
		
	// Configure alert panel
	[alert setMessageText:@"Alert"];
	[alert setInformativeText:message];
	[alert addButtonWithTitle:@"OK"];
	
	// Display alert panel
	[alert beginSheetModalForWindow:[currentWebView window] modalDelegate:self didEndSelector:NULL contextInfo:NULL];
}

- (BOOL)webView:(WebView *)sender runJavaScriptConfirmPanelWithMessage:(NSString *)message {
	Tab *tab = [tabController tabWithWebView:sender];
	if(sender != currentWebView) // if this is the visible webview
	{
		[tabController selectTab:tab refresh:YES];
	}
	// Create alert panel
	NSAlert *alert;
	alert = [[NSAlert alloc] init];
	[alert autorelease];
	
	[[alert window] setLevel: [WindowLevel windowLevel] + 1];
		
	// Configure alert panel
	[alert setMessageText:@"Confirm"];
	[alert setInformativeText:message];
	[alert addButtonWithTitle:@"Yes"];
	[alert addButtonWithTitle:@"No"];
	
	// Display alert panel
	int result;
	result = [alert runModal];
	
	// Return result
	return result == NSAlertFirstButtonReturn;
}

//- (NSWindow *)downloadWindowForAuthenticationSheet:(WebDownload *)download {}

- (void)webView:(WebView *)sender mouseDidMoveOverElement:(NSDictionary *)elementInfo modifierFlags:(unsigned int)modifierFlags
{
	if(sender == currentWebView) // if this is the visible webview
	{
		NSString *location = [[elementInfo objectForKey:WebElementLinkURLKey] absoluteString];
		if (location) {
			NSString *scheme = [[NSURL URLWithString:location] scheme];
			if ([scheme isEqualToString:@"mailto"]) {
				location = [[location componentsSeparatedByString:@"mailto:"] componentsJoinedByString:@""];
				[self setStatusText:[NSString stringWithFormat:@"Send email to %@", location]];
			} else {
				[self setStatusText:location];
			}
		} else {
			[self setStatusText:loadingState];
		}
	}
}

- (void)webView:(WebView *)sender runOpenPanelForFileButtonWithResultListener:(id <WebOpenPanelResultListener>)resultListener {
	Tab *tab = [tabController tabWithWebView:sender];
	if(sender != currentWebView) // if this is the visible webview
	{
		[tabController selectTab:tab refresh:YES];
	}
	// Create open panel
	NSOpenPanel *openPanel;
	openPanel = [NSOpenPanel openPanel];
	
	[openPanel setLevel: [WindowLevel windowLevel] + 1];
		
	// Display open panel
	int result;
	result = [openPanel runModal];
	
	// Return result
	if (result == NSOKButton) {
		[resultListener chooseFilename:[openPanel filename]];
	}
	else {
		[resultListener cancel];
	}
}

- (void)webViewClose:(WebView *)sender {
	if ([tabController tabCount] > 1) { // only close if there is more than one tab open
		Tab *t = [tabController tabWithWebView:sender];
		[tabController removeTab:t redraw:YES resize:YES];
	}
}

- (void)webView:(WebView *)sender setFrame:(NSRect)frame {}		// dont let the window change size or position
//- (void)webViewUnfocus:(WebView *)sender {}
//- (void)webViewFocus:(WebView*)sender {}

- (NSResponder *)webViewFirstResponder:(WebView *)sender
{
    return [[sender window] firstResponder];
}

- (void)webView:(WebView *)sender makeFirstResponder:(NSResponder*)responder
{
    [[sender window] makeFirstResponder:responder];
}

- (NSArray *)webView:(WebView *)sender contextMenuItemsForElement:(NSDictionary *)element defaultMenuItems:(NSArray *)defaultMenuItems {
	NSMutableArray *items = [[NSMutableArray alloc] initWithArray:defaultMenuItems copyItems:YES];
	BOOL link = NO;
	BOOL frame = NO;
	BOOL image = NO;
	
	if ([element objectForKey:WebElementLinkURLKey]) { // item was a link
		link = YES;
	}
	if ([element objectForKey:WebElementFrameKey]) { // item was a web frame
		frame = YES;
	}
	if ([element objectForKey:WebElementImageKey]) { // item was an image
		image = YES;
	}
	
	if (link) {
		NSMenuItem *newWin = (NSMenuItem *)[items objectAtIndex:0];
		[newWin setTitle:@"Open Link in New Tab"];
		
		NSMenuItem *book = [[NSMenuItem alloc] initWithTitle:@"Bookmark Link"
													  action:@selector(menuHandlerBookmarkLink)
											   keyEquivalent:@""];
		
		urlTemp = [element objectForKey:WebElementLinkURLKey];
		strTemp = [element objectForKey:WebElementLinkLabelKey];
		
		[book setTarget:self];
		[items insertObject:book atIndex:1];
		if (!image && !frame) {
			[items insertObject:[NSMenuItem separatorItem] atIndex:4];
		}
		[book release];
		
		//if (!image && !frame) {
		//			[items removeLastObject];
		//		}
	}
	if (image) {
		NSMenuItem *item = (NSMenuItem *)[items objectAtIndex:0];
		if ([[item title] isEqualToString:@"Open Link in New Tab"]) {
			item = (NSMenuItem *)[items objectAtIndex:4];
		}
		[item setTitle:@"Open Image in New Tab"];
		
		if (link) {
			NSMenuItem *item2 = (NSMenuItem *)[items objectAtIndex:5];
			if ([[item2 title] isEqualToString:@"Open Image in New Window"]) {
				[item2 setTitle:@"Open Image in New Tab"];
			}
		}
		
		urlTemp = [element objectForKey:WebElementImageURLKey];
		
		NSMenuItem *copyLoc = [[NSMenuItem alloc] initWithTitle:@"Copy Image Location"
														 action:@selector(menuHandlerCopyImageLocation)
												  keyEquivalent:@""];
		[items addObject:copyLoc];
		
		[copyLoc release];
	}
	if (frame) {
		NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@"View Page Source" action:@selector(viewPageSource) keyEquivalent:@""];
		[menuItem setTarget:self];
		if (!link && !image) {
			[items addObject:[NSMenuItem separatorItem]];
			[items addObject:menuItem];
		} else {
			//[items removeLastObject];
		}
		[menuItem release];
	}
	
	return items;
}

- (void)downloadDidBegin:(NSURLDownload *)download {
	NSURLRequest *req = [download request];
	[download cancel];
	[downloadController prepareForDownloadWithRequest:req];
	[self showDownloadWindow:self];
}

- (IBAction)reloadAllTabs:(id)sender {
	[tabController reloadAllTabs];
}

- (IBAction)clearCache:(id)sender {
	[[NSURLCache sharedURLCache] removeAllCachedResponses];
}

- (void)menuHandlerBookmarkLink {
	[self showBookmarkWindow: nil];
	[bookmarkController newBookmarkWithURL: urlTemp title: strTemp window: [bookmarkWindowController window]];
}

- (void)menuHandlerCopyImageLocation {
	NSPasteboard *pb = [NSPasteboard generalPasteboard];
	[pb declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:self];
	[pb setString:[urlTemp absoluteString] forType:NSStringPboardType];
}

@end