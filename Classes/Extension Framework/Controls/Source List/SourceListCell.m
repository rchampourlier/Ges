//
//  SourceListCell.m
//  SourceList
//
//  Created by Mark Alldritt on 07/09/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "SourceListCell.h"
#import "SourceListView.h"


@implementation SourceListCell

#pragma mark -
#pragma mark === Life cycle ===

- (id)init {
#ifdef SOURCE_LIST_CELL_LIFE_CYCLE
	printf("IN  [SourceListCell init]\n");
#endif
	
	self = [super init];
	
	if (self != nil) {
		imageSize.width = 0;
		imageSize.height = 0;
	}
	
#ifdef SOURCE_LIST_CELL_LIFE_CYCLE
	printf("OUT [SourceListCell init]\n", self);
#endif	
	return self;
}

- (id)copyWithZone:(NSZone *)zone {
#ifdef SOURCE_LIST_CELL_LIFE_CYCLE
	printf("IN  [SourceListCell copyWithZone:]\n", self);
#endif
	
	SourceListCell* newCell = [super copyWithZone:zone];
		
	[newCell->mValue retain];
	
#ifdef SOURCE_LIST_CELL_LIFE_CYCLE
	printf("OUT [SourceListCell copyWithZone:]\n", self, newCell);
#endif
	
	return newCell;
}

- (void)dealloc {
#ifdef SOURCE_LIST_CELL_LIFE_CYCLE
	printf("IN  [SourceListCell dealloc]\n", self);
#endif
	
	[mValue release];
	[super dealloc];
}

#pragma mark -
#pragma mark === Accessors ===

- (NSDictionary *)objectValue {
#ifdef SOURCE_LIST_VIEW_TRACE_METHODS
	printf("IN  [SourceListCell objectValue]\n");
#endif

#ifdef SOURCE_LIST_VIEW_TRACE_METHODS_END
	printf("OUT [SourceListCell objectValue]\n");
#endif
		
	return [[mValue retain] autorelease];
}

- (void)setObjectValue:(id)value {
#ifdef SOURCE_LIST_VIEW_TRACE_METHODS
	printf("IN  [%s setObjectValue:]\n", CLASS_NAME_CSTRING);
#endif
	
	if (![value isKindOfClass:[NSDictionary class]] &&
		![value isKindOfClass:[NSMutableDictionary class]]) {
		[super setObjectValue:value];
	}
	else if (mValue != value) {
		[mValue release];
		mValue = [value retain];
	}
	
#ifdef SOURCE_LIST_VIEW_TRACE_METHODS_END
	printf("OUT [%s setObjectValue:]\n", CLASS_NAME_CSTRING);
#endif
}

#pragma mark -
#pragma mark === Display ===

- (NSColor *)highlightColorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
	//	The table view does the highlighting.  Returning nil seems to stop the cell from
	//	attempting th highlight the row.
	return nil;
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
#ifdef SOURCE_LIST_CELL_DRAWING
	printf("IN  [SourceListCell(%s) drawInteriorWithFrame:inView:]\n", [[mValue objectForKey:@"title"] CSTRING]);
#endif
	
	NSParameterAssert([controlView isKindOfClass:[SourceListView class]]);
	
	NSFontManager* fontManager = [NSFontManager sharedFontManager];
	NSFont *font = [self font];
	NSMutableDictionary *attrs = [NSMutableDictionary dictionaryWithDictionary:[[self attributedStringValue] attributesAtIndex:0 effectiveRange:NULL]];
	[attrs setObject:font forKey:NSFontAttributeName];
	
	NSString* title = [mValue objectForKey:@"title"];
	if (imageSize.width == 0) {
		imageSize = [title sizeWithAttributes:attrs];
		imageSize.width = imageSize.height;
	}
	
	float x = cellFrame.origin.x + 3;
	float y = cellFrame.origin.y + imageSize.height + (NSHeight(cellFrame) - imageSize.height) / 2.0;
	
	NSImage *cellImage;
	cellImage = [NSImage imageNamed:@"table"];
	
	[attrs setValue:[NSColor colorWithDeviceWhite:0.0 alpha:1] forKey:NSForegroundColorAttributeName];
	
	[cellImage setScalesWhenResized:YES];
	[cellImage setSize:imageSize];
	[controlView lockFocus];
	//printf("cellImage compositeToPoint:(%.0f,%.0f) fraction:%d\n", x, y, 1);
	[cellImage compositeToPoint:NSMakePoint(x, y) operation:NSCompositeSourceOver fraction:1];
	[controlView unlockFocus];
	
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
	
#ifdef SOURCE_LIST_CELL_DRAWING
	printf("OUT [SourceListCell(%s) drawInteriorWithFrame:inView:]\n", [[mValue objectForKey:@"title"] CSTRING]);
#endif
}

@synthesize imageSize;

@end
