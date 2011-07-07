#import "SourceListView.h"
#import "SourceListCell.h"

/**
 * SourceListView.m
 *
 * Source list view should be bound to a tree controller containing NSDictionary instances
 * with the following entries:
 *  - "contentDictionary":	dictionary (mutable, or not), containing the main attributes
 *							of the cell to be displayed:
 *								- "title": the title that should be displayed by the cell,
 *								- "imageName":	the name of the image that should be displayed
 *												by the cell (if no image name is specified, the
 *												cell will display no image),
 *	- "isSourceGroup": a BOOL indicating if the displayed is a group cell, or not.
 *
 * Implementation guide:
 *	1.	Instantiate a NSOutlineView in IB and set the class to: SourceListView.
 *	2.	Set corresponding classes for the NSTableColumn and NSCell entities within the
 *		outline view.
 *	3.	Bind the source list's "content" to the tree controller's "arrangedObjects".
 *  4.	Bind the column's "value" to the property containing data of the tree's managed object.
 */

@interface SourceListView (Private)

- (BOOL)_itemIsSourceGroup:(id)item;

@end

@implementation SourceListView (Private)

- (BOOL)_itemIsSourceGroup:(id)item {
#ifdef SOURCE_LIST_VIEW_TRACE_METHODS
	printf("IN  [SourceListView _itemIsSourceGroup:]\n");
#endif
	
	NSDictionary* value = [item observedObject];
	
#ifdef SOURCE_LIST_VIEW_TRACE_METHODS_END
	printf("OUT [SourceListView _itemIsSourceGroup:]\n");
#endif

	return [[value objectForKey:@"isSourceGroup"] boolValue];
}

@end


@implementation SourceListView

#pragma mark -
#pragma mark === Life cycle ===

- (void)awakeFromNib {
#ifdef SOURCE_LIST_VIEW_TRACE_METHODS
	printf("IN  [SourceListView awakeFromNib]\n");
#endif

	[self setDelegate:self];
	
#ifdef SOURCE_LIST_VIEW_TRACE_METHODS_END
	printf("OUT [SourceListView awakeFromNib]\n");
#endif	
}

#pragma mark -
#pragma mark === Delegate methods ===

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item {
#ifdef SOURCE_LIST_VIEW_TRACE_METHODS
	printf("IN  [SourceListView outlineView:shouldSelectItem:]\n");
#endif

#ifdef SOURCE_LIST_VIEW_TRACE_METHODS_END
	printf("OUT [SourceListView outlineView:shouldSelectItem:]\n");
#endif

	//	Don't allow the user to select Source Groups
	return ![self _itemIsSourceGroup:item];
}

- (float)outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(id)item {
#ifdef SOURCE_LIST_VIEW_TRACE_METHODS
	printf("IN  [SourceListView outlineView:heightOfRowByItem:]\n");
#endif
	
#ifdef SOURCE_LIST_VIEW_TRACE_METHODS_END
	printf("OUT [SourceListView outlineView:heightOfRowByItem:]\n");
#endif
	
	//	Make the height of Source Group items a little higher
	if ([self _itemIsSourceGroup:item]) {
		return [self rowHeight] + 4.0;
	}
	return [self rowHeight];
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
#ifdef SOURCE_LIST_VIEW_TRACE_METHODS
	printf("IN  [SourceListView outlineViewSelectionDidChange:]\n");
#endif
	
	if (mAppearance == kSourceList_NumbersAppearance && [[self selectedRowIndexes] count] > 1) {
		[self setNeedsDisplay:YES];
	}

#ifdef SOURCE_LIST_VIEW_TRACE_METHODS_END
	printf("OUT [SourceListView outlineViewSelectionDidChange:]\n");
#endif
}

- (void)outlineViewSelectionIsChanging:(NSNotification *)notification {
#ifdef SOURCE_LIST_VIEW_TRACE_METHODS
	printf("IN  [SourceListView outlineViewSelectionIsChanging:]\n");
#endif
	
	if (mAppearance == kSourceList_NumbersAppearance && [[self selectedRowIndexes] count] > 1)
		[self setNeedsDisplay:YES];

#ifdef SOURCE_LIST_VIEW_TRACE_METHODS_END
	printf("OUT [SourceListView outlineViewSelectionIsChanging:]\n");
#endif
}


#pragma mark -
#pragma mark === Display ===

- (AppearanceKind)appearance {
#ifdef SOURCE_LIST_VIEW_TRACE_METHODS
	printf("IN  [SourceListView appearance]\n");
#endif
	
#ifdef SOURCE_LIST_VIEW_TRACE_METHODS_END
	printf("OUT [SourceListView appearance]\n");
#endif

	return mAppearance;
}

