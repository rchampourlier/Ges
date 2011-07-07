//
//  SourceListColumn.m
//  SourceList
//
//  Created by Mark Alldritt on 07/09/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "SourceListColumn.h"
#import "SourceListCell.h"
#import "SourceListGroupCell.h"


@implementation SourceListColumn

- (void)awakeFromNib {
#ifdef SOURCE_LIST_COLUMN_TRACE_METHODS
	printf("IN  [SourceListColumn awakeFromNib]\n");
#endif
	
	SourceListCell* dataCell = [[[SourceListCell alloc] init] autorelease];
	
	[dataCell setFont:[[self dataCell] font]];
	[dataCell setLineBreakMode:[[self dataCell] lineBreakMode]];
	
	[self setDataCell:dataCell];

#ifdef SOURCE_LIST_COLUMN_TRACE_METHODS_END
	printf("OUT [SourceListColumn awakeFromNib]\n");
#endif
	
}

- (id)dataCellForRow:(int)row {
#ifdef SOURCE_LIST_COLUMN_TRACE_METHODS
	printf("IN  [SourceListColumn dataCellForRow:]\n");
#endif
	
	SourceListCell *cell;
	
	if (row >= 0) {
		NSDictionary* value = [[(NSOutlineView*) [self tableView] itemAtRow:row] observedObject];
		
		if ([[value objectForKey:@"isSourceGroup"] boolValue]) {
			SourceListGroupCell *groupCell = [[[SourceListGroupCell alloc] init] autorelease];
			
			[groupCell setFont:[[self dataCell] font]];
			[groupCell setLineBreakMode:[[self dataCell] lineBreakMode]];
			cell = groupCell;			
		}
		else {
			cell = [self dataCell];
		}
	}
	else {
		cell = [self dataCell];
	}
	
	return cell;
}

@end
