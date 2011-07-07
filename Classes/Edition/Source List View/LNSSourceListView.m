#import "LNSSourceListView.h"
#import "LNSSourceListCell.h"

/**
 * TODO: should subclass SourceListView, as well as other required classes.
 */

@interface LNSSourceListView (Private)

- (BOOL)_itemIsSourceGroup:(id)item;

@end

@implementation LNSSourceListView (Private)

- (BOOL)_itemIsSourceGroup:(id)item {
	NSDictionary* value = [item observedObject];

	return [[value objectForKey:@"isSourceGroup"] boolValue];
}

@end
 

@implementation LNSSourceListView

- (void)mouseEntered:(NSEvent *)theEvent {
	NSDictionary *userInfo = [[theEvent trackingArea] userInfo];
	rowUnderTheMouse = [[userInfo objectForKey:@"row"] intValue];

	//printf("mouseEntered in row\n", rowUnderTheMouse);
	[self setNeedsDisplayInRect:[self frameOfCellAtColumn:0 row:[[userInfo objectForKey:@"row"] intValue]]];
}

- (void)mouseExited:(NSEvent *)theEvent {
	NSDictionary *userInfo = [[theEvent trackingArea] userInfo];
	//printf("mouseExited from row\n", rowUnderTheMouse);
	rowUnderTheMouse = -1;
	
	[self setNeedsDisplayInRect:[self frameOfCellAtColumn:0 row:[[userInfo objectForKey:@"row"] intValue]]];
}

/**
 * Default implementation calls [NSOutlineView outlineView:shouldTrackCell:forTableColumn:item].
 * This implementation voluntary do nothing.
 */
- (void)mouseDown:(NSEvent *)theEvent {
#ifdef LNSSOURCE_LIST_VIEW_TRACE_METHODS
	printf("IN  [LNSSourceListView mouseDown:]\n");
#endif
	
	return;
	
#ifdef LNSSOURCE_LIST_VIEW_TRACE_METHODS_END
	printf("OUT [LNSSourceListView mouseDown:]\n");
#endif	
}

- (void)mouseUp:(NSEvent *)theEvent {
#ifdef LNSSOURCE_LIST_VIEW_TRACE_METHODS
	printf("IN  [LNSSourceListView mouseUp:]\n");
#endif
	
	NSPoint eventLocation = [theEvent locationInWindow];
	NSPoint localPoint = [self convertPoint:eventLocation fromView:nil];
	
	int clickedRow = [self rowAtPoint:localPoint];
	
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
		NSSize imageSize = [[outlineTableColumn dataCellForRow:clickedRow] imageSize];
		int imageRangeXOffset = ((int)[self indentationPerLevel]) * ([self levelForRow:clickedRow] + 1) + 6;
		BOOL isInImageRange = localPoint.x >= imageRangeXOffset && localPoint.x < imageRangeXOffset + imageSize.width;
		
		// TODO: remove sourceList_cellArea enum type from source
		if (isInImageRange) {
			// Mouse click occured in the item's image area
			[editionSelectionSourceListController mouseClickedImageAreaOfItem:item];
		}
		
		else {
			// Mouse click occured in the cell's "standard" area
			[editionSelectionSourceListController mouseClickedTitleAreaOfItem:item];
		}
	}
		
#ifdef LNSSOURCE_LIST_VIEW_TRACE_METHODS_END
	printf("OUT [LNSSourceListView mouseUp:]\n");
#endif	
}

#pragma mark -
#pragma mark === Life cycle ===

- (id)init {
#ifdef LNSSOURCE_LIST_VIEW_TRACE_METHODS
	printf("[LNSSourceListView init]\n");
#endif
	
	self = [super init];
	if (self != nil) {
		lastTrackedRow = -1;
		rowUnderTheMouse = -1;
	}
	
	return self;
}

- (void)awakeFromNib {
	[self setDelegate:self];
}

#pragma mark -
#pragma mark === Delegate methods ===

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item {
	//	Don't allow the user to select Source Groups
	return ![self _itemIsSourceGroup:item];
}

- (float)outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(id)item {
	//	Make the height of Source Group items a little higher
	if ([self _itemIsSourceGroup:item]) {
		return [self rowHeight] + 4.0;
	}
	return [self rowHeight];
}

/**
 * The mouseEntered: and mouseExited: methods set the rowUnderTheMouse value. This
 * allows this methods to detect if the cell which will be displayed is under the
 * mouse, or not, and adapt its way of drawing itself consequently.
 *
 * TODO: Add a timer in order to redraw the cell only if the mouse stands a little
 * time on the cell.
 */
- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item {
#ifdef LNSSOURCE_LIST_VIEW_DRAWING
	printf("IN  [LNSSourceListView outlineView:willDisplayCell:forTableColumn:item:] cell=%p\n", cell);
#endif
	
	int numberOfRows = [self numberOfRows];
	while (lastTrackedRow < numberOfRows) {
		NSRect frame = [self frameOfCellAtColumn:0 row:lastTrackedRow];
		NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:lastTrackedRow], @"row", nil];
		NSTrackingArea *trackingArea = [[NSTrackingArea alloc] initWithRect:frame options:(NSTrackingMouseEnteredAndExited | NSTrackingActiveInKeyWindow) owner:self userInfo:userInfo];
		[self addTrackingArea:trackingArea];
		lastTrackedRow++;
	}
	
	if (rowUnderTheMouse == [self rowForItem:item]) {
		[cell setMouseIsOver:YES];
	}
	else {
		[cell setMouseIsOver:NO];
	}
	
#ifdef LNSSOURCE_LIST_VIEW_DRAWING
	printf("OUT [LNSSourceListView outlineView:willDisplayCell:forTableColumn:item:]\n");
#endif	
}


- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
	if (mAppearance == kSourceList_NumbersAppearance && [[self selectedRowIndexes] count] > 1)
		[self setNeedsDisplay:YES];
}

- (void)outlineViewSelectionIsChanging:(NSNotification *)notification {
	if (mAppearance == kSourceList_NumbersAppearance && [[self selectedRowIndexes] count] > 1)
		[self setNeedsDisplay:YES];
}


#pragma mark -
#pragma mark === Display ===

- (AppearanceKind)appearance {
	return mAppearance;
}

- (void)setAppearance:(AppearanceKind)newAppearance {
	if (mAppearance != newAppearance) {
		mAppearance = newAppearance;
		[self setNeedsDisplay:YES];
	}
}

- (void)highlightSelectionInClipRect:(NSRect)clipRect {
	NSRange rows = [self rowsInRect:clipRect];
	unsigned maxRow = NSMaxRange(rows);
	unsigned row, lastSelectedRow = NSNotFound;
	NSColor* highlightColor = nil;
	NSColor* highlightFrameColor = nil;

	if ([[self window] firstResponder] == self && 
		[[self window] isMainWindow] &&
		[[self window] isKeyWindow])
	{
		highlightColor = [NSColor colorWithCalibratedRed:98.0 / 256.0 green:120.0 / 256.0 blue:156.0 / 256.0 alpha:1.0];
		highlightFrameColor = [NSColor colorWithCalibratedRed:83.0 / 256.0 green:103.0 / 256.0 blue:139.0 / 256.0 alpha:1.0];
	}
	else
	{
		highlightColor = [NSColor colorWithCalibratedRed:160.0 / 256.0 green:160.0 / 256.0 blue:160.0 / 256.0 alpha:1.0];
		highlightFrameColor = [NSColor colorWithCalibratedRed:150.0 / 256.0 green:150.0 / 256.0 blue:150.0 / 256.0 alpha:1.0];
	}

	for (row = rows.location; row < maxRow; ++row)
	{
		if (lastSelectedRow != NSNotFound && row != lastSelectedRow + 1)
		{
			NSRect selectRect = [self rectOfRow:lastSelectedRow];
			
			[highlightFrameColor set];
			selectRect.origin.y += NSHeight(selectRect) - 1.0;
			selectRect.size.height = 1.0;
			NSRectFill(selectRect);
			lastSelectedRow = NSNotFound;
		}
		
		if ([self isRowSelected:row])
		{
			NSRect selectRect = [self rectOfRow:row];

			if (NSIntersectsRect(selectRect, clipRect))
			{
				[highlightColor set];
				NSRectFill(selectRect);
				
				if (row != lastSelectedRow + 1)
				{
					selectRect.size.height = 1.0;
					[highlightFrameColor set];
					NSRectFill(selectRect);
				}
			}

			lastSelectedRow = row;
		}
	}

	if (lastSelectedRow != NSNotFound)
	{
		NSRect selectRect = [self rectOfRow:lastSelectedRow];
		
		[highlightFrameColor set];
		selectRect.origin.y += NSHeight(selectRect) - 1.0;
		selectRect.size.height = 1.0;
		NSRectFill(selectRect);
		lastSelectedRow = NSNotFound;
	}
}

@synthesize rowUnderTheMouse;

@end
