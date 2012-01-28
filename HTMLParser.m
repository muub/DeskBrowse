/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import "HTMLParser.h"


//============================================================
//
//	Thank you Adium for being a great point of reference!
//
//============================================================

// For finding links
NSString* kAOpen			= @"A ";
NSString* kAClose			= @"</A";
NSString* kHREF				= @"HREF=";
NSString* kOpenBracket		= @"<";
NSString* kCloseBracket		= @">";
NSString* kQuoteCharacters	= @"'\"";

// For replacing HTML
NSString* kHTMLCharStart	= @"&";
NSString* kHTMLCharEnd		= @";";
NSString* kAmpersandHTML	= @"AMP";
NSString* kAmpersand		= @"&";
NSString* kApostropheHTML	= @"APOS";
NSString* kApostrophe		= @"'";
NSString* kDashHTML			= @"MDASH";
NSString* kDash				= @"-";
NSString* kGreaterThanHTML	= @"GT";
NSString* kGreaterThan		= @">";
NSString* kLessThanHTML		= @"LT";
NSString* kLessThan			= @"<";
NSString* kQuoteHTML		= @"QUOT";
NSString* kQuote			= @"\"";
NSString* kSpaceHTML		= @"NBSP";
NSString* kSpace			= @" ";


@interface HTMLParser (Private)

- (NSString*) pReplaceHTMLCodesInString: (NSString*) HTMLString;

@end


@implementation HTMLParser


+ (HTMLParser*) HTMLParser
{
	return [[[HTMLParser alloc] init] autorelease];
}

- (NSArray*) linksFromHTMLString: (NSString*) HTMLString
{
	NSMutableArray*	links				= nil;
	NSScanner*		linkScanner			= [NSScanner scannerWithString: HTMLString];
	NSCharacterSet*	quotesCharacterSet	= [NSCharacterSet characterSetWithCharactersInString: kQuoteCharacters];
	int				lengthOfHTMLString	= [HTMLString length];
	int				lengthOfAOpen		= [kAOpen length];
	int				lengthOfHREF		= [kHREF length];	
	
	while (![linkScanner isAtEnd])
	{
		NSString*	intoString				= nil;
		int			scanLocation			= [linkScanner scanLocation];
		int			lengthOfRemainingString	= lengthOfHTMLString - scanLocation;
		
		NSRange		rangeOfAOpen			= NSMakeRange(scanLocation, lengthOfAOpen);
		
		if (lengthOfRemainingString - 1 > lengthOfAOpen && [[HTMLString substringWithRange: rangeOfAOpen] caseInsensitiveCompare: kAOpen] == NSOrderedSame)
		{
			// Found "A" tag
			
			if ([linkScanner scanUpToString: kHREF intoString: nil])
			{
				// Advance the scanner to the URL
				
				if (lengthOfHTMLString - [linkScanner scanLocation] > lengthOfHREF + 1)
				{
					[linkScanner setScanLocation: [linkScanner scanLocation] + lengthOfHREF + 1];
				}
				
				
				// Scan the URL into an NSString
				
				NSString* URLString = nil;
				
				if ([linkScanner scanUpToCharactersFromSet: quotesCharacterSet intoString: &URLString])
				{
					// Advance the scanner to the end of the A tag
					
					if ([linkScanner scanUpToString: kCloseBracket intoString: nil])
					{
						// Advance the scanner to the title
						
						if (lengthOfHTMLString - [linkScanner scanLocation] > 1)
						{
							[linkScanner setScanLocation: [linkScanner scanLocation] + 1];
						}
						
						
						// Scan the title into an NSString
						
						NSString* title = nil;
						
						if ([linkScanner scanUpToString: kAClose intoString: &title])
						{
							if (URLString != nil)
							{
								if (title == nil)
								{
									title = [NSString string];
								}
								
								title = [self pReplaceHTMLCodesInString: title];
								
								NSArray*		objects				= [NSArray arrayWithObjects: title, URLString, nil];
								NSArray*		keys				= [NSArray arrayWithObjects: kLinkTitleKey, kLinkURLStringKey, nil];
								NSDictionary*	newLinkDictionary	= [NSDictionary dictionaryWithObjects: objects forKeys: keys];
								
								if (links == nil)
								{
									links = [NSMutableArray array];
								}
								
								[links addObject: newLinkDictionary];
							}
						}
					}
				}
			}
		}
		
		
		// Advance the scanner one character
		
		scanLocation = [linkScanner scanLocation];
		
		if ((lengthOfHTMLString - scanLocation) > 0)
		{
			[linkScanner setScanLocation: scanLocation + 1];
		}
	}
	
	return links;
}

