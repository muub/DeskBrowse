/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/


#import "AntiPhisingValidator.h"


@implementation AntiPhisingValidator

- (IBAction)menuHandler:(id)sender {
	NSDictionary *dic = [NSDictionary dictionaryWithObject:@"http://www.antiphishing.org/consumer_recs.html" forKey:@"URLString"];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"DBLoadURLNotification"
														object:self
													  userInfo:dic];
}

+ (BOOL)validateLink:(NSURL *)urlLink {
	NSString *u = [urlLink absoluteString];
	return YES;
}

@end
