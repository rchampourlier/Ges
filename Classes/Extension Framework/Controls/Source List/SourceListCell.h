//
//  SourceListCell.h
//  SourceList
//
//  Created by Mark Alldritt on 07/09/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DebugDefines.h"

//#define SOURCE_LIST_CELL_TRACE_METHODS
//#define SOURCE_LIST_CELL_TRACE_METHODS_END
//#define SOURCE_LIST_CELL_LIFE_CYCLE
//#define SOURCE_LIST_CELL_DRAWING

#define CLASS_NAME_CSTRING [[self className] cStringUsingEncoding:NSUTF8StringEncoding]

@interface SourceListCell : NSTextFieldCell {
	NSDictionary*	mValue;
	
	NSSize			imageSize;
	NSRect			cellImageFrame;
}

- (id)init;
- (id)copyWithZone:(NSZone *)zone;

- (NSDictionary *)objectValue;
- (void)setObjectValue:(id)value;
- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;

@property (getter=imageSize) NSSize imageSize;

@end
