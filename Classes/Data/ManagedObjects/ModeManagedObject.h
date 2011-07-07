//
//  ModeManagedObject.h
//  Ges
//
//  Created by NeoJF on 16/06/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DebugDefines.h"
#import "NotificationConstants.h"
#import "PrioritizedManagedObject.h"

#ifdef TRACE_ALL_L1
#define MODE_MANAGED_OBJECT_TRACE_METHODS
#endif

#ifdef TRACE_ALL_L2
#define MODE_MANAGED_OBJECT_TRACE_NOTIFICATIONS
#endif

@interface ModeManagedObject : PrioritizedManagedObject {
}

- (void)setFilterState:(NSNumber *)filterState;

@end
