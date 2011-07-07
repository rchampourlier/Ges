//
//  StatisticsCell.m
//  Ges
//
//  Created by Romain Champourlier on 04/05/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "StatisticsCell.h"

@interface StatisticsCell (PrivateMethods)
- (NSRect)checkboxFrameInCellFrame:(NSRect)cellFrame;
@end

@implementation StatisticsCell

+ (void)initialize {
	imageSize.width = 10;
	imageSize.height = imageSize.width;
	checkedImage = [NSImage imageNamed:@"checkbox-checked"];
	uncheckedImage = [NSImage imageNamed:@"checkbox-unchecked"];
	mixedImage = [NSImage imageNamed:@"checkbox-mixed"];
}

- (id)init {
//	printf("[StatisticsCell init]\n");
	
	self = [super init];
	if (self != nil) {
	}
	
	return self;
}

/*- (id)initTextCell:(NSString *)aString {
#ifdef STATISTICS_TEXT_FIELD_TRACE_METHODS
	printf("IN  [StatisticsCell initTextCell:%s]\n", [aString cStringUsingEncoding:NSUTF8StringEncoding]);
#endif
	
	self = [super initTextCell:aString];
	if (self != nil) {
	}
	
#ifdef STATISTICS_TEXT_FIELD_TRACE_METHODS
	printf("OUT [StatisticsCell initTextCell:]\n");
#endif
	return self;
}*/

