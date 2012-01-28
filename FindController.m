/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import "FindController.h"


@implementation FindController

- (id)init {
	self = [super init];
	if (self) {
		hidden = YES;
		wHidden = YES;
	}
	return self;
}

- (IBAction)findText:(id)sender {
	NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
	if (![controller inWebspose]) {
		[dic setObject:[findField stringValue] forKey:@"searchString"];
		[dic setObject:[NSNumber numberWithInt:[caseSensitive state]] forKey:@"caseSensitive"];
		[dic setObject:[NSNumber numberWithInt:0] forKey:@"backwards"];
	} else {
		[dic setObject:[websposeFindField stringValue] forKey:@"searchString"];
		[dic setObject:[NSNumber numberWithInt:[webposeCaseSensitive state]] forKey:@"caseSensitive"];
		[dic setObject:[NSNumber numberWithInt:0] forKey:@"backwards"];
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"DBWebSearch"
														object:self
													  userInfo:dic];
	[dic release];
}

- (IBAction)findPreviousText:(id)sender {
	NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
	if (![controller inWebspose]) {
		[dic setObject:[findField stringValue] forKey:@"searchString"];
		[dic setObject:[NSNumber numberWithInt:[caseSensitive state]] forKey:@"caseSensitive"];
		[dic setObject:[NSNumber numberWithInt:1] forKey:@"backwards"];
	} else {
		[dic setObject:[websposeFindField stringValue] forKey:@"searchString"];
		[dic setObject:[NSNumber numberWithInt:[webposeCaseSensitive state]] forKey:@"caseSensitive"];
		[dic setObject:[NSNumber numberWithInt:1] forKey:@"backwards"];
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"DBWebSearch"
														object:self
													  userInfo:dic];
	[dic release];
}

- (IBAction)toggleFinding:(id)sender {
	NSString *_title = [[NSApp keyWindow] title];
	if (![_title isEqualToString:@"SlideBrowser"] && ![_title isEqualToString:@"Webspose"]) {
		// TODO: make the standard find panel appear
		// (this was written to allow for finding in the view source window)
		return;
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:@"DBToggleSplitView"
														object:self];
	// switch the finding control visibility 
	if (![controller inWebspose]) {
		switch (hidden) {
			case YES:
				hidden = NO;
				[findLabel setHidden:NO];
				[findField setHidden:NO];
				[caseSensitive setHidden:NO];
				[findField selectText:self];
				break;
			case NO:
				hidden = YES;
				[findLabel setHidden:YES];
				[findField setHidden:YES];
				[caseSensitive setHidden:YES];
				break;
		}
	} else {
		switch (wHidden) {
			case YES:
				wHidden = NO;
				[websposeFindLabel setHidden:NO];
				[websposeFindField setHidden:NO];
				[webposeCaseSensitive setHidden:NO];
				[websposeFindField selectText:self];
				break;
			case NO:
				wHidden = YES;
				[websposeFindLabel setHidden:YES];
				[websposeFindField setHidden:YES];
				[webposeCaseSensitive setHidden:YES];
				break;
		}
	}
}

@end
