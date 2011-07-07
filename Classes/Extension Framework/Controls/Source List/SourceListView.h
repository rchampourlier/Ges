/* SourceListView */

#import <Cocoa/Cocoa.h>
#import "SourceListCell.h"

//#define SOURCE_LIST_VIEW_TRACE_METHODS
//#define SOURCE_LIST_VIEW_TRACE_METHODS_END
//#define SOURCE_LIST_VIEW_DRAWING

typedef enum {
	kSourceList_iTunesAppearance,	// gradient selection backgrounds
	kSourceList_NumbersAppearance	// flat selection backgrounds
} AppearanceKind;


@interface SourceListView : NSOutlineView {
	AppearanceKind	mAppearance;
}

//- (id)init;

- (AppearanceKind)appearance;
- (void)setAppearance:(AppearanceKind)newAppearance;

// Delegate methods
- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item;
- (float)outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(id)item;
- (void)outlineViewSelectionDidChange:(NSNotification *)notification;
- (void)outlineViewSelectionIsChanging:(NSNotification *)notification;

@end
