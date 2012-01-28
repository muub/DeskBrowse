/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import "KeyStuff.h"


@implementation KeyStuff


// --------------------------------------
//
//	characterForKeyCode:
//
//
//	Last edited by: Ian
//	On:	June 3, 2005
//	At:	8:14 PM
//
// --------------------------------------

+ (unichar) characterForKeyCode: (unsigned short) keyCode
{
	UInt32				character	= kNullCharCode;
	
	UInt32				state		= 0;
	const void*			keyboardLayoutData;
	KeyboardLayoutRef	currentKeyBoardLayout;

	if(KLGetCurrentKeyboardLayout(&currentKeyBoardLayout) == noErr && KLGetKeyboardLayoutProperty(currentKeyBoardLayout, kKLKCHRData, &keyboardLayoutData) == noErr)
	{
		character = KeyTranslate(keyboardLayoutData, keyCode, &state);

		switch(character)
		{
			case kPageUpCharCode:
			{
				character = NSPageUpFunctionKey;
				break;
			}
			case kPageDownCharCode:
			{
				character = NSPageDownFunctionKey;
				break;
			}
			case kBackspaceCharCode:
			{
				character = NSDeleteFunctionKey;
				break;
			}
			case kFunctionKeyCharCode:
			{
				character = 'F';//[self characterForFunctionKeyCode: keyCode];
				break;
			}
			case kLeftArrowCharCode:
			{
				character = NSLeftArrowFunctionKey;
				break;
			}
			case kRightArrowCharCode:
			{
				character = NSRightArrowFunctionKey;
				break;
			}
			case kUpArrowCharCode:
			{
				character = NSUpArrowFunctionKey;
				break;
			}
			case kDownArrowCharCode:
			{
				character = NSDownArrowFunctionKey;
				break;
			}
		}
	}
	
	return character;
}


// --------------------------------------
//
//	stringForKeyCode:modifiers:
//
//
//	Last edited by: Ian
//	On:	June 3, 2005
//	At:	6:09 PM
//
// --------------------------------------

+ (NSString*) stringForKeyCode: (unsigned short) keyCode modifiers: (unsigned int) modifiers
{
	NSString*	result		= nil;
	
	NSString*	modString	= [self stringForModifiers: modifiers];
	NSString*	keyString	= [self stringForKeyCode: keyCode];

	result = [NSString stringWithFormat: @"%@%@", modString, keyString];
			
	return result;
}


// --------------------------------------
//
//	stringForKeyCode:
//
//
//	Last edited by: Ian
//	On:	June 3, 2005
//	At:	8:14 PM
//
// --------------------------------------

