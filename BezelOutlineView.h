/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/


#import <Cocoa/Cocoa.h>

#import "BezelScroller.h"
#import "BezelDataCell.h"
#import "BezelButtonCell.h"


@interface BezelOutlineView : NSOutlineView
{
}

@end

@interface NSOutlineView (SGSAdditions)

- (void) setOutlineCell: (NSButtonCell*) newCell;

@end