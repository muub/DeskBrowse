/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import "BookmarkImporter.h"

#import "Bookmark.h"
#import "HTMLParser.h"
#import "URLFormatter.h"


// Schemes

NSString* kFeedScheme								= @"feed";
NSString* kFileScheme								= @"file";
NSString* kHTTPScheme								= @"http";
NSString* kHTTPSScheme								= @"https";


// Camino

NSString* kPathOfCaminoBookmarksFile				= @"~/Library/Application Support/Camino/bookmarks.plist";

NSString* kCaminoChildrenKey						= @"Children";
NSString* kCaminoBookmarkURLStringKey				= @"URL";
NSString* kCaminoBookmarkTitleKey					= @"Title";


// Firefox

NSString* kPathOfFirefoxV8OrLessBookmarksDirectory	= @"~/Library/Phoenix/Profiles/default";
NSString* kPathOfFirefoxV9BookmarksDirectory		= @"~/Library/Application Support/Firefox/Profiles";
NSString* kNameOfFirefoxBookmarksFile				= @"bookmarks.html";

NSString* kPartOf9To10BookmarkDirectoryName			= @"default.";
NSString* kPartOf10UpBookmarkDirectoryName			= @".default";
NSString* kPartOf8OrLessBookmarkDirectoryName		= @".slt";


// Mozilla

NSString* kPathOfMozillaBookmarksDirectory			= @"~/Library/Mozilla/Profiles/default";
NSString* kNameOfMozillaBookmarksFile				= @"bookmarks.html";

NSString* kPartOfMozillaBookmarkDirectoryName		= @".slt";


// Safari

NSString* kPathOfSafariBookmarksFile				= @"~/Library/Safari/Bookmarks.plist";

NSString* kSafariWebBookmarkType					= @"WebBookmarkType";
NSString* kSafariWebBookmarkTypeList				= @"WebBookmarkTypeList";
NSString* kSafariWebBookmarkTypeLeaf				= @"WebBookmarkTypeLeaf";

NSString* kSafariChildrenKey						= @"Children";
NSString* kSafariBookmarkURIDictionaryKey			= @"URIDictionary";
NSString* kSafariBookmarkURLStringKey				= @"URLString";
NSString* kSafariBookmarkTitleKey					= @"title";


// Shiira

NSString* kPathOfShiiraBookmarksFile				= @"~/Library/Shiira/Bookmarks.plist";

NSString* kShiiraChildrenKey						= @"Children";
NSString* kShiiraBookmarkURLStringKey				= @"URLString";
NSString* kShiiraBookmarkTitleKey					= @"Title";


@implementation BookmarkImporter


+ (BookmarkImporter*) bookmarkImporter
{
	return [[[BookmarkImporter alloc] init] autorelease];
}

+ (BOOL) isURLEquivalent: (NSURL*) URL1 toURL: (NSURL*) URL2
{
	BOOL		equivalent	= NO;
	NSString*	scheme1		= [URL1 scheme];
	NSString*	scheme2		= [URL2 scheme];
	
	if ([scheme1 caseInsensitiveCompare: scheme2] == NSOrderedSame)
	{
		NSString* resSpec1 = [URL1 resourceSpecifier];
		NSString* resSpec2 = [URL2 resourceSpecifier];
		
		resSpec1 = [resSpec1 stringByDeletingTrailingSlash];
		resSpec2 = [resSpec2 stringByDeletingTrailingSlash];
				
		if ([resSpec1 caseInsensitiveCompare: resSpec2] == NSOrderedSame)
		{
			equivalent = YES;
		}
	}
	
	return equivalent;
}


#pragma mark Camino

- (NSString*) pathOfCaminoBookmarksFile
{
	NSString*		pathOfCaminoBookmarksFile	= [kPathOfCaminoBookmarksFile stringByExpandingTildeInPath];
	NSFileManager*	fileManager					= [NSFileManager defaultManager];
	
	if (![fileManager fileExistsAtPath: pathOfCaminoBookmarksFile])
	{
		pathOfCaminoBookmarksFile = nil;
	}
	
	return pathOfCaminoBookmarksFile;
}

