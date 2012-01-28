/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import "TabController.h"

#import "Tab.h"
#import "TabBar.h"


@implementation TabController


- (id) initWithTabBar: (TabBar*) bar tabView: (NSTabView*) view
{
	if (self = [super init])
	{
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(tabClicked:) name: @"DBTabClicked" object: nil];
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(tabWantsToClosed:) name:@"DBTabWantsToBeClosed" object: nil];
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(slideWindowResized:) name:@"DBSlideWindowResized" object: nil];
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(removeAllTabs) name:@"DBCloseAllTabs" object: nil];
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reloadTab) name:@"DBReloadTab" object: nil];
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reloadAllTabs) name:@"DBReloadAllTabs" object: nil];
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(frameDidChange) name: NSViewFrameDidChangeNotification object: bar];
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(frameDidChange) name: NSViewBoundsDidChangeNotification object: bar];
														   
		tabs		= [[NSMutableArray alloc] init];
		tabView		= [view retain];
		tabBar		= [bar retain];
		tabWidth	= 120.0;
		
		// create new tab ** Do not call newTabWithWebView: here **
		Tab* newTab	= [[Tab alloc] initWithFrame: NSMakeRect(0, 0, tabWidth, 29)];
		
		[tabs	addObject:	newTab];
		[tabBar addSubview: newTab];
		
		[self	selectTab: newTab refresh: NO];
		[self	updateTabSize];
		[tabBar setNeedsDisplay: YES];
		
		[newTab	release];
	}
	
	return self;
}

- (WebView*)defaultWebView {
	return defaultWebView;
}

- (void)setDefaultWebView:(WebView *)aWebView {
	[defaultWebView release];
	defaultWebView = [aWebView retain];
}

- (TabBar *)tabBar {
	return tabBar;
}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[tabs		release];
	[tabView	release];
	[tabBar		release];
	[defaultWebView release];
	
	[super dealloc];
}

- (void) tabClicked: (NSNotification*) notification
{
	NSDictionary*	userInfo;
	Tab*			clickedTab;
	
	userInfo = [notification userInfo];
	
	if (userInfo != nil)
	{
		clickedTab = [userInfo objectForKey: @"clickedTab"];
		[self selectTab: clickedTab refresh: YES];
	}
}

- (void) tabWantsToClosed:(NSNotification *)notification {
	Tab *tTab = (Tab *)[[notification userInfo] objectForKey:@"sender"];
	if ([tabs count] > 1) {
		[self removeTab: tTab redraw: YES resize: YES];
	}
}

- (void) slideWindowResized: (NSNotification*) notification
{
	[self updateTabSize];
	[tabBar setNeedsDisplay: YES];
}

- (void) newTabWithWebView: (WebView*) webView select: (BOOL) selectNewTab
{
	if ([self canFitMoreTabs])
	{
		Tab*			newTab;
		NSTabViewItem*	newTabViewItem;

		newTab			= [[Tab alloc] initWithFrame: NSMakeRect(0, 0, 0, 0)];
		newTabViewItem	= [[NSTabViewItem alloc] init];

		[newTabViewItem	setView: webView];
		[tabView addTabViewItem: newTabViewItem];

		[tabs	addObject:	newTab];
		[tabBar addSubview: newTab];
		
		if (selectNewTab)
		{
			[self selectTab: newTab refresh: NO];
		}
		
		[self	updateTabSize];
		[tabBar setNeedsDisplay: YES];

		[newTab			release];
		[newTabViewItem release];
	}
	else
	{
		NSLog(@"Can't fit anymore tabs");
		NSBeep();
	}
}

- (void) newTabWithWebView: (WebView*) webView select: (BOOL) selectNewTab URLString:(NSString *)URLString {
	[self newTabWithWebView:webView select:selectNewTab];
	[(Tab *)[tabs objectAtIndex:([tabs count] - 1)] setURLString:URLString];
}

