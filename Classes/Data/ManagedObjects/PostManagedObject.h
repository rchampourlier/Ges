//
//  PostManagedObject.h
//  Ges
//
//  Created by NeoJF on 11/06/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DebugDefines.h"
#import "NotificationConstants.h"
#import "PrioritizedManagedObject.h"

#ifdef TRACE_ALL_L1
#define POST_MANAGED_OBJECT_TRACE_METHODS
#define POST_MANAGED_OBJECT_TRACE_METHODS_END
#endif

#ifdef TRACE_ALL_L2
#define POST_MANAGED_OBJECT_TRACE_NOTIFICATIONS
#endif

#ifdef TRACE_ALL_L4
#define POST_MANAGED_OBJECT_LIFE_CYCLE
#define POST_MANAGED_OBJECT_LIFE_CYCLE_END
#endif

static BOOL PMOPostingFilterStateModifiedNotification = YES;

@interface PostManagedObject : PrioritizedManagedObject {
	int activeTypesCount;
}

- (id)initWithEntity:(NSEntityDescription *)entity insertIntoManagedObjectContext:(NSManagedObjectContext *)context;
- (void)setFilterState:(NSNumber *)filterState;
- (void)typeChangedFilterStateTo:(int)filterState;

+ (void)startPostingFilterStateModifiedNotification;
+ (void)stopPostingFilterStateModifiedNotification;

@end