- (NSArray*) caminoBookmarksExcludingBookmarks: (NSArray*) excludedBookmarks
{
	NSMutableArray* caminoBookmarks				= [NSMutableArray array];
	NSString*		pathOfCaminoBookmarksFile	= [self pathOfCaminoBookmarksFile];
	
	excludedBookmarks = [excludedBookmarks mutableCopy];
	
	if (pathOfCaminoBookmarksFile != nil)
	{
		NSDictionary* caminoBookmarkDictionary = [NSDictionary dictionaryWithContentsOfFile: pathOfCaminoBookmarksFile];
		
		if (caminoBookmarkDictionary != nil)
		{
			[self processCaminoBookmarksFromDictionary: caminoBookmarkDictionary intoArray: caminoBookmarks excludingBookmarks: excludedBookmarks];
		}
	}
	
	[excludedBookmarks release];
	
	return caminoBookmarks;
}

- (void) processCaminoBookmarksFromDictionary: (NSDictionary*) caminoDictionary intoArray: (NSMutableArray*) bookmarkStorage excludingBookmarks: (NSArray*) excludedBookmarks
{
	NSArray* children = [caminoDictionary objectForKey: kCaminoChildrenKey];
	
	if (children != nil)
	{
		// Loop through dictionaries in list and process them
		
		NSEnumerator*	childrenEnumerator	= [children objectEnumerator];
		NSDictionary*	currentChild		= nil;
		
		while ((currentChild = [childrenEnumerator nextObject]) != nil)
		{
			[self processCaminoBookmarksFromDictionary: currentChild intoArray: bookmarkStorage excludingBookmarks: excludedBookmarks];
		}
	}
	else
	{
		// Create Bookmark from info
		
		NSString*		bookmarkTitle	= [caminoDictionary objectForKey: kCaminoBookmarkTitleKey];
		NSString*		URLString		= [caminoDictionary objectForKey: kCaminoBookmarkURLStringKey];
		
		if (URLString != nil)
		{
			NSURL* bookmarkURL = [NSURL URLWithString: URLString];
			
			if (bookmarkTitle != nil && bookmarkURL != nil)
			{
				//
				// We're not adding URLs of the "feed" scheme. I think it's RSS, which we don't have yet.
				//
				BOOL		isFeedScheme	= NO;
				NSString*	bookmarkScheme	= [bookmarkURL scheme];
				
				isFeedScheme = ([bookmarkScheme caseInsensitiveCompare: kFeedScheme] == NSOrderedSame);
				//
				//
				
				if (!isFeedScheme)
				{
					Bookmark* newBookmark = [[Bookmark alloc] initWithURL: bookmarkURL title: bookmarkTitle];
					
					if (newBookmark != nil)
					{
						BOOL			addBookmark					= YES;
						NSEnumerator*	excludedBookmarkEnumerator	= [excludedBookmarks objectEnumerator];
						Bookmark*		currentExcludedBookmark		= nil;
						
						while ((currentExcludedBookmark = [excludedBookmarkEnumerator nextObject]) != nil)
						{
							if ([BookmarkImporter isURLEquivalent: bookmarkURL toURL: [currentExcludedBookmark URL]])
							{
								addBookmark = NO;
								break;
							}
						}
						
						if (addBookmark)
						{
							[bookmarkStorage addObject: newBookmark];
							[(NSMutableArray*)excludedBookmarks addObject: newBookmark];
						}
						
						[newBookmark release];
						newBookmark = nil;
					}
				}
			}
		}
	}
}


#pragma mark Firefox

