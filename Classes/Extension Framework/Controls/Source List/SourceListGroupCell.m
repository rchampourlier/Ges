//
//  SourceListSourceGroupCell.m
//  SourceList
//
//  Created by Mark Alldritt on 07/09/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "SourceListGroupCell.h"

//	A source group is the unselectable (grayed out) group at the top of the source list
//	hierarchy.

@implementation SourceListGroupCell

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
#ifdef SOURCE_LIST_GROUP_CELL_DRAWING
	printf("IN  [SourceListGroupCell drawInteriorWithFrame:inView:]\n");
#endif
	
	NSFontManager* fontManager = [NSFontManager sharedFontManager];
	NSFont *font = [self font];
	
	NSMutableDictionary *attrs = [NSMutableDictionary dictionaryWithDictionary:[[self attributedStringValue] attributesAtIndex:0 effectiveRange:NULL]];
	[attrs setObject:font forKey:NSFontAttributeName];

	[attrs setValue:[fontManager convertFont:font toHaveTrait:NSBoldFontMask] forKey:NSFontAttributeName];
	
	NSString* title = [[mValue objectForKey:@"title"] uppercaseString];
	NSSize titleSize = [title sizeWithAttributes:attrs];
	NSRect inset = cellFrame;
	
	inset.size.height = titleSize.height;
	inset.origin.y = NSMinY(cellFrame) + (NSHeight(cellFrame) - titleSize.height) / 2.0;
	inset.origin.x += 3; // Nasty to hard-code this. Can we get it to draw its own content, or determine correct inset?
	inset.origin.y += 1;
		
	inset.origin.y -= 1;
	[attrs setValue:[NSColor darkGrayColor] forKey:NSForegroundColorAttributeName];
	[title drawInRect:inset withAttributes:attrs];

#ifdef SOURCE_LIST_GROUP_CELL_DRAWING
	printf("OUT [SourceListGroupCell drawInteriorWithFrame:inView:]\n");
#endif
}

@end
