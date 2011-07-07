//
//  LNSSourceListCell.h
//  SourceList
//
//  Created by Mark Alldritt on 07/09/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

//#define LNSSOURCE_LIST_CELL_TRACE_METHODS
//#define LNSSOURCE_LIST_CELL_TRACE_METHODS_END
//#define LNSSOURCE_LIST_CELL_LIFE_CYCLE
//#define LNSSOURCE_LIST_CELL_DRAWING

@interface LNSSourceListCell : NSTextFieldCell {
	NSDictionary*	mValue;
	
	BOOL			mouseIsOver;
	BOOL			hasTrackingArea;
	
	NSSize			imageSize;
	NSRect			cellImageFrame;
}

- (id)init;
- (id)copyWithZone:(NSZone *)zone;

- (NSDictionary *)objectValue;
- (void)setObjectValue:(id)value;
- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;

- (void)setMouseIsOver:(BOOL)isOver;

// Accessors
- (NSString *)representedCategory;
- (int)representedPriority;
- (int)representedPostPriority;

@property (getter=mouseIsOver, setter=setMouseIsOver:) BOOL mouseIsOver;
@property (getter=hasTrackingArea, setter=setHasTrackingArea:) BOOL hasTrackingArea;
@property (getter=imageSize) NSSize imageSize;

@end