- (NSString*) pathOfFirefoxBookmarksFile
{
	NSString*		pathOfFirefoxBookmarksFile		= nil;
	NSString*		pathOfFirefoxBookmarksDirectory	= [kPathOfFirefoxV9BookmarksDirectory stringByExpandingTildeInPath];
	NSFileManager*	fileManager						= [NSFileManager defaultManager];
	
	if ([fileManager fileExistsAtPath: pathOfFirefoxBookmarksDirectory])
	{
		// Firefox V 0.9 or later
		// Enumerate bookmarks directory for bookmark folder
		
		NSArray*		contentsOfBookmarkDirectory		= [fileManager directoryContentsAtPath: pathOfFirefoxBookmarksDirectory];
		NSEnumerator*	bookmarksDirectoryEnumerator	= [contentsOfBookmarkDirectory objectEnumerator];
		NSString*		currentFileName					= nil;
		BOOL			foundBookmarkFolder				= NO;
		
		while ((currentFileName = [bookmarksDirectoryEnumerator nextObject]) != nil)
		{
			NSRange rangeOf9To10String	= [currentFileName rangeOfString: kPartOf9To10BookmarkDirectoryName];
			NSRange rangeOf10UpString	= [currentFileName rangeOfString: kPartOf10UpBookmarkDirectoryName];
			
			if (rangeOf9To10String.location != NSNotFound || rangeOf10UpString.location != NSNotFound)
			{
				foundBookmarkFolder = YES;
			}
			
			if (foundBookmarkFolder)
			{
				pathOfFirefoxBookmarksFile	= [pathOfFirefoxBookmarksDirectory stringByAppendingPathComponent: currentFileName];
				pathOfFirefoxBookmarksFile	= [pathOfFirefoxBookmarksFile stringByAppendingPathComponent: kNameOfFirefoxBookmarksFile];
				
				break;
			}
		}
	}
	else
	{
		// Firefox V 0.8.x or less
		// Enumerate bookmarks directory for bookmark folder
		
		pathOfFirefoxBookmarksDirectory	= [kPathOfFirefoxV8OrLessBookmarksDirectory stringByExpandingTildeInPath];
		
		NSArray*		contentsOfBookmarkDirectory		= [fileManager directoryContentsAtPath: pathOfFirefoxBookmarksDirectory];
		NSEnumerator*	bookmarksDirectoryEnumerator	= [contentsOfBookmarkDirectory objectEnumerator];
		NSString*		currentFileName					= nil;
		BOOL			foundBookmarkFolder				= NO;
		
		while ((currentFileName = [bookmarksDirectoryEnumerator nextObject]) != nil)
		{
			NSRange rangeOf8OrLessString = [currentFileName rangeOfString: kPartOf8OrLessBookmarkDirectoryName];
			
			if (rangeOf8OrLessString.location != NSNotFound)
			{
				foundBookmarkFolder = YES;
			}
			
			if (foundBookmarkFolder)
			{
				pathOfFirefoxBookmarksFile	= [pathOfFirefoxBookmarksDirectory stringByAppendingPathComponent: currentFileName];
				pathOfFirefoxBookmarksFile	= [pathOfFirefoxBookmarksFile stringByAppendingPathComponent: kNameOfFirefoxBookmarksFile];
				
				break;
			}
		}
	}
	
	if (![fileManager fileExistsAtPath: pathOfFirefoxBookmarksFile])
	{
		pathOfFirefoxBookmarksFile = nil;
	}
	
	return pathOfFirefoxBookmarksFile;
}

- (NSArray*) firefoxBookmarksExcludingBookmarks: (NSArray*) excludedBookmarks
{
	NSArray*	firefoxBookmarks			= [NSMutableArray array];
	NSString*	pathOfFirefoxBookmarksFile	= [self pathOfFirefoxBookmarksFile];
		
	if (pathOfFirefoxBookmarksFile != nil)
	{
		firefoxBookmarks = [self mozillaBookmarksFromPath: pathOfFirefoxBookmarksFile excludingBookmarks: excludedBookmarks];
	}
	
	return firefoxBookmarks;
}


#pragma mark Mozilla

- (NSString*) pathOfMozillaBookmarksFile
{
	NSString*		pathOfMozillaBookmarksFile		= nil;
	NSString*		pathOfMozillaBookmarksDirectory	= [kPathOfMozillaBookmarksDirectory stringByExpandingTildeInPath];
	NSFileManager*	fileManager						= [NSFileManager defaultManager];
	
	if ([fileManager fileExistsAtPath: pathOfMozillaBookmarksDirectory])
	{
		// Enumerate bookmarks directory for bookmark folder
		
		pathOfMozillaBookmarksDirectory	= [kPathOfMozillaBookmarksDirectory stringByExpandingTildeInPath];
		
		NSArray*		contentsOfBookmarkDirectory		= [fileManager directoryContentsAtPath: pathOfMozillaBookmarksDirectory];
		NSEnumerator*	bookmarksDirectoryEnumerator	= [contentsOfBookmarkDirectory objectEnumerator];
		NSString*		currentFileName					= nil;
		BOOL			foundBookmarkFolder				= NO;
		
		while ((currentFileName = [bookmarksDirectoryEnumerator nextObject]) != nil)
		{
			NSRange rangeOfPartString = [currentFileName rangeOfString: kPartOfMozillaBookmarkDirectoryName];
			
			if (rangeOfPartString.location != NSNotFound)
			{
				foundBookmarkFolder = YES;
			}
			
			if (foundBookmarkFolder)
			{
				pathOfMozillaBookmarksFile	= [pathOfMozillaBookmarksDirectory stringByAppendingPathComponent: currentFileName];
				pathOfMozillaBookmarksFile	= [pathOfMozillaBookmarksFile stringByAppendingPathComponent: kNameOfMozillaBookmarksFile];
				
				break;
			}
		}
	}
	
	if (![fileManager fileExistsAtPath: pathOfMozillaBookmarksFile])
	{
		pathOfMozillaBookmarksFile = nil;
	}
	
	return pathOfMozillaBookmarksFile;
}

