//
//  SourceListGroupCell.h
//  SourceList
//
//  Created by Mark Alldritt on 07/09/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SourceListCell.h"

//#define SOURCE_LIST_GROUP_CELL_DRAWING

@interface SourceListGroupCell : SourceListCell {
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;

@end
