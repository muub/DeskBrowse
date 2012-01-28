/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import "Bookmark.h"

#import "NSBezierPathRoundRects.h"
#import "NSStringAdditions.h"
#import "BookmarkActionCell.h"
#import "BookmarkMenuCell.h"


NSString*	kDBLoadURLNotification			= @"DBLoadURLNotification";
NSString*	kDBDeleteBookmarkNotification	= @"DBDeleteBookmarkNotification";

NSString*	kBookmarkInfoURLStringKey		= @"URLString";
NSString*	kBookmarkInfoTitleKey			= @"TitleString";
NSString*	kBookmarkInfoMoreBookmarksKey	= @"Bookmarks";


@implementation Bookmark


- (id) initWithDictionary: (NSDictionary*) dictionary
{
	NSArray* subBookmarks = [dictionary objectForKey: kBookmarkInfoMoreBookmarksKey];
	
	if (subBookmarks != nil)
	{
		[self release];
		
		self = [[BookmarkFolder alloc] initWithDictionary: dictionary];
	}
	else
	{
		NSString*	urlString	= [dictionary objectForKey: kBookmarkInfoURLStringKey];
		NSURL*		url			= nil;
		NSString*	title		= [dictionary objectForKey: kBookmarkInfoTitleKey];
		
		if (urlString != nil)
		{
			url = [NSURL URLWithString: urlString];
		}
		
		self = [self initWithURL: url title: title];
	}
	
	return self;
}

- (id) initWithURL: (NSURL*) URL title: (NSString*) title
{
	NSRect newFrame = NSMakeRect(0, 0, 100, 15);
	
	if (self = [super initWithFrame: newFrame])
	{
		mURL	= [URL retain];
		mTitle	= [title retain];
	}
	
	return self;
}

- (void) dealloc
{
	[mURL release];
	[mTitle release];
	
	[super dealloc];
}

#pragma mark -

- (id) copyWithZone: (NSZone*) zone
{
	Bookmark* copyOfSelf = [[Bookmark alloc] init];
	NSLog(@"Copy!!!");
	[copyOfSelf setURL: mURL];
	[copyOfSelf setTitle: mTitle];
	
	return copyOfSelf;
}

#pragma mark -

- (void) load
{
	if (mURL != nil)
	{
		NSDictionary* userInfo = [NSDictionary dictionaryWithObject: [mURL absoluteString] forKey: kBookmarkInfoURLStringKey];
		
		[[NSNotificationCenter defaultCenter] postNotificationName: kDBLoadURLNotification object: self userInfo: userInfo];
	}
}

- (void) remove
{
	[[NSNotificationCenter defaultCenter] postNotificationName: kDBDeleteBookmarkNotification object: self userInfo: nil];
}

#pragma mark -

- (NSMutableDictionary*) dictionary
{
	NSMutableDictionary* dictionary = nil;
	
	if (mTitle != nil)
	{
		dictionary = [NSMutableDictionary dictionary];
		
		[dictionary setObject: mTitle forKey: kBookmarkInfoTitleKey];
		
		if (mURL != nil)
		{
			[dictionary setObject: [mURL absoluteString] forKey: kBookmarkInfoURLStringKey];
		}
	}
	
	return dictionary;
}

- (NSURL*) URL
{
	return mURL;
}

- (void) setURL: (NSURL*) url
{
	if (url != mURL)
	{
		[url retain];
		[mURL release];
		
		mURL = url;
	}
}

- (NSString*) URLString
{
	return [mURL absoluteString];
}

- (void) setURLString: (NSString*) urlString
{
	[mURL release];
	mURL = [[NSURL URLWithString: urlString] retain];
}

- (NSString*) title
{
	return mTitle;
}

- (void) setTitle: (NSString*) title
{
	if (title != mTitle)
	{
		[mTitle release];
		mTitle = [title copy];
		
		[mBookmarkBarCell setStringValue: mTitle];
	}
}


// -----------------------------
//
//	Bookmark Bar related
//
// -----------------------------

#pragma mark -
#pragma mark Bookmark Bar

- (id <BookmarkBarCell>) cell
{
	if (mBookmarkBarCell == nil)
	{
		mBookmarkBarCell = [[BookmarkActionCell alloc] initWithTarget: self action: @selector(load)];
		
		[mBookmarkBarCell setStringValue: mTitle];
	}
	
	return mBookmarkBarCell;
}


#pragma mark -


- (void) setUpMenu
{
	NSMenu*		bookmarkMenu	= [[NSMenu alloc] initWithTitle: @"Bookmark"];
	NSMenuItem*	loadMenuItem	= [[NSMenuItem alloc] initWithTitle: @"Load" action: @selector(load) keyEquivalent: @""];
	NSMenuItem*	deleteMenuItem	= [[NSMenuItem alloc] initWithTitle: @"Delete" action: @selector(remove) keyEquivalent: @""];
	
	[bookmarkMenu	addItem: loadMenuItem];
	[bookmarkMenu	addItem: deleteMenuItem];
	
	[self setMenu: bookmarkMenu];
	
	[bookmarkMenu release];
	[loadMenuItem release];
	[deleteMenuItem release];
}


#pragma mark -
#pragma mark Sorting

