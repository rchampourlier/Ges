//
//  OperationManagedObject.m
//  Ges
//
//  Created by Romain Champourlier on 26/08/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "OperationManagedObject.h"

/**
 * Implements some accessors to provide adapted behavior.
 * It provides:
 *  - automatic selection of the type when a post is set (first type in priority order),
 *  - automatic update of the transfer's dual operation for the following properties:
 *		- person,
 *		- mode,
 *		- post,
 *		- reference,
 *		- type,
 *		- value,
 *		- value date (as known in model, even if, in fact, it represents the operation date),
 *
 * TODO: draw a little "link" indicator on corresponding fields when the transfer is active!
 */

@implementation OperationManagedObject

// TODO: accessors for setting should take into account the transferDualOperations to update it likewise

- (void)setPerson:(NSManagedObject *)aPerson {
#ifdef OPERATION_MANAGED_OBJECT_TRACE_METHODS
	printf("IN  [OperationManagedObject(%s) setPerson:%s]\n", [[self valueForKey:@"operationDescription"] CSTRING], [[aPerson valueForKey:@"name"] CSTRING]);
#endif
	
	[self willChangeValueForKey:@"person"];
	[self setPrimitiveValue:aPerson forKey:@"person"];
	[self didChangeValueForKey:@"person"];
	
	OperationManagedObject *tranferDualOperation = [self valueForKey:@"transferDualOperation"];
	if (tranferDualOperation != nil) {
		[tranferDualOperation willChangeValueForKey:@"person"];
		[tranferDualOperation setPrimitiveValue:aPerson forKey:@"person"];
		[tranferDualOperation didChangeValueForKey:@"person"];
	}
	
#ifdef OPERATION_MANAGED_OBJECT_TRACE_METHODS
	printf("OUT [OperationManagedObject(%s) setPerson:%s]\n", [[self valueForKey:@"operationDescription"] CSTRING], [[aPerson valueForKey:@"name"] CSTRING]);
#endif
}

- (void)setMode:(NSManagedObject *)aMode {
#ifdef OPERATION_MANAGED_OBJECT_TRACE_METHODS
	printf("IN  [OperationManagedObject(%s) setMode:%s]\n", [[self valueForKey:@"operationDescription"] CSTRING], [[aMode valueForKey:@"name"] CSTRING]);
#endif
	
	[self willChangeValueForKey:@"mode"];
	[self setPrimitiveValue:aMode forKey:@"mode"];
	[self didChangeValueForKey:@"mode"];
	
	OperationManagedObject *tranferDualOperation = [self valueForKey:@"transferDualOperation"];
	if (tranferDualOperation != nil) {
		[tranferDualOperation willChangeValueForKey:@"mode"];
		[tranferDualOperation setPrimitiveValue:aMode forKey:@"mode"];
		[tranferDualOperation didChangeValueForKey:@"mode"];
	}
	
#ifdef OPERATION_MANAGED_OBJECT_TRACE_METHODS
	printf("OUT [OperationManagedObject(%s) setMode:%s]\n", [[self valueForKey:@"operationDescription"] CSTRING], [[aMode valueForKey:@"name"] CSTRING]);
#endif
}

- (void)setReference:(id)aReference {
#ifdef OPERATION_MANAGED_OBJECT_TRACE_METHODS
	printf("IN  [OperationManagedObject(%s) setReference:%s]\n", [[self valueForKey:@"operationDescription"] CSTRING], [[aReference stringValue] CSTRING]);
#endif
	
	[self willChangeValueForKey:@"reference"];
	[self setPrimitiveValue:aReference forKey:@"reference"];
	[self didChangeValueForKey:@"reference"];
	
	OperationManagedObject *tranferDualOperation = [self valueForKey:@"transferDualOperation"];
	if (tranferDualOperation != nil) {
		[tranferDualOperation willChangeValueForKey:@"reference"];
		[tranferDualOperation setPrimitiveValue:aReference forKey:@"reference"];
		[tranferDualOperation didChangeValueForKey:@"reference"];
	}
	
#ifdef OPERATION_MANAGED_OBJECT_TRACE_METHODS
	printf("OUT [OperationManagedObject(%s) setReference:%s]\n", [[self valueForKey:@"operationDescription"] CSTRING], [[aReference stringValue] CSTRING]);
#endif
}

/**
 * Set accessor for the post property.
 *
 * The overriden accessor is used to automatically set the type of the
 * receiver to the first type child of aPost whose filterState is ON.
 */
