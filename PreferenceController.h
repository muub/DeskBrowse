/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

#import "DBApplication.h"
#import "DeskBrowseConstants.h"
#import "PlistUtils.h"


@interface PreferenceController : NSWindowController
{
	IBOutlet id				showMenuBarAndDock;
	IBOutlet id				showMenuExtra;
	IBOutlet id				selectNewTabs;
	IBOutlet id				checkForUpdates;
	IBOutlet id				checkForUpdatesIndicator;
	IBOutlet id				homePage;
	IBOutlet id				loadHomePageOnLaunch;
	IBOutlet id				browserMode;
	IBOutlet id				allowJavaScript;
	IBOutlet id				allowJava;
	IBOutlet id				allowImages;
	IBOutlet id				allowAnimatedImages;
	IBOutlet id				allowPluginMedia;
	IBOutlet id				blockPopupWindows;
	IBOutlet id				blockWebAds;
	
	IBOutlet id				sbHotKeyField;
	IBOutlet id				wbHotKeyField;
	
	IBOutlet id				changePasswordWindow;
	IBOutlet id				changePasswordOld;
	IBOutlet id				changePasswordNew;
	IBOutlet id				changePasswordVerify;
	IBOutlet id				changePasswordStatus;
	
	IBOutlet NSTextField	*downloadPathField;
	
	NSToolbar				*toolbar;
	IBOutlet NSTabView		*tabView;
	
	NSSize					sizeOfGeneralPane;
	NSSize					sizeOfWebPane;
	NSSize					sizeOfWebsposePane;
}

- (IBAction) closeWindow: (id) sender;
- (IBAction) savePreferences: (id) sender;
- (IBAction) resetPreferences: (id) sender;
- (IBAction) checkForUpdates: (id) sender;

- (IBAction) changeSBHotKey: (id) sender;
- (IBAction) changeWBHotKey: (id) sender;

- (IBAction) changePassword: (id) sender;
- (IBAction) savePassword: (id) sender;
- (IBAction) cancelPassword: (id) sender;

- (IBAction) changeDownloadLocation: (id) sender;

- (void) setLevel: (int) newLevel;
- (void) syncViewWithUserPrefs;

- (void)showGeneralPane;
- (void)showWebPane;
- (void)showWebsposePane;

@end
