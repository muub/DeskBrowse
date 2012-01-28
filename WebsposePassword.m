/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import "WebsposePassword.h"

#import "KeychainAccess.h"


static NSString* webpsosePasswordKeychainName		= @"DeskBrowse";
static NSString* webpsosePasswordKeychainAccount	= @"Webspose";

@implementation WebsposePassword


+ (NSString*) websposePassword
{
	NSString*		password = nil;
	KeychainAccess*	keychain = [KeychainAccess keychainAccess];
	
	
	// Get password from the keychain
	
	password = [[keychain passwordFromKeychainWithName: webpsosePasswordKeychainName account: webpsosePasswordKeychainAccount] retain];
		
	if (password == nil)
	{
		// Password wasn't in the keychain, so see if it's in the DeskBrowse preferences
		
		password = [[NSUserDefaults standardUserDefaults] stringForKey: kWebsposePassword];
	}
	
	return password;
}

+ (void) setWebsposePassword: (NSString*) password
{
	KeychainAccess* keychain = [KeychainAccess keychainAccess];
	
	
	// Save password to the keychain
	
	[keychain addNewKeychainItemWithName: webpsosePasswordKeychainName account: webpsosePasswordKeychainAccount password: password];
}


@end