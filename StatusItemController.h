/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import <Cocoa/Cocoa.h>


@interface StatusItemController : NSObject {
	id _controller;
	NSStatusItem *_item;
}

- (id)initWithController:(id)controller;
- (NSMenu *)standardMenu;

@end
