//
//  TypeManagedObject.h
//  Ges
//
//  Created by NeoJF on 28/05/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DebugDefines.h"
#import "PostManagedObject.h"
#import "PrioritizedManagedObject.h"
#import "NotificationConstants.h"

#ifdef TRACE_ALL_L1
#define TYPE_MAMAGED_OBJECT_TRACE_METHODS
#define TYPE_MAMAGED_OBJECT_TRACE_METHODS_END
#endif

#ifdef TRACE_ALL_L3
#define TYPE_MAMAGED_OBJECT_TRACE_NOTIFICATIONS
#endif

#ifdef TRACE_ALL_L4
#define TYPE_MANAGED_OBJECT_LIFE_CYCLE
#endif


static BOOL TMOPostingFilterStateModifiedNotification = YES;

@interface TypeManagedObject : PrioritizedManagedObject {
}

- (id)initWithEntity:(NSEntityDescription *)entity insertIntoManagedObjectContext:(NSManagedObjectContext *)context;

- (NSArray *)selectShiftedInstancesFrom:(int)sourcePriority to:(int)destPriority;
- (void)setPost:(NSManagedObject *)post;
- (void)setFilterState:(NSNumber *)filterState;

+ (void)startPostingFilterStateModifiedNotification;
+ (void)stopPostingFilterStateModifiedNotification;

@end
