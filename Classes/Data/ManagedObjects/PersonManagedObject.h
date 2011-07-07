//
//  PersonManagedObject.h
//  Ges
//
//  Created by Romain Champourlier on 12/04/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DebugDefines.h"
#import "NotificationConstants.h"
#import "PrioritizedManagedObject.h"

#ifndef TRACE_ALL_L2
#define PERSON_MANAGED_OBJECT_TRACE_METHODS
#endif

#ifndef TRACE_ALL_L3
#define PERSON_MANAGED_OBJECT_TRACE_NOTIFICATIONS
#endif


static BOOL PersonMOPostingFilterStateModifiedNotification = YES;

@interface PersonManagedObject : PrioritizedManagedObject {
}

- (void)setFilterState:(NSNumber *)filterState;

+ (void)startPostingFilterStateModifiedNotification;
+ (void)stopPostingFilterStateModifiedNotification;

@end
