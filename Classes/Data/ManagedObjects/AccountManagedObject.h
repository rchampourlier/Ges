//
//  AccountManagedObject.h
//  Ges
//
//  Created by Romain Champourlier on 29/08/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DebugDefines.h"
#import "NotificationConstants.h"
#import "PrioritizedManagedObject.h"

#ifdef TRACE_ALL_L1
#define ACCOUNT_MANAGED_OBJECT_TRACE_ALL_L1
#endif
#ifdef TRACE_ALL_L2
#define ACCOUNT_MANAGED_OBJECT_TRACE_ALL_L2
#endif

#ifdef ACCOUNT_MANAGED_OBJECT_TRACE_ALL_L1
#define ACCOUNT_MANAGED_OBJECT_TRACE_METHODS
#endif
#ifdef ACCOUNT_MANAGED_OBJECT_TRACE_ALL_L2
#define ACCOUNT_MANAGED_OBJECT_TRACE_NOTIFICATIONS
#endif


static BOOL AMOPostingFilterStateModifiedNotification = YES;

@interface AccountManagedObject : PrioritizedManagedObject {
}

- (void)setFilterState:(NSNumber *)filterState;

+ (void)startPostingFilterStateModifiedNotification;
+ (void)stopPostingFilterStateModifiedNotification;

@end