- (void)setAppearance:(AppearanceKind)newAppearance {
#ifdef SOURCE_LIST_VIEW_TRACE_METHODS
	printf("IN  [SourceListView setAppearance:]\n");
#endif
	
	if (mAppearance != newAppearance) {
		mAppearance = newAppearance;
		[self setNeedsDisplay:YES];
	}

#ifdef SOURCE_LIST_VIEW_TRACE_METHODS_END
	printf("OUT [SourceListView setAppearance:]\n");
#endif	
}

- (void)highlightSelectionInClipRect:(NSRect)clipRect {
#ifdef SOURCE_LIST_VIEW_DRAWING
	printf("IN  [SourceListView highlightSelectionInClipRect:(%.0f,%.0f) %.0fx%.0f]\n", clipRect.origin.x, clipRect.origin.y, clipRect.size.width, clipRect.size.height);
#endif	

	switch (mAppearance) {
		default:
		case kSourceList_iTunesAppearance:
		{
			//	This code is cribbed from iTableTextCell.... and draws the highlight for the selected
			//	cell.
			
			NSRange rows = [self rowsInRect:clipRect];
			unsigned maxRow = NSMaxRange(rows);
			unsigned row;
			NSImage *gradient;
			
			/* Determine whether we should draw a blue or grey gradient.
			 * We will automatically redraw when our parent view loses/gains focus, 
			 * or when our parent window loses/gains main/key status.
			 */
			if (([[self window] firstResponder] == self) &&
				[[self window] isMainWindow] &&
				[[self window] isKeyWindow]) {
				gradient = [NSImage imageNamed:@"highlight_blue.tiff"];
			}
			else {
				gradient = [NSImage imageNamed:@"highlight_grey.tiff"];
			}
			
			/* Make sure we draw the gradient the correct way up. */
			
			
			[gradient setFlipped:YES];
			
			for (row = rows.location; row < maxRow; ++row)
			{
				if ([self isRowSelected:row])
				{
					NSRect selectRect = [self rectOfRow:row];
					
					if (NSIntersectsRect(selectRect, clipRect))
					{
						int i = 0;
						
						/* We're selected, so draw the gradient background. */
						NSSize gradientSize = [gradient size];
						for (i = selectRect.origin.x; i < (selectRect.origin.x + selectRect.size.width); i += gradientSize.width) {
							[gradient drawInRect:NSMakeRect(i, selectRect.origin.y, gradientSize.width, selectRect.size.height)
										fromRect:NSMakeRect(0, 0, gradientSize.width, gradientSize.height)
									   operation:NSCompositeSourceOver
										fraction:1.0];
						}
					}
				}
			}
		}
			break;
			
		case kSourceList_NumbersAppearance:
		{
			NSRange rows = [self rowsInRect:clipRect];
			unsigned maxRow = NSMaxRange(rows);
			unsigned row, lastSelectedRow = NSNotFound;
			NSColor* highlightColor = nil;
			NSColor* highlightFrameColor = nil;
			
			if ([[self window] firstResponder] == self && 
				[[self window] isMainWindow] &&
				[[self window] isKeyWindow]) {
				highlightColor = [NSColor colorWithCalibratedRed:98.0 / 256.0 green:120.0 / 256.0 blue:156.0 / 256.0 alpha:1.0];
				highlightFrameColor = [NSColor colorWithCalibratedRed:83.0 / 256.0 green:103.0 / 256.0 blue:139.0 / 256.0 alpha:1.0];
			}
			else {
				highlightColor = [NSColor colorWithCalibratedRed:160.0 / 256.0 green:160.0 / 256.0 blue:160.0 / 256.0 alpha:1.0];
				highlightFrameColor = [NSColor colorWithCalibratedRed:150.0 / 256.0 green:150.0 / 256.0 blue:150.0 / 256.0 alpha:1.0];
			}
			
			for (row = rows.location; row < maxRow; ++row) {
				if (lastSelectedRow != NSNotFound && row != lastSelectedRow + 1) {
					NSRect selectRect = [self rectOfRow:lastSelectedRow];
					
					[highlightFrameColor set];
					selectRect.origin.y += NSHeight(selectRect) - 1.0;
					selectRect.size.height = 1.0;
					NSRectFill(selectRect);
					lastSelectedRow = NSNotFound;
				}
				
				if ([self isRowSelected:row]) {
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
			
			if (lastSelectedRow != NSNotFound) {
				NSRect selectRect = [self rectOfRow:lastSelectedRow];
				
				[highlightFrameColor set];
				selectRect.origin.y += NSHeight(selectRect) - 1.0;
				selectRect.size.height = 1.0;
				NSRectFill(selectRect);
				lastSelectedRow = NSNotFound;
			}
		}
			break;
	}

#ifdef SOURCE_LIST_VIEW_DRAWING
	printf("OUT  [SourceListView highlightSelectionInClipRect:(%.0f,%.0f) %.0fx%.0f]\n", clipRect.origin.x, clipRect.origin.y, clipRect.size.width, clipRect.size.height);
#endif	
}

@end
