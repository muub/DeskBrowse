/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import "SymbolicHotKeyController.h"


@interface SymbolicHotKeyState : NSObject
{
	BOOL mAllWindowsEnabled, mAllWindowsSlowEnabled, mAppWindowsEnabled, mAppWindowsSlowEnabled, mShowDesktopEnabled, mShowDesktopSlowEnabled, mShowDashboardEnabled, mShowDashboardSlowEnabled;
}

- (id) initWithCurrentState;

- (void) restore;

@end



@implementation SymbolicHotKeyController


+ (id) symbolicHotKeyController
{
	return [[[SymbolicHotKeyController alloc] init] autorelease];
}

- (void) dealloc
{
	[mSavedHotKeyState release];
	
	[super dealloc];
}


- (void) disableAllHotKeys
{
	[[SymbolicHotKey allWindowsSymbolicHotKey]				setEnabled: NO];
	[[SymbolicHotKey allWindowsSlowSymbolicHotKey]			setEnabled: NO];
	[[SymbolicHotKey applicationWindowsSymbolicHotKey]		setEnabled: NO];
	[[SymbolicHotKey applicationWindowsSlowSymbolicHotKey]	setEnabled: NO];
	[[SymbolicHotKey showDesktopSymbolicHotKey]				setEnabled: NO];
	[[SymbolicHotKey showDesktopSlowSymbolicHotKey]			setEnabled: NO];
	[[SymbolicHotKey showDashboardSymbolicHotKey]			setEnabled: NO];
	[[SymbolicHotKey showDashboardSlowSymbolicHotKey]		setEnabled: NO];
}

- (void) enableAllHotKeys
{
	[[SymbolicHotKey allWindowsSymbolicHotKey]				setEnabled: YES];
	[[SymbolicHotKey allWindowsSlowSymbolicHotKey]			setEnabled: YES];
	[[SymbolicHotKey applicationWindowsSymbolicHotKey]		setEnabled: YES];
	[[SymbolicHotKey applicationWindowsSlowSymbolicHotKey]	setEnabled: YES];
	[[SymbolicHotKey showDesktopSymbolicHotKey]				setEnabled: YES];
	[[SymbolicHotKey showDesktopSlowSymbolicHotKey]			setEnabled: YES];
	[[SymbolicHotKey showDashboardSymbolicHotKey]			setEnabled: YES];
	[[SymbolicHotKey showDashboardSlowSymbolicHotKey]		setEnabled: YES];
}


- (void) saveHotKeyState
{
	if (mSavedHotKeyState != nil)
	{
		[mSavedHotKeyState release];
		mSavedHotKeyState = nil;
	}
	
	mSavedHotKeyState = [[SymbolicHotKeyState alloc] initWithCurrentState];
}

- (void) restoreHotKeyState
{
	[mSavedHotKeyState restore];
}


@end



@implementation SymbolicHotKeyState


- (id) initWithCurrentState
{
	if (self = [super init])
	{
		mAllWindowsEnabled			= [[SymbolicHotKey allWindowsSymbolicHotKey]				enabled];
		mAllWindowsSlowEnabled		= [[SymbolicHotKey allWindowsSlowSymbolicHotKey]			enabled];
		mAppWindowsEnabled			= [[SymbolicHotKey applicationWindowsSymbolicHotKey]		enabled];
		mAppWindowsSlowEnabled		= [[SymbolicHotKey applicationWindowsSlowSymbolicHotKey]	enabled];
		mShowDesktopEnabled			= [[SymbolicHotKey showDesktopSymbolicHotKey]				enabled];
		mShowDesktopSlowEnabled		= [[SymbolicHotKey showDesktopSlowSymbolicHotKey]			enabled];
		mShowDashboardEnabled		= [[SymbolicHotKey showDashboardSymbolicHotKey]				enabled];
		mShowDashboardSlowEnabled	= [[SymbolicHotKey showDashboardSlowSymbolicHotKey]			enabled];
	}
	
	return self;
}

- (void) restore
{
	[[SymbolicHotKey allWindowsSymbolicHotKey]				setEnabled: mAllWindowsEnabled];
	[[SymbolicHotKey allWindowsSlowSymbolicHotKey]			setEnabled: mAllWindowsSlowEnabled];
	[[SymbolicHotKey applicationWindowsSymbolicHotKey]		setEnabled: mAppWindowsEnabled];
	[[SymbolicHotKey applicationWindowsSlowSymbolicHotKey]	setEnabled: mAppWindowsSlowEnabled];
	[[SymbolicHotKey showDesktopSymbolicHotKey]				setEnabled: mShowDesktopEnabled];
	[[SymbolicHotKey showDesktopSlowSymbolicHotKey]			setEnabled: mShowDesktopSlowEnabled];
	[[SymbolicHotKey showDashboardSymbolicHotKey]			setEnabled: mShowDashboardEnabled];
	[[SymbolicHotKey showDashboardSlowSymbolicHotKey]		setEnabled: mShowDashboardSlowEnabled];
}