- (void)setPost:(NSManagedObject *)aPost {
#ifdef OPERATION_MANAGED_OBJECT_TRACE_METHODS
	printf("IN  [OperationManagedObject(%s) setPost:%s]\n", [[self valueForKey:@"operationDescription"] cString], [[aPost valueForKey:@"name"] cString]);
#endif
	
	[self willChangeValueForKey:@"post"];
	[self setPrimitiveValue:aPost forKey:@"post"];
	[self didChangeValueForKey:@"post"];
	
	OperationManagedObject *tranferDualOperation = [self valueForKey:@"transferDualOperation"];
	
	if (aPost != nil) {
		NSFetchRequest *request = [[NSFetchRequest alloc] init];
		[request setEntity:[NSEntityDescription entityForName:EntityNameType inManagedObjectContext:[self managedObjectContext]]];
		[request setPredicate:[NSPredicate predicateWithFormat:@"post == %@", aPost]];
		NSArray *sortDescriptors = [SortDescriptorsController prioritySortDescriptors];
		[request setSortDescriptors:sortDescriptors];
		NSArray *typesArray = [[self managedObjectContext] executeFetchRequest:request error:nil];
		
		NSEnumerator *types = [typesArray objectEnumerator];
		NSManagedObject *type;
		NSManagedObject *keptType = nil;
		while ((type = [types nextObject]) && keptType == nil) {
			if ([[type valueForKey:@"filterState"] intValue] == 1) {
				keptType = type;
			}
		}
		
		[self willChangeValueForKey:@"type"];
		[self setPrimitiveValue:keptType forKey:@"type"];
		[self didChangeValueForKey:@"type"];
		
		if (tranferDualOperation != nil) {
			[tranferDualOperation willChangeValueForKey:@"type"];
			[tranferDualOperation setPrimitiveValue:keptType forKey:@"type"];
			[tranferDualOperation didChangeValueForKey:@"type"];
		}
	}
	
	if (tranferDualOperation != nil) {
		[tranferDualOperation willChangeValueForKey:@"post"];
		[tranferDualOperation setPrimitiveValue:aPost forKey:@"post"];
		[tranferDualOperation didChangeValueForKey:@"post"];
	}

#ifdef OPERATION_MANAGED_OBJECT_TRACE_METHODS
	printf("OUT [OperationManagedObject(%s) setPost:%s]\n", [[self valueForKey:@"operationDescription"] cString], [[aPost valueForKey:@"name"] cString]);
#endif
}

- (void)setType:(NSManagedObject *)aType {
#ifdef OPERATION_MANAGED_OBJECT_TRACE_METHODS
	printf("IN  [OperationManagedObject(%s) setType:%s]\n", [[self valueForKey:@"operationDescription"] CSTRING], [[aType valueForKey:@"name"] CSTRING]);
#endif
	
	[self willChangeValueForKey:@"type"];
	[self setPrimitiveValue:aType forKey:@"type"];
	[self didChangeValueForKey:@"type"];
	
	OperationManagedObject *tranferDualOperation = [self valueForKey:@"transferDualOperation"];
	if (tranferDualOperation != nil) {
		[tranferDualOperation willChangeValueForKey:@"type"];
		[tranferDualOperation setPrimitiveValue:aType forKey:@"type"];
		[tranferDualOperation didChangeValueForKey:@"type"];
	}
	
#ifdef OPERATION_MANAGED_OBJECT_TRACE_METHODS
	printf("OUT [OperationManagedObject(%s) setType:%s]\n", [[self valueForKey:@"operationDescription"] CSTRING], [[aType valueForKey:@"name"] CSTRING]);
#endif
}


/**
 * Set accessor for the value property.
 *
 * Overrides the standard accessor to update the dual operation when transfer
 * is set. The transferDualOperation is updated according to the modification
 * of the receiver.
 */
- (void)setValue:(NSNumber *)aValue {
#ifdef OPERATION_MANAGED_OBJECT_TRACE_METHODS
	printf("IN  [OperationManagedObject(%s) setValue:%s]\n", [[self valueForKey:@"operationDescription"] CSTRING], [[aValue stringValue] CSTRING]);
#endif
	
	[self willChangeValueForKey:@"value"];
	[self setPrimitiveValue:aValue forKey:@"value"];
	[self didChangeValueForKey:@"value"];
	
	OperationManagedObject *tranferDualOperation = [self valueForKey:@"transferDualOperation"];
	if (tranferDualOperation != nil) {
		[tranferDualOperation willChangeValueForKey:@"value"];
		[tranferDualOperation setPrimitiveValue:[NSNumber numberWithFloat:-[aValue floatValue]] forKey:@"value"];
		[tranferDualOperation didChangeValueForKey:@"value"];
	}
	
#ifdef OPERATION_MANAGED_OBJECT_TRACE_METHODS
	printf("OUT [OperationManagedObject(%s) setValue:%s]\n", [[self valueForKey:@"operationDescription"] CSTRING], [[aValue stringValue] CSTRING]);
#endif
}

- (void)setValueDate:(id)aDate {
#ifdef OPERATION_MANAGED_OBJECT_TRACE_METHODS
	printf("IN  [OperationManagedObject(%s) setValueDate:]\n", [[self valueForKey:@"operationDescription"] CSTRING]);
#endif
	
	[self willChangeValueForKey:@"valueDate"];
	[self setPrimitiveValue:aDate forKey:@"valueDate"];
	[self didChangeValueForKey:@"valueDate"];
	
	OperationManagedObject *tranferDualOperation = [self valueForKey:@"transferDualOperation"];
	if (tranferDualOperation != nil) {
		[tranferDualOperation willChangeValueForKey:@"valueDate"];
		[tranferDualOperation setPrimitiveValue:aDate forKey:@"valueDate"];
		[tranferDualOperation didChangeValueForKey:@"valueDate"];
	}
	
#ifdef OPERATION_MANAGED_OBJECT_TRACE_METHODS
	printf("OUT [OperationManagedObject(%s) setValueDate:]\n", [[self valueForKey:@"operationDescription"] CSTRING]);
#endif
}

@end
