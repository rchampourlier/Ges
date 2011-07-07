//
//  StatisticsCell.h
//  Ges
//
//  Created by Romain Champourlier on 04/05/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DebugDefines.h"
#import "StatisticsCellData.h"

#ifndef TRACE_ALL
#define STATISTICS_TEXT_FIELD_TRACE_METHODS
#endif

static int numberOfCallsInit;
static int numberOfCallsSetObjectValue;
static int numberOfCallsDrawInterior;

static NSImage				*checkedImage;
static NSImage				*uncheckedImage;
static NSImage				*mixedImage;
static NSSize				imageSize;

@interface StatisticsCell : NSTextFieldCell {
	StatisticsCellData	*data;
}

- (void)setObjectValue:(id)object;
- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;
- (StatisticsCellData *)data;

@end
