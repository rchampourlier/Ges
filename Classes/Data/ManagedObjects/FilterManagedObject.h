//
//  FilterManagedObject.h
//  Ges
//
//  Created by Romain Champourlier on 12/04/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DebugDefines.h"
#import "ModelConstants.h"
#import "PrioritizedManagedObject.h"

#ifdef TRACE_ALL_L2
#define FILTER_MANAGED_OBJECT_TRACE_METHODS
#endif
#ifdef TRACE_ALL_L4
#define FILTER_MANAGED_OBJECT_TRACE_PRIVATE_METHODS
#endif

@interface FilterManagedObject : PrioritizedManagedObject {

}

- (BOOL)containsObject:(NSManagedObject *)anObject;
- (void)inverseObjectStateInActiveFilter:(NSManagedObject *)anObject;
- (void)includeFromSameTypeOnly:(NSManagedObject *)anObject;
- (void)include:(NSManagedObject *)anObject;

@end
