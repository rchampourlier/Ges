//
//  OperationManagedObject.h
//  Ges
//
//  Created by Romain Champourlier on 26/08/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DebugDefines.h"
#import "ModelConstants.h"
#import "SortDescriptorsController.h"

#ifndef TRACE_ALL_L1
#define OPERATION_MANAGED_OBJECT_TRACE_METHODS
#endif

@interface OperationManagedObject : NSManagedObject {
}

- (void)setPerson:(NSManagedObject *)aPerson;
- (void)setMode:(NSManagedObject *)aMode;
- (void)setPost:(NSManagedObject *)aPost;
- (void)setType:(NSManagedObject *)aType;
- (void)setValue:(NSNumber *)aValue;
- (void)setValueDate:(id)aDate;

@end
