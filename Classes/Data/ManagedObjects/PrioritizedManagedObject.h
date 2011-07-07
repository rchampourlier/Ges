//
//  PrioritizedManagedObject.h
//  Ges
//
//  Created by NeoJF on 05/05/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DebugDefines.h"
#import "SortDescriptorsController.h"

#ifdef TRACE_ALL_L2
#define PRIORITIZED_MANAGED_OBJECT_TRACE_METHODS
#endif

#ifdef TRACE_ALL_L3
#define PRIORITIZED_MANAGED_OBJECT_TRACE_PRIVATE_METHODS
#define PRIORITIZED_MANAGED_OBJECT_DETAILS
#endif

#define LARGE_NUMBER 9999 // Used to select prioritized managed object, so should be larger than the possible number of such instances in a file

static BOOL priorityShiftingLock = NO;

@interface PrioritizedManagedObject : NSManagedObject {
}

- (void)prepareToRemoval;
- (void)setPriority:(NSNumber *)priority;

@end