- (void) removeTab: (Tab*) tab redraw: (BOOL) redraw resize: (BOOL) resize
{
	// Eventually need to disable "Close" menu item when there is only one tab
	if ([tabs count] > 1)
	{
		Tab *currentTab;
		Tab *newTab;
		int i;
		int indexOfTab			= [tabs indexOfObject: tab];
		int selectedTab			= [tabs indexOfObject: [self selectedTab]];
		int	indexOfTabToSelect	= selectedTab;
		
		if (indexOfTab != NSNotFound)
		{
			if (indexOfTab == selectedTab)
			{
				if (indexOfTab == ([tabs count] - 1)) // Last tab
				{
					indexOfTabToSelect = indexOfTab - 1;
				}
			}
			else
			{
				if (indexOfTab < selectedTab)
				{
					indexOfTabToSelect = selectedTab - 1;
				}
			}
						
			[tab		removeFromSuperview];
			[tabs		removeObjectAtIndex: indexOfTab]; // faster to removeObjectAtIndex: than removeObject:
			[[[tabView	tabViewItemAtIndex: indexOfTab] view] stopLoading: self];
			[tabView	removeTabViewItem: [tabView tabViewItemAtIndex: indexOfTab]];
			[tabView	selectTabViewItemAtIndex: indexOfTabToSelect];
			[self		selectTab: [tabs objectAtIndex: indexOfTabToSelect] refresh: NO];
			
			if (resize)
			{
				[self updateTabSize];
			}
			
			if (redraw)
			{
				[tabBar setNeedsDisplay: YES];
			}
		}
	}
}

- (void) removeAllTabs
{
	Tab*			selectedTab		= [self selectedTab];
	Tab*			currentTab		= nil;
	NSMutableArray*	tabsToRemove	= [[NSMutableArray alloc] init];
	
	int i;
	for(i = 0; i < [tabs count]; i++)
	{
		currentTab = [tabs objectAtIndex: i];
		if (currentTab != selectedTab)
		{
			[tabsToRemove addObject: currentTab];
		}
	}
	
	for(i = 0; i < [tabsToRemove count]; i++)
	{
		currentTab = [tabsToRemove objectAtIndex: i];
		[self removeTab: currentTab redraw: NO resize: NO];
	}
	
	[tabsToRemove release];
	[self updateTabSize];
	[tabBar setNeedsDisplay: YES];
}

- (void) updateTabSize
{
	float tabWidthToFit = [tabBar frame].size.width / [tabs count];
		
	if (tabWidth >= tabWidthToFit)
	{
		tabWidth = tabWidthToFit;
	}
	else
	{
		if (tabWidthToFit <= 120.0)
		{
			tabWidth = tabWidthToFit;
		}
		else
		{
			if (tabWidth < 120.0)
			{
				tabWidth = 120.0;
			}
		}
	}
			
	Tab*	currentTab;
	NSPoint	newOrigin;
	NSSize	newSize;
	
	newSize	= NSMakeSize(tabWidth, 29);
	
	int i;
	for(i = 0; i < [tabs count]; i++)
	{
		currentTab	= [tabs objectAtIndex: i];
		newOrigin	= NSMakePoint((i * (tabWidth )), 0);
		
		[currentTab setFrame: NSMakeRect(newOrigin.x, newOrigin.y, newSize.width, newSize.height)];
	}
	
	[tabBar setNeedsDisplay: YES];
}

- (BOOL) canFitMoreTabs
{
	BOOL	canFit			= YES;
	float	tabWidthToFit	= [tabBar frame].size.width / [tabs count];
	
	if (tabWidthToFit < 50.0)
	{
		canFit = NO;
	}
	else
	{
		canFit = YES;
	}
	
	return canFit;
}

