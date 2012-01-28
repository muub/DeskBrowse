/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import "KeychainAccess.h"
#import <CoreFoundation/CoreFoundation.h>
#import <Security/Security.h>


@implementation KeychainAccess


+ (KeychainAccess*) keychainAccess
{
	return [[[KeychainAccess alloc] init] autorelease];
}

- (BOOL) getKeychainWithName: (NSString*) name account: (NSString*) account keychainItem: (SecKeychainItemRef*) keychainItem
{
	BOOL	exists	= NO;
	OSErr	result	= SecKeychainFindGenericPassword(NULL, [name length], [name UTF8String], [account length], [account UTF8String], 0, NULL, keychainItem);
	
	exists = (result != errSecItemNotFound);
	
	return exists;
}

- (BOOL) addNewKeychainItemWithName: (NSString*) name account: (NSString*) account password: (NSString*) password
{
	BOOL				added			= NO;
	SecKeychainItemRef	keychainItem	= nil;
	OSErr				result			= noErr;
	
	if ([self getKeychainWithName: name account: account keychainItem: &keychainItem])
	{
		 // Keychain exists, change password
		 
		result = SecKeychainItemModifyAttributesAndData(keychainItem, NULL, [password length], [password UTF8String]);
	}
	else
	{
		// Keychain doesn't exist, create one
		
		result = SecKeychainAddGenericPassword(NULL, [name length], [name UTF8String], [account length], [account UTF8String], [password length], [password UTF8String], NULL);
	}
	
	if (result == noErr)
	{
		added = YES;
	}
	
	return added;
}

- (NSString*) passwordFromKeychainWithName: (NSString*) name account: (NSString*) account
{
	NSString*	password			= nil;
	int			numberOfAttributes	= (name != nil) + (account != nil);
	
	if (numberOfAttributes > 0)
	{
		SecKeychainSearchRef		search			= NULL;
		SecKeychainItemRef			keychainItem	= NULL;
		SecKeychainAttributeList	attributeList;
		SecKeychainAttribute		attributes[numberOfAttributes];
		
		int index = 0;
		
		if (name != nil)
		{
			attributes[index].tag		= kSecServiceItemAttr;
			attributes[index].length	= [name length];
			attributes[index].data		= [name UTF8String];
			
			index++;
		}
		
		if (account != nil)
		{
			attributes[index].tag		= kSecAccountItemAttr;
			attributes[index].length	= [account length];
			attributes[index].data		= [account UTF8String];
			
			index++;
		}
		
		attributeList.count			= numberOfAttributes;
		attributeList.attr			= attributes;
		
		OSErr result = SecKeychainSearchCreateFromAttributes(NULL, kSecGenericPasswordItemClass, &attributeList, &search);
		
		if (result == noErr)
		{
			result = SecKeychainSearchCopyNext(search, &keychainItem);
			
			if (result == noErr)
			{
				password = [self passwordFromKeychainItem: keychainItem];
				
//				CFRelease(keychainItem);
			}
		}
	}
	
	return password;
}

- (NSString*) passwordFromKeychainItem: (SecKeychainItemRef) keychainItem
{
	NSString* passwordString = nil;
	
	if (keychainItem != NULL)
	{	
		UInt32						length = 0;
		char*						passwordChars;
		
		OSErr status = SecKeychainItemCopyContent(keychainItem, NULL, NULL, &length, (void**)&passwordChars);
		
		if (status == noErr)
		{
			if (passwordChars != NULL)
			{
				char passwordBuffer[1024];
				
				if (length > 1023)
				{
					length = 1023;
				}
				
				strncpy(passwordBuffer, passwordChars, length);
				
				passwordBuffer[length] = '\0';
				
				passwordString = [NSString stringWithCString: passwordBuffer];
			}
		}
	}
	
	return passwordString;
}


@end