- (NSArray*) mozillaBookmarksExcludingBookmarks: (NSArray*) excludedBookmarks
{
	NSArray*	mozillaBookmarks			= [NSMutableArray array];
	NSString*	pathOfMozillaBookmarksFile	= [self pathOfMozillaBookmarksFile];
		
	if (pathOfMozillaBookmarksFile != nil)
	{
		mozillaBookmarks = [self mozillaBookmarksFromPath: pathOfMozillaBookmarksFile excludingBookmarks: excludedBookmarks];
	}
	
	return mozillaBookmarks;
}

- (NSArray*) mozillaBookmarksFromPath: (NSString*) filePath excludingBookmarks: (NSArray*) excludedBookmarks
{
	NSMutableArray* bookmarks = [NSMutableArray array];
	
	excludedBookmarks = [excludedBookmarks mutableCopy];
	
	if (filePath != nil)
	{
		HTMLParser*		parser					= [HTMLParser HTMLParser];
		NSArray*		linksInFile				= [parser linksFromHTMLFileAtPath: filePath];
		NSEnumerator*	linkEnumerator			= [linksInFile objectEnumerator];
		NSDictionary*	currentLinkDictionary	= nil;
		
		while ((currentLinkDictionary = [linkEnumerator nextObject]) != nil)
		{
			NSString*	linkTitle		= [currentLinkDictionary objectForKey: kLinkTitleKey];
			NSString*	linkURLString	= [currentLinkDictionary objectForKey: kLinkURLStringKey];
			NSURL*		bookmarkURL		= [NSURL URLWithString: linkURLString];
			
			if (linkTitle != nil && bookmarkURL != nil)
			{
				//
				// We're not adding URLs of the "feed" scheme. I think it's RSS, which we don't have yet.
				//
				BOOL		isFeedScheme	= NO;
				NSString*	bookmarkScheme	= [bookmarkURL scheme];
				
				isFeedScheme = ([bookmarkScheme caseInsensitiveCompare: kFeedScheme] == NSOrderedSame);
				//
				//
				
				if (!isFeedScheme)
				{
					Bookmark* newBookmark = [[Bookmark alloc] initWithURL: bookmarkURL title: linkTitle];
					
					if (newBookmark != nil)
					{
						BOOL			addBookmark					= YES;
						NSEnumerator*	excludedBookmarkEnumerator	= [excludedBookmarks objectEnumerator];
						Bookmark*		currentExcludedBookmark		= nil;
						
						while ((currentExcludedBookmark = [excludedBookmarkEnumerator nextObject]) != nil)
						{
							if ([BookmarkImporter isURLEquivalent: bookmarkURL toURL: [currentExcludedBookmark URL]])
							{
								addBookmark = NO;
								break;
							}
						}
						
						if (addBookmark)
						{
							[bookmarks addObject: newBookmark];
							[(NSMutableArray*)excludedBookmarks addObject: newBookmark];
						}
						
						[newBookmark release];
						newBookmark = nil;
					}
				}
			}
			
		}
	}
	
	[excludedBookmarks release];
	
	return bookmarks;
}


#pragma mark Safari

- (NSString*) pathOfSafariBookmarksFile
{
	NSString*		pathOfSafariBookmarksFile	= [kPathOfSafariBookmarksFile stringByExpandingTildeInPath];
	NSFileManager*	fileManager					= [NSFileManager defaultManager];
	
	if (![fileManager fileExistsAtPath: pathOfSafariBookmarksFile])
	{
		pathOfSafariBookmarksFile = nil;
	}
	
	return pathOfSafariBookmarksFile;
}

