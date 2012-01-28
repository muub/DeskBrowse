/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@class TabBar;
@class Tab;


@interface TabController : NSObject
{
	NSMutableArray*	tabs;
	NSTabView*		tabView;
	TabBar*			tabBar;
	WebView*		defaultWebView;
	
	float			tabWidth;
}

- (id) initWithTabBar: (TabBar*) bar tabView: (NSTabView*) view;
- (void) tabClicked: (NSNotification*) notification;
- (void) tabWantsToClosed:(NSNotification *)notification;
- (void) slideWindowResized: (NSNotification*) notification;
- (void) newTabWithWebView: (WebView*) webView select: (BOOL) selectNewTab;
- (void) newTabWithWebView: (WebView*) webView select: (BOOL) selectNewTab URLString:(NSString *)URLString;
- (void) removeTab: (Tab*) tab redraw: (BOOL) redraw resize: (BOOL) resize;
- (void) removeAllTabs;
- (void) updateTabSize;
- (BOOL) canFitMoreTabs;

- (void) selectTab:(Tab *)aTab refresh: (BOOL) refresh;
- (void) selectTabRight;
- (void) selectTabLeft;
- (Tab *)selectedTab;

- (Tab*) tabWithWebView: (WebView*) webView;

- (WebView *)defaultWebView;
- (void)setDefaultWebView:(WebView *)aWebView;
- (TabBar *)tabBar;

- (int)tabCount;

- (void)reloadTab;
- (void)reloadAllTabs;

- (void) frameDidChange;

@end
