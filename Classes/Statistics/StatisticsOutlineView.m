//
//  StatisticsOutlineView.m
//  Ges
//
//  Created by Romain Champourlier on 06/02/09.
//  Copyright 2009 Galilée Conseil & Technologies. All rights reserved.
//

#import "StatisticsOutlineView.h"

/**
 Simple subclass of NSOutlineView.
 Add the following behaviors:
	- mouseDown: handles tracking of the cells for any cell type, not only NSButtonCell subclasses.
 */

@implementation StatisticsOutlineView

/*- (void)mouseDown:(NSEvent *)theEvent {
	NSPoint eventLocation = [theEvent locationInWindow];
	NSPoint localPoint = [self convertPoint:eventLocation fromView:nil];
	
	NSInteger clickedRow = [self rowAtPoint:localPoint];
	NSInteger clickedColumn = [self columnAtPoint:localPoint];
	
	NSTableColumn *outlineTableColumn = [self outlineTableColumn];
	float outlineColumnWidth = outlineTableColumn.width;
	
	id item = [self itemAtRow:clickedRow];
	
	NSRect frameOfOutlineCell = [self frameOfOutlineCellAtRow:clickedRow];
	BOOL didClickInOutlineCellFrame = CGRectContainsPoint(CGRectMake(frameOfOutlineCell.origin.x, frameOfOutlineCell.origin.y, frameOfOutlineCell.size.width,frameOfOutlineCell.size.height), CGPointMake(localPoint.x, localPoint.y));
	
	if (didClickInOutlineCellFrame) {
		// Mouse click occured in the expanding arrow area
		if ([self isExpandable:item]) {
			if ([self isItemExpanded:item]) {
				[self collapseItem:item];
			}
			else {
				[self expandItem:item];
			}
		}
	}
	else {
		NSCell *targetCell = [[[self tableColumns] objectAtIndex:clickedColumn] dataCell];
		if (clickedRow != -1 && clickedColumn != -1) {
			[targetCell trackMouse:theEvent inRect:[self frameOfCellAtColumn:clickedColumn row:clickedRow] ofView:self untilMouseUp:YES];
		}
	}		
}*/

- (IBAction)delete:(id)sender {
	printf("IN  [StatisticsOutlineView delete:]\n");
	
	[statisticsViewController delete];
	
	printf("OUT [StatisticsOutlineView delete:]\n");
}

@end