- (void)setObjectValue:(id)object {
	//printf("IN  [StatisticsCell(%p) setObjectValue:]\n", self);

	if (object != nil) {
		if ([object class] == [StatisticsCellData class]) {
			data = object;
			//printf("[StatisticsCellData setObjectValue: isTitle=%s isParent=%s title=%s value=%s]\n", [value isTitleCell] ? "YES" : "NO", [value isParentCell] ? "YES" : "NO", [value isTitleCell] ? [[value title] cStringUsingEncoding:NSUTF8StringEncoding] : "N/A", [value isTitleCell] ? "N/A" : [[NSString stringWithFormat:@"%@", [value value]] cStringUsingEncoding:NSUTF8StringEncoding]);
			if ([data isParentCell]) {
				[self setFont:[NSFont boldSystemFontOfSize:[[self font] pointSize]]];
				[self setTextColor:[NSColor blackColor]];
			}
			else {
				[self setFont:[NSFont systemFontOfSize:[[self font] pointSize]]];
				[self setTextColor:[NSColor colorWithDeviceWhite:0.30 alpha:1.0]];
			}
			if ([data isTitleCell]) {
				[super setObjectValue:[data title]];
				//printf("%s\n", [[value title] CSTRING]);
			}
			else {
				NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
				[currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
				
				[super setObjectValue:[currencyFormatter stringFromNumber:[data value]]];
				//printf("%.2f\n", [[value value] floatValue]);
			}
			//printf("[StatisticsCellData setObjectValue: isTitle=%s isParent=%s title=%s value=%s] END\n", [value isTitleCell] ? "YES" : "NO", [value isParentCell] ? "YES" : "NO", [value isTitleCell] ? [[value title] cStringUsingEncoding:NSUTF8StringEncoding] : "N/A", [value isTitleCell] ? "N/A" : [[[value value] stringValue] cStringUsingEncoding:NSUTF8StringEncoding]);
		}
		else {
			//printf("StatisticsCellData setObjectValue:%s\n", [object cStringUsingEncoding:NSUTF8StringEncoding]);
			[super setObjectValue:object];
		}
	}
	else {
		//printf("\n");
	}
	
	//printf("OUT [StatisticsCell(%p) setObjectValue:]\n", self);
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
//#ifdef SOURCE_LIST_CELL_DRAWING
	//printf("IN  [StatisticsCell drawInteriorWithFrame:inView:] ", self);
//#endif

	/*if ([data isTitleCell]) {
		NSImage *cellImage = nil;
		if ([data includedInStatisticsTotalState] != IncludedInStatisticsTotalNA) {
			if ([data includedInStatisticsTotalState] == IncludedInStatisticsTotalYes) {
				cellImage = checkedImage;
			}
			else if ([data includedInStatisticsTotalState] == IncludedInStatisticsTotalNo) {
				cellImage = uncheckedImage;
			}
			else {
				// State = mixed
				cellImage = mixedImage;
			}
			
			[cellImage setScalesWhenResized:YES];
			[cellImage setSize:imageSize];
			[controlView lockFocus];
			NSPoint compositePoint = [self checkboxFrameInCellFrame:cellFrame].origin;
			compositePoint.y += imageSize.height;
			[cellImage compositeToPoint:compositePoint operation:NSCompositeSourceOver fraction:1];
			[controlView unlockFocus];
		}
	}*/
	
	[super drawInteriorWithFrame:cellFrame inView:controlView];	
//#ifdef SOURCE_LIST_CELL_DRAWING
	//printf("OUT [StatisticsCell drawInteriorWithFrame:inView:]\n");
//#endif
}

- (BOOL)trackMouse:(NSEvent *)theEvent inRect:(NSRect)cellFrame ofView:(NSView *)controlView untilMouseUp:(BOOL)untilMouseUp {
	printf("IN  [StatisticsCell trackMouse:inRect:(%.0f, %.0f) %.0fx%.0f]\n", cellFrame.origin.x, cellFrame.origin.y, cellFrame.size.width, cellFrame.size.height);

	NSPoint currentPoint = [theEvent locationInWindow];
	currentPoint = [controlView convertPoint:currentPoint fromView:nil];
	printf("currentPoint: (%.0f, %.0f)\n", currentPoint.x, currentPoint.y);
	NSRect cbF = [self checkboxFrameInCellFrame:cellFrame];
	printf("checkboxFrameInCellFrame: (%.0f, %.0f) %.0fx%.0f\n", cbF.origin.x, cbF.origin.y, cbF.size.width, cbF.size.height);
	BOOL result = NO;
	if (CGRectContainsPoint(NSRectToCGRect([self checkboxFrameInCellFrame:cellFrame]), NSPointToCGPoint(currentPoint))) {
		// The event happened within the checkbox' frame.
		NSDate *endDate;
		BOOL done = NO;
		BOOL trackContinously = [self startTrackingAt:currentPoint inView:controlView];
		// catch next mouse-dragged or mouse-up event until timeout
		BOOL mouseIsUp = NO;
		NSEvent *event;
		while (!done) { // loop ...
			NSPoint lastPoint = currentPoint;
			endDate = [NSDate distantFuture];
			event = [NSApp nextEventMatchingMask:(NSLeftMouseUpMask|NSLeftMouseDraggedMask) untilDate:endDate inMode:NSEventTrackingRunLoopMode dequeue:YES];
			if (event) { // mouse event
				currentPoint = [event locationInWindow];
				if (trackContinously) { // send continueTracking.../stopTracking...
					if (![self continueTracking:lastPoint at:currentPoint inView:controlView]) {
						done = YES;
						[self stopTracking:lastPoint at:currentPoint inView:controlView mouseIsUp:mouseIsUp];
					}
					if ([self isContinuous]) {
						[NSApp sendAction:[self action] to:[self target] from:controlView];
					}
				}
				mouseIsUp = ([event type] == NSLeftMouseUp);
				if (mouseIsUp) {
					done = YES;
					[self stopTracking:lastPoint at:currentPoint inView:controlView mouseIsUp:mouseIsUp];
					
					NSTableView *outlineView = (NSTableView *)controlView;
					NSPoint point = [theEvent locationInWindow];
					NSInteger row = [outlineView rowAtPoint:[controlView convertPoint:point fromView:nil]];
					//[outlineView drawRow:row clipRect:cellFrame];
					//[outlineView reloadData];					
					[outlineView setNeedsDisplayInRect:cellFrame];
				}
				if (untilMouseUp) {
					result = mouseIsUp;
				}
				else {
					// check, if the mouse left our cell rect
					result = NSPointInRect([controlView convertPoint:currentPoint fromView:nil], cellFrame);
					if (!result) {
						done = YES;
					}
				}
				if (done && result && ![self isContinuous]) {
					[NSApp sendAction:[self action] to:[self target] from:controlView];
				}
			}
		} // while (!done)
	}
	else {
		result = NO;
	}
	printf("OUT [StatisticsCell trackMouse:inRect:(%.0f, %.0f) %.0fx%.0f]\n", cellFrame.origin.x, cellFrame.origin.y, cellFrame.size.width, cellFrame.size.height);
	return result;
}

- (BOOL)startTrackingAt:(NSPoint)startPoint inView:(NSView *)controlView {
	printf("IN  [StatisticsCell startTrackingAt:inView:]\n");
	//[super startTrackingAt:startPoint inView:controlView];
	printf("OUT [StatisticsCell startTrackingAt:inView:]\n");
	return YES;
}

- (BOOL)continueTracking:(NSPoint)lastPoint at:(NSPoint)currentPoint inView:(NSView *)controlView {
	printf("IN  [StatisticsCell continueTracking:at:inView:]\n");
	//[super continueTracking:lastPoint at:currentPoint inView:controlView];
	printf("OUT [StatisticsCell continueTracking:at:inView:]\n");
	return YES;
}

- (void)stopTracking:(NSPoint)lastPoint at:(NSPoint)stopPoint inView:(NSView *)controlView mouseIsUp:(BOOL)flag {
	printf("IN  [StatisticsCell stopTracking:at:(%.0f, %.0f) inView:mouseIsUp:%s]\n", stopPoint.x, stopPoint.y, flag ? "yes" : "no");
	
	NSTableView *outlineView = (NSTableView *)controlView;
	NSInteger column = [outlineView columnAtPoint:[controlView convertPoint:stopPoint fromView:nil]];
	NSInteger row = [outlineView rowAtPoint:[controlView convertPoint:stopPoint fromView:nil]];
	StatisticsCell *preparedCell = (StatisticsCell *)[outlineView preparedCellAtColumn:column row:row];
	//printf("preparedCell: %s\n", [[preparedCell stringValue] CSTRING]);
	StatisticsCellData *preparedData = [preparedCell data];
	//[preparedData setValue:[NSNumber numberWithBool:![preparedData includedInStatisticsTotalState]] forKey:@"includedInStatisticsTotal"];
	
	printf("OUT [StatisticsCell stopTracking:at:inView:]\n");
}

- (NSRect)checkboxFrameInCellFrame:(NSRect)cellFrame {
	float x = cellFrame.origin.x + cellFrame.size.width - imageSize.width - 3;
	float y = cellFrame.origin.y + /*imageSize.height + */(NSHeight(cellFrame) - imageSize.height) / 2.0;
	NSRect checkboxFrame;
	checkboxFrame.origin.x = x;
	checkboxFrame.origin.y = y;
	checkboxFrame.size = imageSize;
	return checkboxFrame;
}

- (StatisticsCellData *)data {
	return data;
}

@end