- (NSArray*) linksFromHTMLFileAtPath: (NSString*) HTMLFilePath
{
	NSString* HTMLStringFromFile = [NSString stringWithContentsOfFile: HTMLFilePath encoding: NSUTF8StringEncoding error: nil];
	
	return [self linksFromHTMLString: HTMLStringFromFile];
}


@end


@implementation HTMLParser (Private)


- (NSString*) pReplaceHTMLCodesInString: (NSString*) HTMLString
{
	NSMutableString*	newString		= [[HTMLString mutableCopy] autorelease];
	NSRange				currentRange	= NSMakeRange(NSNotFound, 0);
	
	
	// Ampersand
	while ((currentRange = [newString rangeOfString: [NSString stringWithFormat: @"%@%@%@", kHTMLCharStart, kAmpersandHTML, kHTMLCharEnd] options: NSCaseInsensitiveSearch]).location != NSNotFound)
	{
		[newString replaceCharactersInRange: currentRange withString: kAmpersand];
	}
	
	// Apostrophe
	while ((currentRange = [newString rangeOfString: [NSString stringWithFormat: @"%@%@%@", kHTMLCharStart, kApostropheHTML, kHTMLCharEnd] options: NSCaseInsensitiveSearch]).location != NSNotFound)
	{
		[newString replaceCharactersInRange: currentRange withString: kApostrophe];
	}
	
	// Dash
	while ((currentRange = [newString rangeOfString: [NSString stringWithFormat: @"%@%@%@", kHTMLCharStart, kDashHTML, kHTMLCharEnd] options: NSCaseInsensitiveSearch]).location != NSNotFound)
	{
		[newString replaceCharactersInRange: currentRange withString: kDash];
	}
	
	// Greater than
	while ((currentRange = [newString rangeOfString: [NSString stringWithFormat: @"%@%@%@", kHTMLCharStart, kGreaterThanHTML, kHTMLCharEnd] options: NSCaseInsensitiveSearch]).location != NSNotFound)
	{
		[newString replaceCharactersInRange: currentRange withString: kGreaterThan];
	}
	
	// Less than
	while ((currentRange = [newString rangeOfString: [NSString stringWithFormat: @"%@%@%@", kHTMLCharStart, kLessThanHTML, kHTMLCharEnd] options: NSCaseInsensitiveSearch]).location != NSNotFound)
	{
		[newString replaceCharactersInRange: currentRange withString: kLessThan];
	}
	
	// Quote
	while ((currentRange = [newString rangeOfString: [NSString stringWithFormat: @"%@%@%@", kHTMLCharStart, kQuoteHTML, kHTMLCharEnd] options: NSCaseInsensitiveSearch]).location != NSNotFound)
	{
		[newString replaceCharactersInRange: currentRange withString: kQuote];
	}
	
	// Space
	while ((currentRange = [newString rangeOfString: [NSString stringWithFormat: @"%@%@%@", kHTMLCharStart, kSpaceHTML, kHTMLCharEnd] options: NSCaseInsensitiveSearch]).location != NSNotFound)
	{
		[newString replaceCharactersInRange: currentRange withString: kSpace];
	}
	
	return newString;
}


@end