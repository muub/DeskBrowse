/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

/* DeskBrowseController */

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import <IOKit/IOKitLib.h>

#import "DeskBrowseConstants.h"
#import "ThreadWorker.h"

@class DBApplication;
@class DeskBrowseConstants;

@class ActionMenuView;
@class ActionMenuWindow;
@class Authorizer;
@class BookmarkBar;
@class BookmarkController;
@class BookmarkImportWindowController;
@class BookmarkWindowController;
@class DownloadController;
@class HistoryController;
@class HistoryWindowController;
@class HotKeyController;
@class LocationTextField;
@class NSFileManagerSGSAdditions;
@class NSWindowFade;
@class PlistUtils;
@class PreferenceController;
@class QuickDownload;
@class SearchEngineController;
@class SlideWindow;
@class TabController;
@class Tab;
@class TabBar;
@class URLFormatter;
@class ViewSourceWindowController;
@class WebKitEx;
@class WebsposeWindow;
@class WindowLevel;
@class StatusItemController;
@class SymbolicHotKeyController;

@interface DeskBrowseController : NSObject
{
	// main browser components
    IBOutlet SlideWindow			*slideWindow; // the main window
	IBOutlet NSBox*					webViewBox;
	IBOutlet NSBox*					tabBarBox;
	IBOutlet NSButton				*back; // back button
	IBOutlet NSButton				*forward; // forward button
	IBOutlet NSButton				*stop; // stop button
	IBOutlet NSButton				*reload; // reload button
	IBOutlet NSButton				*home; // home button
	IBOutlet NSTextField			*statusField; // where the status text is shown
	IBOutlet LocationTextField		*urlField; // the location text field
	IBOutlet NSSearchField			*searchField; // the google search field
	IBOutlet NSTextField			*titleField; // where the title of the page is displayed
	IBOutlet NSProgressIndicator	*spinner; // the little spinner next to the search field
	IBOutlet NSTabView				*tabView; // the tab view
	IBOutlet NSImageView			*rightbar; // the right edge image view
	IBOutlet NSImageView			*filler;
	IBOutlet BookmarkBar*			bookmarkBar;
	IBOutlet TabBar*				tabBar;
	IBOutlet NSMenuItem*			backMenuItem;
	IBOutlet NSMenuItem*			forwardMenuItem;
	IBOutlet NSMenuItem*			stopMenuItem;
	IBOutlet NSMenuItem*			registrationMenuItem;
	IBOutlet NSMenuItem*			reloadMenuItem;
	IBOutlet NSWindow *				quickDownloadWindow;
	IBOutlet NSMenuItem*			regItem;
	
	// class variables/objects
	NSString						*loadingState; // used to keep track of the loading status string
	NSString						*homePage; // the home page
	BOOL							windowIsVisible; // used to keep track of whether the window is already slide out or not
	//float							padding; // added to the zero cord to position the window (TEMORARY)
	
	BOOL spinnerEnabled;
	BOOL stopEnabled;
	BOOL reloadEnabled;
	
	HistoryController*			historyController;
	BookmarkController*			bookmarkController;
	DownloadController*			downloadController;
	PreferenceController*		prefController;
	
	HistoryWindowController*		historyWindowController;
	BookmarkImportWindowController*	bookmarkImportWindowController;
	BookmarkWindowController*		bookmarkWindowController;
	ViewSourceWindowController*		sourceWindowController;
	
	StatusItemController		*statusController;
	
	SymbolicHotKeyController    *symbolicHotKeyController;
	
	TabController				*tabController;
		
	WebView*					currentWebView;
	NSString*					currentStatus;
	NSString*					currentTitle;
	Authorizer*					auth;
	
	ActionMenuWindow			*actionMenuWindow;
	ActionMenuView				*actionMenu;
	BOOL						actionMenuVisible;
	IBOutlet NSButton *			actionMenuButton;
	
	//BOOL						registrationModalRunning;
			
	// Websposé stuff
	BOOL						inWebsposeMode;
	
