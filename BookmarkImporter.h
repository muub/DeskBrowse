/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import <Cocoa/Cocoa.h>


@interface BookmarkImporter : NSObject
{

}

+ (BookmarkImporter*) bookmarkImporter;
+ (BOOL) isURLEquivalent: (NSURL*) URL1 toURL: (NSURL*) URL2;

// Camino
- (NSString*) pathOfCaminoBookmarksFile;
- (NSArray*) caminoBookmarksExcludingBookmarks: (NSArray*) excludedBookmarks;
- (void) processCaminoBookmarksFromDictionary: (NSDictionary*) caminoDictionary intoArray: (NSMutableArray*) bookmarkStorage excludingBookmarks: (NSArray*) excludedBookmarks;

// Firefox
- (NSString*) pathOfFirefoxBookmarksFile;
- (NSArray*) firefoxBookmarksExcludingBookmarks: (NSArray*) excludedBookmarks;

// Mozilla
- (NSString*) pathOfMozillaBookmarksFile;
- (NSArray*) mozillaBookmarksExcludingBookmarks: (NSArray*) excludedBookmarks;
- (NSArray*) mozillaBookmarksFromPath: (NSString*) filePath excludingBookmarks: (NSArray*) excludedBookmarks;

// Safari
- (NSString*) pathOfSafariBookmarksFile;
- (NSArray*) safariBookmarksExcludingBookmarks: (NSArray*) excludedBookmarks;
- (void) processSafariBookmarksFromDictionary: (NSDictionary*) safariDictionary intoArray: (NSMutableArray*) bookmarkStorage excludingBookmarks: (NSArray*) excludedBookmarks;

// Shiira
- (NSString*) pathOfShiiraBookmarksFile;
- (NSArray*) shiiraBookmarksExcludingBookmarks: (NSArray*) excludedBookmarks;
- (void) processShiiraBookmarksFromDictionary: (NSDictionary*) shiiraDictionary intoArray: (NSMutableArray*) bookmarkStorage excludingBookmarks: (NSArray*) excludedBookmarks;

@end

@interface NSString (SGSURLHelper)

- (NSString*) stringByDeletingTrailingSlash;

@end