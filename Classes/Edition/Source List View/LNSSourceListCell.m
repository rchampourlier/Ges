//
//  LNSSourceListCell.m
//  SourceList
//
//  Created by Mark Alldritt on 07/09/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "LNSSourceListCell.h"
#import "LNSSourceListView.h"


@implementation LNSSourceListCell

#pragma mark -
#pragma mark === Life cycle ===

- (id)init {
#ifdef LNSSOURCE_LIST_CELL_LIFE_CYCLE
	printf("IN  [LNSSourceListCell init] ");
#endif
	
	self = [super init];
	
	if (self != nil) {
		mouseIsOver = NO;
		hasTrackingArea = NO;
		imageSize.width = 0;
		imageSize.height = 0;
	}
	
#ifdef LNSSOURCE_LIST_CELL_LIFE_CYCLE
	printf("OUT [LNSSourceListCell init] cell=%p\n", self);
#endif	
	return self;
}

- (id)copyWithZone:(NSZone *)zone {
#ifdef LNSSOURCE_LIST_CELL_LIFE_CYCLE
	printf("IN  [LNSSourceListCell copyWithZone:] src=%p ", self);
#endif

	LNSSourceListCell* newCell = [super copyWithZone:zone];
	
#ifdef LNSSOURCE_LIST_CELL_LIFE_CYCLE
	printf("cpy=%p\n", newCell);
#endif
	
	[newCell->mValue retain];
	newCell->hasTrackingArea = hasTrackingArea;
	
#ifdef LNSSOURCE_LIST_CELL_LIFE_CYCLE
	printf("OUT [LNSSourceListCell copyWithZone:] src=%p cpy=%p\n", self, newCell);
#endif
	
	return newCell;
}

- (void)dealloc {
#ifdef LNSSOURCE_LIST_CELL_LIFE_CYCLE
	printf("IN  [LNSSourceListCell dealloc] cell=%p\n", self);
#endif
	
	[mValue release];
	[super dealloc];
}

#pragma mark -
#pragma mark === Accessors ===

- (NSDictionary *)objectValue {
	return [[mValue retain] autorelease];
}

// TODO NOW! Should be verified!!!
- (void)setObjectValue:(id)value {
	if (![mValue isKindOfClass:[NSDictionary class]]) {
		[super setObjectValue:value];
	}
	
	if (mValue != value) {
		[mValue release];
		mValue = [value retain];
	}
}

#pragma mark -
#pragma mark === Display ===

- (NSColor *)highlightColorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	//	The table view does the highlighting.  Returning nil seems to stop the cell from
	//	attempting th highlight the row.
	return nil;
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
#ifdef LNSSOURCE_LIST_CELL_DRAWING
	printf("[LNSSourceListCell drawInteriorWithFrame:inView:]\n");