+ (NSString*) stringForKeyCode: (unsigned short) keyCode
{
	NSString* stringForKey = nil;
	
	switch(keyCode)
	{
		/*case 50:
		{
			stringForKey = @"`";
			break;
		}
		case 27:
		{
			stringForKey = @"-";
			break;
		}
		case 24:
		{
			stringForKey = @"=";
			break;
		}
		case 67:
		{
			stringForKey = @"*";
			break;
		}
		case 69:
		{
			stringForKey = @"+";
			break;
		}
		case 33:
		{
			stringForKey = @"[";
			break;
		}
		case 30:
		{
			stringForKey = @"]";
			break;
		}
		case 42:
		{
			stringForKey = @"\\";
			break;
		}
		case 41:
		{
			stringForKey = @";";
			break;
		}
		case 39:
		{
			stringForKey = @"'";
			break;
		}
		case 43:
		{
			stringForKey = @",";
			break;
		}
		case 47:
		{
			stringForKey = @".";
			break;
		}
		case 44:
		{
			stringForKey = @"/";
			break;
		}
		case 18:
		{
			stringForKey = @"1";
			break;
		}
		case 19:
		{
			stringForKey = @"2";
			break;
		}
		case 20:
		{
			stringForKey = @"3";
			break;
		}
		case 21:
		{
			stringForKey = @"4";
			break;
		}
		case 23:
		{
			stringForKey = @"5";
			break;
		}
		case 22:
		{
			stringForKey = @"6";
			break;
		}
		case 26:
		{
			stringForKey = @"7";
			break;
		}
		case 28:
		{
			stringForKey = @"8";
			break;
		}
		case 25:
		{
			stringForKey = @"9";
			break;
		}
		case 29:
		{
			stringForKey = @"0";
			break;
		}
		case 0:
		{
			stringForKey = @"A";
			break;
		}
		case 11:
		{
			stringForKey = @"B";
			break;
		}
		case 8:
		{
			stringForKey = @"C";
			break;
		}
		case 2:
		{
			stringForKey = @"D";
			break;
		}
		case 14:
		{
			stringForKey = @"E";
			break;
		}
		case 3:
		{
			stringForKey = @"F";
			break;
		}
		case 5:
		{
			stringForKey = @"G";
			break;
		}
		case 4:
		{
			stringForKey = @"H";
			break;
		}
		case 34:
		{
			stringForKey = @"I";
			break;
		}
		case 38:
		{
			stringForKey = @"J";
			break;
		}
		case 40:
		{
			stringForKey = @"K";
			break;
		}
		case 37:
		{
			stringForKey = @"L";
			break;
		}
		case 46:
		{
			stringForKey = @"M";
			break;
		}
		case 45:
		{
			stringForKey = @"N";
			break;
		}
		case 31:
		{
			stringForKey = @"O";
			break;
		}
		case 35:
		{
			stringForKey = @"P";
			break;
		}
		case 12:
		{
			stringForKey = @"Q";
			break;
		}
		case 15:
		{
			stringForKey = @"R";
			break;
		}
		case 1:
		{
			stringForKey = @"S";
			break;
		}
		case 17:
		{
			stringForKey = @"T";
			break;
		}
		case 32:
		{
			stringForKey = @"U";
			break;
		}
		case 9:
		{
			stringForKey = @"V";
			break;
		}
		case 13:
		{
			stringForKey = @"W";
			break;
		}
		case 7:
		{
			stringForKey = @"X";
			break;
		}
		case 16:
		{
			stringForKey = @"Y";
			break;
		}
		case 6:
		{
			stringForKey = @"Z";
			break;
		}
		*/
		case 122:
		{
			stringForKey = @"F1";
			break;
		}
		case 120:
		{
			stringForKey = @"F2";
			break;
		}
		case 99:
		{
			stringForKey = @"F3";
			break;
		}
		case 118:
		{
			stringForKey = @"F4";
			break;
		}
		case 96:
		{
			stringForKey = @"F5";
			break;
		}
		case 97:
		{
			stringForKey = @"F6";
			break;
		}
		case 98:
		{
			stringForKey = @"F7";
			break;
		}
		case 100:
		{
			stringForKey = @"F8";
			break;
		}
		case 101:
		{
			stringForKey = @"F9";
			break;
		}
		case 109:
		{
			stringForKey = @"F10";
			break;
		}
		case 103:
		{
			stringForKey = @"F11";
			break;
		}
		case 111:
		{
			stringForKey = @"F12";
			break;
		}
		case 105:
		{
			stringForKey = @"F13";
			break;
		}
		default:
		{
			unichar character	= [self characterForKeyCode: keyCode];
			stringForKey		= [[NSString stringWithCharacters: &character length: 1] uppercaseString];
		}
	}
	
	return stringForKey;
}


// --------------------------------------
//
//	stringForModifiers:
//
//
//	Last edited by: Ian
//	On:	June 3, 2005
//	At:	6:09 PM
//
// --------------------------------------

+ (NSString*) stringForModifiers: (unsigned int) modifiers
{
	NSMutableString*	stringResult = [NSMutableString string];
	unichar				character;
	
	if(modifiers & NSShiftKeyMask)
	{
		character = kShiftUnicode;
		[stringResult appendString: [NSString stringWithCharacters: &character length: 1]];
	}
	
	if(modifiers & NSControlKeyMask)
	{
		character = kControlUnicode;
		[stringResult appendString: [NSString stringWithCharacters: &character length: 1]];
	}
	
	if(modifiers & NSAlternateKeyMask)
	{
		character = kOptionUnicode;
		[stringResult appendString: [NSString stringWithCharacters: &character length: 1]];
	}
	
	if(modifiers & NSCommandKeyMask)
	{
		character = kCommandUnicode;
		[stringResult appendString: [NSString stringWithCharacters: &character length: 1]];
	}
		
	return stringResult;
}


@end