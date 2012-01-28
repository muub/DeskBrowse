/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import <Cocoa/Cocoa.h>


@class SymbolicHotKeyState;

@interface SymbolicHotKeyController : NSObject
{
	@private
	
		SymbolicHotKeyState* mSavedHotKeyState;
}

+ (id) symbolicHotKeyController;

- (void) disableAllHotKeys;
- (void) enableAllHotKeys;

- (void) saveHotKeyState;
- (void) restoreHotKeyState;

@end


typedef enum
{
	SymbolicHotKeyTypeInvalid = 0,
	SymbolicHotKeyTypeAllWindows,				// All windows
	SymbolicHotKeyTypeApplicationWindows,		// Application windows
	SymbolicHotKeyTypeAllWindowsSlow,			// All windows slow
	SymbolicHotKeyTypeApplicationWindowsSlow,	// Application windows slow
	SymbolicHotKeyTypeShowDesktop,				// Desktop
	SymbolicHotKeyTypeShowDesktopSlow,			// Desktop slow
	SymbolicHotKeyTypeShowDashboard,			// Dashboard
	SymbolicHotKeyTypeShowDashboardSlow			// Dashboard slow
} SymbolicHotKeyType;

@interface SymbolicHotKey : NSObject
{
	@private
		
		int32_t mSymbolicHotKey;
}

- (id) initWithSymbolicHotKeyType: (SymbolicHotKeyType) symbolicHotKeyType;

+ (id) symbolicHotKeyWithType: (SymbolicHotKeyType) symbolicHotKeyType;

+ (id) allWindowsSymbolicHotKey;
+ (id) allWindowsSlowSymbolicHotKey;
+ (id) applicationWindowsSymbolicHotKey;
+ (id) applicationWindowsSlowSymbolicHotKey;
+ (id) showDesktopSymbolicHotKey;
+ (id) showDesktopSlowSymbolicHotKey;
+ (id) showDashboardSymbolicHotKey;
+ (id) showDashboardSlowSymbolicHotKey;

- (BOOL) enabled;
- (void) setEnabled: (BOOL) enabled;

- (int32_t) symbolicHotKeyForType: (SymbolicHotKeyType) symbolicHotKeyType;

@end