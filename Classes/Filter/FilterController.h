//
//  FilterController.h
//  Ges
//
//  Created by NeoJF on 16/06/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//


#import <Cocoa/Cocoa.h>

#import "DebugDefines.h"
#import "FilterObserver.h"
#import "ModelConstants.h"
#import "NotificationConstants.h"

#import "AccountManagedObject.h"
#import "FilterManagedObject.h"
#import "PostManagedObject.h"
#import "TypeManagedObject.h"

#ifdef TRACE_ALL_L1
#define FILTER_CONTROLLER_TRACE_METHODS
#endif

#ifdef TRACE_ALL_L2
#define FILTER_CONTROLLER_TRACE_EVENTS
#define FILTER_CONTROLLER_TRACE_NOTIFICATIONS
#endif

#ifdef TRACE_ALL_L3
	#define FILTER_CONTROLLER_TRACE_KVO
#endif

@interface FilterController : NSObject {
	
	// Predicates
	NSPredicate		*filterPredicate;
	NSPredicate		*filterObjectPredicate;
	NSPredicate		*periodPredicate;
	NSPredicate		*searchFieldPredicate;
	NSPredicate		*stablePredicate;
	
	BOOL			isFilteringOperations;
	int				filteringOperationsLevel;
	NSNumber		*period;

	/* These variables store the operations parameters which
	 * are to be used for coming new operations.
	 */
	NSManagedObject *newOperationAccount;
	NSManagedObject *newMode;
	NSManagedObject *newOperationPost;
	NSManagedObject *newType;
	
	// IBOutlets
	IBOutlet NSArrayController	*accountsArrayController;
	IBOutlet NSArrayController	*operationsArrayController;
	IBOutlet NSArrayController	*personsArrayController;
	IBOutlet NSTreeController	*postsTypesTreeController;
	IBOutlet NSArrayController	*postsArrayController;
	IBOutlet NSArrayController	*typesArrayController;
	
	// GUI components
	IBOutlet NSTextField		*filterPeriodLabel;
	
	// NEW 2009-04-12
	IBOutlet NSArrayController				*filtersArrayController;
	IBOutlet NSObject <FilterObserver>		*editionSelectionSourceListController;
	FilterManagedObject						*activeFilter;
}

// Life cycle
- (id)init;
- (void)dealloc;
- (void)awakeFromNib;
- (void)addObservers;
- (void)removeObservers;
- (void)managedObjectContextLoaded;

// Notification selectors
- (void)accountFilterStateModified:(NSNotification *)aNotification;
- (void)modeFilterStateModified:(NSNotification *)aNotification;
- (void)typeFilterStateModified:(NSNotification *)aNotification;
- (void)startFilteringOperations:(NSNotification *)aNotification;
- (void)stopFilteringOperations:(NSNotification *)aNotification;

// Accessors
- (NSPredicate *)filterPredicate;
- (NSPredicate *)searchFieldPredicate;
- (void)setSearchFieldPredicate:(NSPredicate *)aPredicate;
- (void)setPeriod:(NSNumber *)number;

// Filter actions
- (void)rearrangeOperations;

// Predicate management
- (NSPredicate *)constructPredicate;
- (void)updateFilterPredicate;
- (void)updatePeriodPredicate;

// Other predicates
- (NSPredicate *)displayedEntityPredicate;

// NEW: Test for active filter
- (BOOL)activeFilterContainsObject:(NSManagedObject *)anObject;

// NEW: Actions on active filter
- (void)inverseObjectStateInActiveFilter:(NSManagedObject *)anObject;
- (void)includeFromSameTypeOnly:(NSManagedObject *)anObject;
- (void)includeAllObjectForEntityName:(NSString *)entityName;

// PrivateMethods
- (NSPredicate *)predicateForFilter:(FilterManagedObject *)filter;


@property (retain)							NSArrayController	*accountsArrayController;
@property (retain)							NSPredicate			*filterPredicate;
@property (retain)							NSManagedObject		*newOperationAccount;
@property (retain)							NSManagedObject		*newMode;
@property (retain)							NSManagedObject		*newOperationPost;
@property (retain)							NSManagedObject		*newType;
@property (retain)							NSArrayController	*operationsArrayController;
@property (retain,setter=setPeriod:)		NSNumber			*period;
@property (retain)							NSPredicate			*searchFieldPredicate;
@property (retain)							NSPredicate			*stablePredicate;
@property (retain)							NSArrayController	*typesArrayController;

@end
