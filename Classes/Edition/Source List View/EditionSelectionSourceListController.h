//
//  EditionSelectionSourceListController.h
//  Ges
//
//  Created by Romain Champourlier on 30/06/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NSTreeController_Extensions.h"

#import "FilterController.h"
#import "FilterObserver.h"
#import "PersonManagedObject.h"
#import "NotificationConstants.h"
#import "SortDescriptorsController.h"

#ifdef TRACE_ALL_L1
#define EDITION_SELECTION_SOURCE_LIST_CONTROLLER_TRACE_METHODS
#define EDITION_SELECTION_SOURCE_LIST_CONTROLLER_TRACE_METHODS_END
#endif
#ifdef TRACE_ALL_L2
#define EDITION_SELECTION_SOURCE_LIST_CONTROLLER_TRACE_NOTIFICATIONS
#endif


@interface EditionSelectionSourceListController : NSObject <FilterObserver> {
	IBOutlet NSArrayController		*accountsArrayController;
	IBOutlet NSArrayController		*accountGroupsArrayController;
	IBOutlet NSArrayController		*personsArrayController;
	IBOutlet NSArrayController		*postsArrayController;
	IBOutlet NSTreeController		*sourceListTreeController;
	IBOutlet NSArrayController		*typesArrayController;
	
	IBOutlet NSOutlineView			*sourceListView;
	
	IBOutlet FilterController		*filterController;
	
	BOOL							dataDidLoad;
	BOOL							filterDidLoad;
}

// Life cycle
- (id)init;
- (void)dealloc;
- (void)addObservers;
- (void)removeObservers;
- (void)dataDidLoad;

// Update methods
- (void)accountFilterStateModified:(NSNotification *)aNotification;
- (void)postFilterStateModified:(NSNotification *)aNotification;
- (void)typeFilterStateModified:(NSNotification *)aNotification;

// Filter observer protocol
- (void)filterDidLoad;
- (void)filterInclude:(NSManagedObject *)object;
- (void)filterExclude:(NSManagedObject *)object;

// Content control
- (void)fillSourceListView;
- (void)expandAccountsSourceItem;

// Respond to user clicks
- (void)mouseClickedImageAreaOfItem:(id)item;
- (void)mouseClickedTitleAreaOfItem:(id)item;

@end