@end



enum
{
	kCGSWindowVousAllHotKey					= 32,	// All windows
	kCGSWindowVousFrontHotKey				= 33,	// Application windows
	kCGSWindowVousAllSlowHotKey				= 34,	// All windows slow
	kGSWindowVousFrontSlowHotKey			= 35,	// Application windows slow
	kGGSWindowVousShowDesktopHotKey			= 36,	// Desktop
	kCGSWindowVousShowDesktopSlowHotKey		= 37,	// Desktop slow
	kCGSWindowVousShowDashboardHotKey		= 62,	// Dashboard
	kCGSWindowVousShowDashboardSlowHotKey	= 63	// Dashboard slow
};

extern char CGSIsSymbolicHotKeyEnabled(int32_t key);
extern char CGSSetSymbolicHotKeyEnabled(int32_t key, unsigned char enabled);

@implementation SymbolicHotKey


- (id) initWithSymbolicHotKeyType: (SymbolicHotKeyType) symbolicHotKeyType
{
	if (self = [super init])
	{
		if (symbolicHotKeyType == SymbolicHotKeyTypeInvalid)
		{
			[self release];
			self = nil;
		}
		else
		{
			mSymbolicHotKey = [self symbolicHotKeyForType: symbolicHotKeyType];
		}
	}
	
	return self;
}


+ (id) symbolicHotKeyWithType: (SymbolicHotKeyType) symbolicHotKeyType
{
	return [[[[self class] alloc] initWithSymbolicHotKeyType: symbolicHotKeyType] autorelease];
}


+ (id) allWindowsSymbolicHotKey
{
	return [[self class] symbolicHotKeyWithType: SymbolicHotKeyTypeAllWindows];
}

+ (id) allWindowsSlowSymbolicHotKey
{
	return [[self class] symbolicHotKeyWithType: SymbolicHotKeyTypeAllWindowsSlow];
}

+ (id) applicationWindowsSymbolicHotKey
{
	return [[self class] symbolicHotKeyWithType: SymbolicHotKeyTypeApplicationWindows];
}

+ (id) applicationWindowsSlowSymbolicHotKey
{
	return [[self class] symbolicHotKeyWithType: SymbolicHotKeyTypeApplicationWindowsSlow];
}

+ (id) showDesktopSymbolicHotKey
{
	return [[self class] symbolicHotKeyWithType: SymbolicHotKeyTypeShowDesktop];
}

+ (id) showDesktopSlowSymbolicHotKey
{
	return [[self class] symbolicHotKeyWithType: SymbolicHotKeyTypeShowDesktopSlow];
}

+ (id) showDashboardSymbolicHotKey
{
	return [[self class] symbolicHotKeyWithType: SymbolicHotKeyTypeShowDashboard];
}

+ (id) showDashboardSlowSymbolicHotKey
{
	return [[self class] symbolicHotKeyWithType: SymbolicHotKeyTypeShowDashboardSlow];
}


- (BOOL) enabled
{
	BOOL enabled = (BOOL) CGSIsSymbolicHotKeyEnabled(mSymbolicHotKey);
	
	return enabled;
}

- (void) setEnabled: (BOOL) enabled
{
	CGSSetSymbolicHotKeyEnabled(mSymbolicHotKey, (unsigned char) enabled);
}


- (int32_t) symbolicHotKeyForType: (SymbolicHotKeyType) symbolicHotKeyType
{
	int32_t symbolicHotKey = 0;
	
	if (symbolicHotKeyType != SymbolicHotKeyTypeInvalid)
	{
		switch (symbolicHotKeyType)
		{
			case SymbolicHotKeyTypeAllWindows:				symbolicHotKey = kCGSWindowVousAllHotKey;				break;
			case SymbolicHotKeyTypeApplicationWindows:		symbolicHotKey = kCGSWindowVousFrontHotKey;				break;
			case SymbolicHotKeyTypeAllWindowsSlow:			symbolicHotKey = kCGSWindowVousAllSlowHotKey;			break;
			case SymbolicHotKeyTypeApplicationWindowsSlow:	symbolicHotKey = kGSWindowVousFrontSlowHotKey;			break;
			case SymbolicHotKeyTypeShowDesktop:				symbolicHotKey = kGGSWindowVousShowDesktopHotKey;		break;
			case SymbolicHotKeyTypeShowDesktopSlow:			symbolicHotKey = kCGSWindowVousShowDesktopSlowHotKey;	break;
			case SymbolicHotKeyTypeShowDashboard:			symbolicHotKey = kCGSWindowVousShowDashboardHotKey;		break;
			case SymbolicHotKeyTypeShowDashboardSlow:		symbolicHotKey = kCGSWindowVousShowDashboardSlowHotKey;	break;
		}
	}
	
	return symbolicHotKey;
}


@end