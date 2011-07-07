/* LNSSourceListView */

#import <Cocoa/Cocoa.h>
#import "EditionSelectionSourceListController.h"
#import "LNSSourceListCell.h"

#ifdef TRACE_ALL_L3
#define LNSSOURCE_LIST_VIEW_TRACE_ALL_L3
#endif
#ifdef TRACE_ALL_L4
#define LNSSOURCE_LIST_VIEW_TRACE_ALL_L4
#endif

#ifdef LNSSOURCE_LIST_VIEW_TRACE_ALL_L3
#define LNSSOURCE_LIST_VIEW_TRACE_METHODS
#define LNSSOURCE_LIST_VIEW_TRACE_METHODS_END
#endif

#ifdef LNSSOURCE_LIST_VIEW_TRACE_ALL_L4
#define LNSSOURCE_LIST_VIEW_DRAWING
#endif

typedef enum {
	kSourceList_iTunesAppearance,	// gradient selection backgrounds
	kSourceList_NumbersAppearance	// flat selection backgrounds
} AppearanceKind;


@interface LNSSourceListView : NSOutlineView {
	AppearanceKind	mAppearance;
	
	int lastTrackedRow;
	int rowUnderTheMouse;
	
	IBOutlet EditionSelectionSourceListController	*editionSelectionSourceListController;
}

- (AppearanceKind)appearance;
- (void)setAppearance:(AppearanceKind)newAppearance;

// Delegate methods
- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item;
- (float)outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(id)item;
- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item;
- (void)outlineViewSelectionDidChange:(NSNotification *)notification;
- (void)outlineViewSelectionIsChanging:(NSNotification *)notification;

@property(getter=rowUnderTheMouse, setter=setRowUnderTheMouse:) int rowUnderTheMouse;

@end
