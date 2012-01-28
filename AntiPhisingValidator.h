/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/


#import <Cocoa/Cocoa.h>


@interface AntiPhisingValidator : NSObject {

}

- (IBAction)menuHandler:(id)sender;
+ (BOOL)validateLink:(NSURL *)urlLink;

@end
