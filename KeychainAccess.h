/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import <Cocoa/Cocoa.h>


@interface KeychainAccess : NSObject
{

}

+ (KeychainAccess*) keychainAccess;

- (BOOL) getKeychainWithName: (NSString*) name account: (NSString*) account keychainItem: (SecKeychainItemRef*) keychainItem;
- (BOOL) addNewKeychainItemWithName: (NSString*) name account: (NSString*) account password: (NSString*) password;
- (NSString*) passwordFromKeychainWithName: (NSString*) keychainName account: (NSString*) account;
- (NSString*) passwordFromKeychainItem: (SecKeychainItemRef) keychainItem;

@end