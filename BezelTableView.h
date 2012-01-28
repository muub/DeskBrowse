/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/


#import <Cocoa/Cocoa.h>

#import "BezelScroller.h"
#import "BezelDataCell.h"


static float kDragImageAlpha = 0.55f;

@interface BezelTableView : NSTableView
{

}

- (void)tableViewDeleteKeyPressed:(NSTableView *)tableView;

@end