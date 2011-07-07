//
//  PropertiesPostsTypesOutlineViewDragAndDropController.h
//  Ges
//
//  Created by NeoJF on 12/11/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "DocumentPropertiesConstants.h"
#import "ModelConstants.h"
#import "PasteboardTypes.h"
#import "NSTreeController_Extensions.h"

#import "DocumentPropertiesController.h"

#ifndef BENCHMARK_ALL
#endif

#ifndef TRACE_ALL
#define PROPERTIES_POSTS_TYPES_OUTLINE_VIEW_DRAG_AND_DROP_CONTROLLER_TRACE
#endif


@interface PropertiesPostsTypesOutlineViewDragAndDropController : NSObject {
	IBOutlet DocumentPropertiesController	*documentPropertiesController;
	IBOutlet NSOutlineView					*postsTypesOutlineView;
	IBOutlet NSTreeController				*postsTypesTreeController;
}

// Datasource
- (int)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item;
- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item;
- (id)outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item;
- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item;

// Drag'n'drop management
- (BOOL)outlineView:(NSOutlineView *)outlineView acceptDrop:(id <NSDraggingInfo>)info item:(id)item childIndex:(int)index;
- (NSDragOperation)outlineView:(NSOutlineView *)outlineView validateDrop:(id <NSDraggingInfo>)info proposedItem:(id)item proposedChildIndex:(int)index;
- (BOOL)outlineView:(NSOutlineView *)outlineView writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pboard;

@property (retain) DocumentPropertiesController	*documentPropertiesController;
@property (retain) NSOutlineView					*postsTypesOutlineView;
@property (retain) NSTreeController				*postsTypesTreeController;
@end

void moveType(NSManagedObjectContext *moc, int destTypePriority, NSManagedObject *sourceType, NSManagedObject *destPost);