- (NSComparisonResult) compare: (Bookmark*) otherBookmark
{
	NSComparisonResult result = NSOrderedSame;
	
	if (otherBookmark != nil)
	{
		NSString*	stringToCompare1	= mTitle;
		NSString*	stringToCompare2	= [otherBookmark title];
		
		if (stringToCompare1 == nil)
		{
			stringToCompare1 = [mURL absoluteString];
		}
		
		if (stringToCompare2 == nil)
		{
			stringToCompare2 = [[otherBookmark URL] absoluteString];
		}
		
		result = [stringToCompare1 caseInsensitiveCompare: stringToCompare2];
	}
	
	return result;
}


@end


#pragma mark -

@implementation BookmarkFolder


- (id) initWithDictionary: (NSDictionary*) dictionary
{
	NSString* title = [dictionary objectForKey: kBookmarkInfoTitleKey];
	
	if (self = [super initWithURL: nil title: title])
	{
		NSArray*		subBookmarks		= [dictionary objectForKey: kBookmarkInfoMoreBookmarksKey];
		NSEnumerator*	bookmarkEnumerator	= [subBookmarks objectEnumerator];
		NSDictionary*	currentInfoDict		= nil;
		
		while ((currentInfoDict = [bookmarkEnumerator nextObject]) != nil)
		{
			Bookmark* newBookmark = [[Bookmark alloc] initWithDictionary: currentInfoDict];
			
			[self addBookmark: newBookmark];
			
			[newBookmark release];
		}
	}
	
	return self;
}

- (void) dealloc
{
	[mContainedBookmarks release];
	
	[super dealloc];
}


#pragma mark -

- (id) copyWithZone: (NSZone*) zone
{
	BookmarkFolder* copyOfSelf = [[BookmarkFolder alloc] init];
	NSLog(@"Folder copy: %@ %@", self, mTitle);
	[copyOfSelf setURL: mURL];
	[copyOfSelf setTitle: mTitle];
	[copyOfSelf setSubBookmarks: mContainedBookmarks];
	
	return copyOfSelf;
}


#pragma mark -

- (NSMutableDictionary*) dictionary
{
	NSMutableDictionary*	dictionary		= [super dictionary];
	NSMutableArray*			subBookmarks	= nil;
	
	if (dictionary != nil && mContainedBookmarks != nil)
	{
		subBookmarks						= [NSMutableArray array];
		NSEnumerator*	bookmarkEnumerator	= [mContainedBookmarks objectEnumerator];
		Bookmark*		currentBookmark		= nil;
		
		while ((currentBookmark = [bookmarkEnumerator nextObject]) != nil)
		{
			NSDictionary* bookmarkDictionaryInfo = [currentBookmark dictionary];
			
			if (bookmarkDictionaryInfo != nil)
			{
				[subBookmarks addObject: bookmarkDictionaryInfo];
			}
		}
		
		if (subBookmarks != nil && [subBookmarks count] > 0)
		{
			[dictionary setObject: subBookmarks forKey: kBookmarkInfoMoreBookmarksKey];
		}
	}
	
	return dictionary;
}


#pragma mark -

- (unsigned) numberOfBookmarks
{
	return [mContainedBookmarks count];
}


#pragma mark -

- (NSArray*) subBookmarks
{
	return mContainedBookmarks;
}

- (void) setSubBookmarks: (NSArray*) bookmarks
{
	if (bookmarks != mContainedBookmarks)
	{
		[mContainedBookmarks release];
		
		mContainedBookmarks = [bookmarks mutableCopy];
	}
}


#pragma mark -

- (void) addBookmark: (Bookmark*) bookmark
{
	if (mContainedBookmarks == nil)
	{
		mContainedBookmarks = [[NSMutableArray alloc] init];
	}
	
	if (bookmark != nil)
	{
		[mContainedBookmarks addObject: bookmark];
		[self reloadCellMenu];
	}
}

- (void) removeBookmark: (Bookmark*) bookmark
{
	if (bookmark != nil && mContainedBookmarks != nil)
	{
		[mContainedBookmarks removeObject: bookmark];
		[self reloadCellMenu];
	}
}

#pragma mark -


- (id <BookmarkBarCell>) cell
{
	if (mBookmarkBarCell == nil)
	{
		if ([mContainedBookmarks count] > 0)
		{
			mBookmarkBarCell = [[BookmarkMenuCell alloc] init];
			
			[self reloadCellMenu];
			
			[mBookmarkBarCell setStringValue: mTitle];
		}
	}
	
	return mBookmarkBarCell;
}

- (void) reloadCellMenu
{
	NSMenu*			cellMenu			= [[NSMenu alloc] initWithTitle: @""];
	NSEnumerator*	bookmarkEnumerator	= [mContainedBookmarks objectEnumerator];
	Bookmark*		currentBookmark		= nil;
	
	[cellMenu addItem: [NSMenuItem separatorItem]];
	
	while ((currentBookmark = [bookmarkEnumerator nextObject]) != nil)
	{
		NSMenuItem*	bookmarkMenuItem = [[currentBookmark cell] menuItem];
		
		if (bookmarkMenuItem != nil)
		{
			[cellMenu addItem: bookmarkMenuItem];
		}
	}
	
	[mBookmarkBarCell setMenu: cellMenu];
	
	[cellMenu release];
}


@end