#endif
		   
	NSParameterAssert([controlView isKindOfClass:[LNSSourceListView class]]);
	
	NSFontManager* fontManager = [NSFontManager sharedFontManager];
	NSString* title = [mValue objectForKey:@"name"];
	NSMutableDictionary *attrs = [NSMutableDictionary dictionaryWithDictionary:[[self attributedStringValue] attributesAtIndex:0 effectiveRange:NULL]];
	NSFont* font = [attrs objectForKey:NSFontAttributeName];

	if (imageSize.width == 0) {
		imageSize = [title sizeWithAttributes:attrs];
		imageSize.width = imageSize.height;
	}
	
	float x = cellFrame.origin.x + 3;
	float y = cellFrame.origin.y + imageSize.height + (NSHeight(cellFrame) - imageSize.height) / 2.0;

	NSNumber *filterState = [mValue objectForKey:@"filterState"];
	NSImage *cellImage;
	if ([[mValue objectForKey:@"priority"] intValue] == -1) {
		// Allows specificities for the "All..." items
		[attrs setValue:[fontManager convertFont:font toHaveTrait:NSBoldFontMask] forKey:NSFontAttributeName];
		cellImage = [NSImage imageNamed:@"table_multiple_b&w"];
	}
	else {
		if (mouseIsOver && filterState != nil) {
			int filterStateInt = [filterState intValue];
			if (filterStateInt == 1) {
				cellImage = [NSImage imageNamed:@"table_minus"];
			}
			else {
				cellImage = [NSImage imageNamed:@"table_plus"];
			}
		}
		else {
			if ([[mValue valueForKey:@"category"] isEqualToString:@"post"]) {
				cellImage = [NSImage imageNamed:@"table_multiple"];
			}
			else {
				cellImage = [NSImage imageNamed:@"table"];
			}
		}
	}
	
	float fraction;
	if (filterState != nil) {
		int filterStateInt = [filterState intValue];
		if (filterStateInt == 0) {
			fraction = 0.33;
		}
		else {
			if (filterStateInt == 1) {
				fraction = 1;
			}
			else {
				fraction = 1;
			}
		}
	}
	else {
		fraction = 1;
	}
	[attrs setValue:[NSColor colorWithDeviceWhite:0.0 alpha:fraction] forKey:NSForegroundColorAttributeName];
	
	[cellImage setScalesWhenResized:YES];
	[cellImage setSize:imageSize];
	[controlView lockFocus];
	[cellImage compositeToPoint:NSMakePoint(x, y) operation:NSCompositeSourceOver fraction:fraction];
	[controlView unlockFocus];
	
	// TODO: redefine cellImageFrame in order to have it set before the cell is drawn. Do it instead when the setObject is done
	cellImageFrame.origin.x = x;
	cellImageFrame.origin.y = y;
	cellImageFrame.size.width = imageSize.width;
	cellImageFrame.size.height = imageSize.height;

	NSWindow* window = [controlView window];

	BOOL windowIsFront = [window firstResponder] == controlView && [window isMainWindow] && [window isKeyWindow];

	if ([self isHighlighted]) {
		[attrs setValue:[fontManager convertFont:font toHaveTrait:NSBoldFontMask] forKey:NSFontAttributeName];
		[attrs setValue:[NSColor darkGrayColor] forKey:NSForegroundColorAttributeName];
	}

	NSSize titleSize = [title sizeWithAttributes:attrs];
	NSRect inset = cellFrame;
	
	inset.size.height = titleSize.height;
	inset.origin.y = NSMinY(cellFrame) + (NSHeight(cellFrame) - titleSize.height) / 2.0;
	inset.origin.x += 1.5 * imageSize.width;
	[title drawInRect:inset withAttributes:attrs];

	if (kSourceList_NumbersAppearance && windowIsFront && [self isHighlighted]) {
		[attrs setValue:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
		[title drawInRect:inset withAttributes:attrs];
	}
	//printf("DIF cellImageFrame=(%.0f, %.0f), %.0fx%.0f\n", cellImageFrame.origin.x, cellImageFrame.origin.y, cellImageFrame.size.width, cellImageFrame.size.height);
	
#ifdef LNSSOURCE_LIST_CELL_DRAWING
	printf("[LNSSourceListCell drawInteriorWithFrame:inView:] END\n");
#endif
}


#pragma mark -
#pragma mark === Mouse events tracking ===

- (void)setMouseIsOver:(BOOL)isOver {
	//printf("setMouseIsOver:%d\n", isOver);
	mouseIsOver = isOver;
}

#pragma mark -
#pragma mark === Accessors ===

- (NSString *)representedCategory {
	return [mValue valueForKey:@"category"];
}

- (int)representedPriority {
	return [[mValue valueForKey:@"priority"] intValue];
}

- (int)representedPostPriority {
	if ([[mValue valueForKey:@"category"] isEqualToString:@"type"]) {
		return [[mValue valueForKey:@"postPriority"] intValue];
	}
	else return -1;
}

@synthesize mouseIsOver;
@synthesize hasTrackingArea;
@synthesize imageSize;

@end