- (NSArray*) safariBookmarksExcludingBookmarks: (NSArray*) excludedBookmarks
{	
	NSMutableArray* safariBookmarks				= [NSMutableArray array];
	NSString*		pathOfSafariBookmarksFile	= [self pathOfSafariBookmarksFile];
	
	excludedBookmarks = [excludedBookmarks mutableCopy];
	
	if (pathOfSafariBookmarksFile != nil)
	{
		NSDictionary* safariBookmarkDictionary = [NSDictionary dictionaryWithContentsOfFile: pathOfSafariBookmarksFile];
		
		if (safariBookmarkDictionary != nil)
		{
			[self processSafariBookmarksFromDictionary: safariBookmarkDictionary intoArray: safariBookmarks excludingBookmarks: excludedBookmarks];
		}
	}
	
	[excludedBookmarks release];
	
	return safariBookmarks;
}

- (void) processSafariBookmarksFromDictionary: (NSDictionary*) safariDictionary intoArray: (NSMutableArray*) bookmarkStorage excludingBookmarks: (NSArray*) excludedBookmarks
{
	NSString* webBookmarkType = [safariDictionary objectForKey: kSafariWebBookmarkType];
	
	if ([webBookmarkType isEqualToString: kSafariWebBookmarkTypeList])
	{
		// Loop through dictionaries in list and process them
		
		NSArray*		children			= [safariDictionary objectForKey: kSafariChildrenKey];
		NSEnumerator*	childrenEnumerator	= [children objectEnumerator];
		NSDictionary*	currentChild		= nil;
		
		while ((currentChild = [childrenEnumerator nextObject]) != nil)
		{
			[self processSafariBookmarksFromDictionary: currentChild intoArray: bookmarkStorage excludingBookmarks: excludedBookmarks];
		}
	}
	else if ([webBookmarkType isEqualToString: kSafariWebBookmarkTypeLeaf])
	{
		// Create Bookmark from info
		
		NSDictionary*	URIDictionary	= [safariDictionary objectForKey: kSafariBookmarkURIDictionaryKey];
		NSString*		bookmarkTitle	= [URIDictionary objectForKey: kSafariBookmarkTitleKey];
		NSString*		URLString		= [safariDictionary objectForKey: kSafariBookmarkURLStringKey];
		
		if (URLString != nil)
		{
			NSURL* bookmarkURL = [NSURL URLWithString: URLString];
			
			if (bookmarkTitle != nil && bookmarkURL != nil)
			{
				//
				// We're not adding URLs of the "feed" scheme. I think it's RSS, which we don't have yet.
				//
				BOOL		isFeedScheme	= NO;
				NSString*	bookmarkScheme	= [bookmarkURL scheme];
				
				isFeedScheme = ([bookmarkScheme caseInsensitiveCompare: kFeedScheme] == NSOrderedSame);
				//
				//
				
				if (!isFeedScheme)
				{
					Bookmark* newBookmark = [[Bookmark alloc] initWithURL: bookmarkURL title: bookmarkTitle];
					
					if (newBookmark != nil)
					{
						BOOL			addBookmark					= YES;
						NSEnumerator*	excludedBookmarkEnumerator	= [excludedBookmarks objectEnumerator];
						Bookmark*		currentExcludedBookmark		= nil;
						
						while ((currentExcludedBookmark = [excludedBookmarkEnumerator nextObject]) != nil)
						{
							if ([BookmarkImporter isURLEquivalent: bookmarkURL toURL: [currentExcludedBookmark URL]])
							{
								addBookmark = NO;
								break;
							}
						}
						
						if (addBookmark)
						{
							[bookmarkStorage addObject: newBookmark];
							[(NSMutableArray*)excludedBookmarks addObject: newBookmark];
						}
						
						[newBookmark release];
						newBookmark = nil;
					}
				}
			}
		}
	}
}


#pragma mark Shiira

- (NSString*) pathOfShiiraBookmarksFile
{
	NSString*		pathOfShiiraBookmarksFile	= [kPathOfShiiraBookmarksFile stringByExpandingTildeInPath];
	NSFileManager*	fileManager					= [NSFileManager defaultManager];
	
	if (![fileManager fileExistsAtPath: pathOfShiiraBookmarksFile])
	{
		pathOfShiiraBookmarksFile = nil;
	}
	
	return pathOfShiiraBookmarksFile;
}