	// Websposé outlets
	IBOutlet WebsposeWindow*		websposeWindow;
	IBOutlet NSBox*					websposeWebViewBox;
	IBOutlet NSBox*					websposeTabBarBox;
	IBOutlet NSButton*				websposeBack;
	IBOutlet NSButton*				websposeForward;
	IBOutlet NSButton*				websposeStop;
	IBOutlet NSButton*				websposeReload;
	IBOutlet NSPanel*				websposePasswordWindow;
	IBOutlet NSProgressIndicator*	websposeSpinner;
	IBOutlet NSSearchField*			websposeSearchField;
	IBOutlet NSTextField*			websposeStatusField;
	IBOutlet NSTextField*			websposeTitleField;
	IBOutlet LocationTextField*		websposeURLField;
	IBOutlet NSTextField*			websposePasswordField;
	IBOutlet NSTextField*			websposePasswordStatus;
	IBOutlet NSButton*				webpsoseActionMenuButton;
	IBOutlet BookmarkBar*			websposeBookmarkBar;
}

- (IBAction) websposeEnterPassword: (id) sender;
- (IBAction) websposeCancelPassword: (id) sender;
- (IBAction)loadURL:(id)sender; // called when enter is pushed inside the url field
- (IBAction)googleSearch:(id)sender; // called when enter is pushed inside the search field
- (IBAction)back:(id)sender;
- (IBAction)forward:(id)sender;
- (IBAction)reload:(id)sender;
- (IBAction)goHome:(id)sender; // called by the home button
- (IBAction)showDownloadWindow:(id)sender; // shows the download window
- (IBAction) showPrefWindow: (id) sender; // shows the preference window
- (IBAction) showSourceWindow: (id) sender; // shows the source window
- (IBAction) showHistoryWindow: (id) sender;
- (IBAction) showBookmarkImportWindow: (id) sender;
- (IBAction) showBookmarkWindow: (id) sender;
- (IBAction) addBookmark: (id) sender;
- (IBAction)toggleActionMenu:(id)sender;
- (IBAction)toggleBookmarkBar:(id)sender;
- (IBAction)stopLoading:(id)sender;
- (IBAction) selectTabRight: (id) sender;
- (IBAction) selectTabLeft: (id) sender;
- (IBAction) closeAllTabs: (id) sender;
- (IBAction)close:(id)sender;
- (IBAction)newBlankTab:(id)sender;
- (IBAction)makeTextLarger:(id)sender;
- (IBAction)makeTextSmaller:(id)sender;
- (IBAction)saveCurrentPage:(id)sender;
- (IBAction)openLocation:(id)sender;
- (IBAction)showQDownloadWindow:(id)sender;
- (IBAction)showDocumentation:(id)sender;

- (void) setupTabView;
- (NSWindow*) currentWindow;
- (void)handleNotification:(NSNotification *)note;
- (void) toggleWebspose;
- (void) lock: (BOOL) shouldLock;
- (void) loadURLNotification: (NSNotification*) notification;
- (void) loadURLString: (NSString*) URLString;
- (void) slideWindowResized: (NSNotification*) notification;
- (void) syncVariablesWithUserPrefs;
- (void)setStatusText:(NSString *)status; // used to set the current status text of the page
- (NSString *)statusText; // returns the current status text of the page
- (void)setTitleText:(NSString *)title; // used to set the current status text of the page
- (NSString *)titleText; // returns the current title text of the page
- (LocationTextField*) URLField;
- (void)setURLText:(NSString *)URL; // used to set the current URL text of the page
- (NSString *)URLText; // returns the current URL text of the page
- (NSString*) searchFieldText;
- (void) setFavicon: (NSImage*) favicon;
- (void)syncLoadingStateWithStatus; // used to set the loading to the status bar text
- (void)slideInForcingToFront: (BOOL) forceToFront; // slides the window in
- (void)slideOut; // slides the window out
- (void)toggleSlideBrowse; // called when the hotkey is pushed
- (void)filterErrorMessage:(NSString *)msg forWebView: (WebView*) webView;
- (BOOL)handleFileProtocolForPath:(NSString *)path webview:(WebView *)wv;
- (void)viewPageSource;
- (void) updateButtons;
- (WebView*) newWebView;
- (void) tabChanged: (NSNotification*) notification;
- (BOOL)actionMenuVisible;
- (BOOL)inWebspose;
- (void)windowDidResignKey:(NSNotification *)aNotification;
- (void) handleNewTabRequest:(NSNotification *)notification;
- (void) mouseDown: (NSEvent*) theEvent;
- (void) keyCombinationPressed: (KeyCombination) keys;
- (void) showErrorPageForReason:(NSString *)reason title:(NSString *)title webview:(WebView *)wv;
- (IBAction)reloadAllTabs:(id)sender;
- (IBAction)clearCache:(id)sender;
//- (void) registrationStatusChanged;

//- (IBAction) showRegistrationWindow: (id) sender;

@end
