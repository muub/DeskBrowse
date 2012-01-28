/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import "NewBookmarkWindowController.h"

#import "Bookmark.h"
#import "BookmarkController.h"


NSString* const kNewBookmarkWindowNibName = @"NewBookmark";

@implementation NewBookmarkWindowController


- (id) initWithBookmarkController: (BookmarkController*) bookmarkController title: (NSString*) bookmarkTitle url: (NSURL*) bookmarkURL
{
	if (self = [super initWithWindowNibName: kNewBookmarkWindowNibName])
	{
		mBookmarkController = [bookmarkController retain];
		mBookmarkTitle		= [bookmarkTitle retain];
		mBookmarkURL		= [bookmarkURL retain];
	}
	
	return self;
}

- (void) dealloc
{
	[mBookmarkController release];
	[mBookmarkURL release];
	[mBookmarkTitle release];
	
	[super dealloc];
}


- (void) close
{
	[NSApp endSheet: [self window]];
	[super close];
	
	[self release];
}


- (void) runSheetOnWindow: (NSWindow*) window
{
	[NSApp beginSheet: [self window] modalForWindow: window modalDelegate: nil didEndSelector: nil contextInfo: nil];
	
	NSString* titleFieldValue = @"";
	
	if (mBookmarkTitle != nil)
	{
		titleFieldValue = mBookmarkTitle;
	}
	
	[mTitleField setStringValue: titleFieldValue];
	
	[self retain];
}


- (IBAction) ok: (id) sender
{
	NSString* newTitle = [mTitleField stringValue];
	
	if ([newTitle length] <= 0)
	{
		newTitle = [mBookmarkURL absoluteString];
	}
	
	if ([newTitle length] > 0)
	{
		Bookmark* newBookmark = [[Bookmark alloc] initWithURL: mBookmarkURL title: newTitle];
		
		[mBookmarkController addBookmark: newBookmark toFront: YES];
		
		[newBookmark release];
	}
	
	[self close];
}

- (IBAction) cancel: (id) sender
{
	[self close];
}


@end