- (NSArray*) shiiraBookmarksExcludingBookmarks: (NSArray*) excludedBookmarks
{
	NSMutableArray* shiiraBookmarks				= [NSMutableArray array];
	NSString*		pathOfShiiraBookmarksFile	= [self pathOfShiiraBookmarksFile];
	
	excludedBookmarks = [excludedBookmarks mutableCopy];
	
	if (pathOfShiiraBookmarksFile != nil)
	{
		NSDictionary* shiiraBookmarkDictionary = [NSDictionary dictionaryWithContentsOfFile: pathOfShiiraBookmarksFile];
		
		if (shiiraBookmarkDictionary != nil)
		{
			[self processShiiraBookmarksFromDictionary: shiiraBookmarkDictionary intoArray: shiiraBookmarks excludingBookmarks: excludedBookmarks];
		}
	}
	
	[excludedBookmarks release];
	
	return shiiraBookmarks;
}

- (void) processShiiraBookmarksFromDictionary: (NSDictionary*) shiiraDictionary intoArray: (NSMutableArray*) bookmarkStorage excludingBookmarks: (NSArray*) excludedBookmarks
{
	NSArray* children = [shiiraDictionary objectForKey: kShiiraChildrenKey];
	
	if (children != nil)
	{
		// Loop through dictionaries in list and process them
		
		NSEnumerator*	childrenEnumerator	= [children objectEnumerator];
		NSDictionary*	currentChild		= nil;
		
		while ((currentChild = [childrenEnumerator nextObject]) != nil)
		{
			[self processShiiraBookmarksFromDictionary: currentChild intoArray: bookmarkStorage excludingBookmarks: excludedBookmarks];
		}
	}
	else
	{
		// Create Bookmark from info
		
		NSString*		bookmarkTitle	= [shiiraDictionary objectForKey: kShiiraBookmarkTitleKey];
		NSString*		URLString		= [shiiraDictionary objectForKey: kShiiraBookmarkURLStringKey];
		
		if (URLString != nil)
		{
			NSURL* bookmarkURL = [NSURL URLWithString: URLString];
			
			if (bookmarkTitle != nil && bookmarkURL != nil)
			{
				//
				// We're not adding URLs of the "feed" scheme. I think it's RSS, which we don't have yet.
				//
				BOOL		isFeedScheme	= NO;
				NSString*	bookmarkScheme	= [bookmarkURL scheme];
				
				isFeedScheme = ([bookmarkScheme caseInsensitiveCompare: kFeedScheme] == NSOrderedSame);
				//
				//
				
				if (!isFeedScheme)
				{
					Bookmark* newBookmark = [[Bookmark alloc] initWithURL: bookmarkURL title: bookmarkTitle];
					
					if (newBookmark != nil)
					{
						BOOL			addBookmark					= YES;
						NSEnumerator*	excludedBookmarkEnumerator	= [excludedBookmarks objectEnumerator];
						Bookmark*		currentExcludedBookmark		= nil;
						
						while ((currentExcludedBookmark = [excludedBookmarkEnumerator nextObject]) != nil)
						{
							if ([BookmarkImporter isURLEquivalent: bookmarkURL toURL: [currentExcludedBookmark URL]])
							{
								addBookmark = NO;
								break;
							}
						}
						
						if (addBookmark)
						{
							[bookmarkStorage addObject: newBookmark];
							[(NSMutableArray*)excludedBookmarks addObject: newBookmark];
						}
						
						[newBookmark release];
						newBookmark = nil;
					}
				}
			}
		}
	}
}


@end


@implementation NSString (SGSURLHelper)


- (NSString*) stringByDeletingTrailingSlash
{
	NSString* stringWithoutTrailingSlash = self;
	
	if ([self length] > 0)
	{
		NSRange rangeOfLastCharacter = NSMakeRange([self length] - 1, 1);
		
		if ([[self substringWithRange: rangeOfLastCharacter] isEqualToString: @"/"])
		{
			NSRange rangeExcludingLastCharacter = NSMakeRange(0, [self length] - 1);
			stringWithoutTrailingSlash = [self substringWithRange: rangeExcludingLastCharacter];
		}
	}
	
	return stringWithoutTrailingSlash;
}


@end