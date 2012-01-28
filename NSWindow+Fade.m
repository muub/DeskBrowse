/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import "NSWindow+Fade.h"

static NSMutableDictionary *fadeInfo = nil;

@interface NSWindow (FadePrivate)

- (void)fadeInWindow:(NSTimer *)theTimer;
- (void)fadeOutWindow:(NSTimer *)theTimer;

@end

@implementation NSWindow (Fade)

-(void)fadeIn {
	if (!fadeInfo) {
		fadeInfo = [[NSMutableDictionary alloc] init];
	} else {
		if ([(NSString *)[fadeInfo objectForKey:@"status"] isEqualToString:@"inprogress"]) { // check status
			if ([(NSString *)[fadeInfo objectForKey:@"type"] isEqualToString:@"fadeOut"]) {
				NSWindow *target = [fadeInfo objectForKey:@"target"];
				if (self == target) {
					NSTimer *aTimer = (NSTimer *)[fadeInfo objectForKey:@"timer"];
					[aTimer invalidate];
					[aTimer release];
				}
			}
		}
	}
	NSTimer *timer = [[NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(fadeInWindow:) userInfo:nil repeats:YES] retain];
	[fadeInfo setObject:self forKey:@"target"];
	[fadeInfo setObject:timer forKey:@"timer"];
	[fadeInfo setObject:@"fadeIn" forKey:@"type"];
	[fadeInfo setObject:@"inprogress" forKey:@"status"];
}

-(void)fadeOut {
	if (!fadeInfo) {
		fadeInfo = [[NSMutableDictionary alloc] init];
	} else {
		if ([(NSString *)[fadeInfo objectForKey:@"status"] isEqualToString:@"inprogress"]) { // check status
			if ([(NSString *)[fadeInfo objectForKey:@"type"] isEqualToString:@"fadeIn"]) {
				NSWindow *target = [fadeInfo objectForKey:@"target"];
				if (self == target) {
					NSTimer *aTimer = (NSTimer *)[fadeInfo objectForKey:@"timer"];
					[aTimer invalidate];
					[aTimer release];
				}
			}
		}
	}
	NSTimer *timer = [[NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(fadeOutWindow:) userInfo:nil repeats:YES] retain];
	[fadeInfo setObject:self forKey:@"target"];
	[fadeInfo setObject:timer forKey:@"timer"];
	[fadeInfo setObject:@"fadeOut" forKey:@"type"];
	[fadeInfo setObject:@"inprogress" forKey:@"status"];
}

- (void)fadeInWindow:(NSTimer *)theTimer {
	if ([self alphaValue] < 1.0) {
		float av = [self alphaValue];
		[self setAlphaValue:av + 0.2];
	} else {
		[theTimer invalidate];
		[theTimer release];
		[fadeInfo removeObjectForKey:@"target"];
		[fadeInfo removeObjectForKey:@"timer"];
		[fadeInfo setObject:@"" forKey:@"type"];
		[fadeInfo setObject:@"done" forKey:@"status"];
	}
}

- (void)fadeOutWindow:(NSTimer *)theTimer {
	if ([self alphaValue] > 0.0) {
		float av = [self alphaValue];
		[self setAlphaValue:av - 0.2];
	} else {
		[theTimer invalidate];
		[theTimer release];
		[fadeInfo removeObjectForKey:@"target"];
		[fadeInfo removeObjectForKey:@"timer"];
		[fadeInfo setObject:@"" forKey:@"type"];
		[fadeInfo setObject:@"done" forKey:@"status"];
	}
}


@end