- (void)selectTab:(Tab *)aTab refresh: (BOOL) refresh {
	Tab*			currentTab = nil;
	
	int i;
	for(i = 0; i < [tabs count]; i++)
	{
		currentTab = [tabs objectAtIndex: i];
				
		if (currentTab != nil)
		{
			if (currentTab == aTab)
			{
				[currentTab setSelected: YES];
				[tabView selectTabViewItemAtIndex: i];
				[[[tabView tabViewItemAtIndex: i] view] setNeedsDisplay: YES];
				
				// Send notification
				NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
				[dic setObject: [[tabView tabViewItemAtIndex: i] view] forKey:@"WebView"];
				[dic setObject: [tabs objectAtIndex: i] forKey:@"Tab"];
				[[NSNotificationCenter defaultCenter] postNotificationName:@"DBTabSelected"
																	object:nil
																  userInfo:dic];
				[dic release];
			}
			else
			{
				[currentTab setSelected: NO];
			}
		}		
	}
	
	if (refresh)
	{
		[tabBar setNeedsDisplay: YES];
	}
}

- (void) selectTabRight
{
	int		indexOfTabToSelect;
	Tab*	tabToSelect			= nil;
	Tab*	selectedTab			= [self selectedTab];
	int		indexOfSelectedTab	= [tabs indexOfObject: selectedTab];
	int		tabCount			= [tabs count];
	
	if (tabCount > 1)
	{
		if (indexOfSelectedTab != NSNotFound)
		{
			if (indexOfSelectedTab < tabCount - 1)
			{
				indexOfTabToSelect = indexOfSelectedTab + 1;
			}
			else
			{
				indexOfTabToSelect = 0;
			}
			
			tabToSelect = [tabs objectAtIndex: indexOfTabToSelect];
			
			if (tabToSelect)
			{
				[self selectTab: tabToSelect refresh: YES];
			}
		}
	}
}

- (void) selectTabLeft
{
	int		indexOfTabToSelect;
	Tab*	tabToSelect			= nil;
	Tab*	selectedTab			= [self selectedTab];
	int		indexOfSelectedTab	= [tabs indexOfObject: selectedTab];
	int		tabCount			= [tabs count];
	
	if (tabCount > 1)
	{
		if (indexOfSelectedTab != NSNotFound)
		{
			if (indexOfSelectedTab > 0)
			{
				indexOfTabToSelect = indexOfSelectedTab - 1;
			}
			else
			{
				indexOfTabToSelect = tabCount - 1;
			}
			
			tabToSelect = [tabs objectAtIndex: indexOfTabToSelect];
			
			if (tabToSelect)
			{
				[self selectTab: tabToSelect refresh: YES];
			}
		}
	}
}

- (Tab *)selectedTab {
	Tab		*currentTab = nil;
	Tab		*returnTab	= nil;
	int i;
	for(i = 0; i < [tabs count]; i++) {
		currentTab = [tabs objectAtIndex: i];
		
		if (currentTab != nil) {
			if ([currentTab selected]) {
				returnTab = currentTab;
				break;
			}
		}
	}
	return returnTab;
}

- (Tab*) tabWithWebView: (WebView*) webView
{
	Tab*	tabWithWebView	= nil;
	Tab*	currentTab		= nil;
	
	int i;
	for(i = 0; i < [tabs count]; i++)
	{
		currentTab = [tabs objectAtIndex: i];
		
		if (webView == [[tabView tabViewItemAtIndex: i] view])
		{
			tabWithWebView = [tabs objectAtIndex: i];
			break;
		}
	}
	
	return tabWithWebView;
}

- (int)tabCount {
	return [tabs count];
}

- (void)reloadTab {
	Tab *sel = [self selectedTab];
	int i;
	int index = -1;
	for (i=0; i<[tabs count]; i++) {
		if (sel == [tabs objectAtIndex:i]) {
			index = i;
			break;
		}
	}
	
	if (index != -1) {
		WebView *wv = [[tabView tabViewItemAtIndex:index] view];
		[wv reload:self];
	}
}

- (void)reloadAllTabs {
	int i;
	WebView *wv;
	for (i=0; i<[tabs count]; i++) {
		wv = [[tabView tabViewItemAtIndex:i] view];
		[wv reload:self];
	}
}

- (void) frameDidChange
{
	[self updateTabSize];
	
	NSEnumerator*	tabEnumerator	= [tabs objectEnumerator];
	Tab*			currentTab		= nil;
	
	while ((currentTab = [tabEnumerator nextObject]) != nil)
	{
		[currentTab resetTrackingRect];
	}
}

@end
