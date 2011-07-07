/*
 * PrioritizedManagedObject.m
 *
 * Updated with last debug defines implementation.
 */

#import "PrioritizedManagedObject.h"

@interface PrioritizedManagedObject (PrivateMethods)
- (NSArray *)selectShiftedInstancesFrom:(int)sourcePriority to:(int)destPriority;
- (void)shiftInstancesFrom:(int)sourcePriority to:(int)destPriority;
@end
#pragma mark -

/**
 * PrioritizedManagedObject: extends NSManagedObject
 *
 * This class extends NSManagedObject for the special use of data classes using the
 * 'priority' property to stay ordered.
 */

@implementation PrioritizedManagedObject

/**
 Prepares the receiver to be removed from the document's managed object context.
 
 Concretely, it set the receiver's priority to the minimum, what allows another instance to take its place, and the other to shift in consequence.
 */
- (void)prepareToRemoval {
#ifdef PRIORITIZED_MANAGED_OBJECT_TRACE_METHODS
	printf("IN  [PrioritizedManagedObject prepareToRemoval]\n");
#endif
	
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	[request setEntity:[self entity]];
	[request setSortDescriptors:[SortDescriptorsController prioritySortDescriptors]];
	[self setPriority:[NSNumber numberWithInt:([[[self managedObjectContext] executeFetchRequest:request error:NULL] count] - 1)]];
	
#ifdef PRIORITIZED_MANAGED_OBJECT_TRACE_METHODS
	printf("OUT [PrioritizedManagedObject prepareToRemoval]\n");
#endif
}

/**
 * Sets the priority of the receiver. It also adjust priorities of the other entity's
 * instance. Selecting the instances to shift is done through the use of the
 * selectShiftedInstances: method (this allows the reusability of this class for the
 * Type entity which requires selection based on the parent post).
 */
- (void)setPriority:(NSNumber *)priority {
#ifdef PRIORITIZED_MANAGED_OBJECT_TRACE_METHODS
	printf("IN  [PrioritizedManagedObject (%s) setPriority:%d]\n", [[self valueForKey:@"name"] cString], [priority intValue]);
#endif
	
	if (![[self valueForKey:@"priority"] isEqualToNumber:priority]) {
		if (priorityShiftingLock) {
			
			/* This method is being re-entered by different instances which are being shifted
			 * by the source one. Only the first one must start the shifting.
			 */
			[self willChangeValueForKey:@"priority"];
			[self setPrimitiveValue:priority forKey:@"priority"];
			[self didChangeValueForKey:@"priority"];
		}
		
		else {
			priorityShiftingLock = YES;
			
			[self shiftInstancesFrom:[[self valueForKey:@"priority"] intValue] to:[priority intValue]];
			[self willChangeValueForKey:@"priority"];
			[self setPrimitiveValue:priority forKey:@"priority"];
			[self didChangeValueForKey:@"priority"];			
			
		priorityShiftingLock = NO;		}
	}
	
#ifdef PRIORITIZED_MANAGED_OBJECT_TRACE_METHODS
	printf("OUT [PrioritizedManagedObject (%s) setPriority:] END\n", [[self valueForKey:@"name"] cString]);
#endif
}


#pragma mark -
#pragma mark === PrivateMethods ===

- (NSArray *)selectShiftedInstancesFrom:(int)sourcePriority to:(int)destPriority {
#ifdef PRIORITIZED_MANAGED_OBJECT_TRACE_PRIVATE_METHODS
	printf("IN  [PrioritizedManagedObject selectShiftedInstancesFrom:%d:%d]\n", sourcePriority, destPriority);
#endif
	
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	[request setEntity:[self entity]];
	NSArray *sortDescriptors = [NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"priority" ascending:YES]];
	[request setSortDescriptors:sortDescriptors];
	
	if (sourcePriority == -1) {
		// Receiver is inserted
		
		[request setPredicate:[NSPredicate predicateWithFormat:@"priority >= %d", destPriority]];
	}
	else if (destPriority > sourcePriority) {
		// Receiver is going down

		[request setPredicate:[NSPredicate predicateWithFormat:@"priority > %d AND priority <= %d", sourcePriority, destPriority]];
	}
	
	else if (destPriority < sourcePriority) {
		// Receiver is going up

		[request setPredicate:[NSPredicate predicateWithFormat:@"priority < %d AND priority >= %d", sourcePriority, destPriority]];
	}

#ifdef PRIORITIZED_MANAGED_OBJECT_TRACE_PRIVATE_METHODS
	printf("OUT [PrioritizedManagedObject selectShiftedInstancesFrom:%d:%d]\n", sourcePriority, destPriority);
#endif
	
	return [[self managedObjectContext] executeFetchRequest:request error:NULL];
}

- (void)shiftInstancesFrom:(int)sourcePriority to:(int)destPriority {
#ifdef PRIORITIZED_MANAGED_OBJECT_TRACE_PRIVATE_METHODS
	printf("IN  [PrioritizedManagedObject shiftInstancesFrom:%d:%d]\n", sourcePriority, destPriority);
#endif
	
	NSArray *shiftedInstances = [self selectShiftedInstancesFrom:sourcePriority to:destPriority];
#ifdef PRIORITIZED_MANAGED_OBJECT_DETAILS
	printf("--- number of shifted instances: %d\n", [shiftedInstances count]);
#endif
	
	if (sourcePriority == -1) {
		int i;
		for (i = 0; i < [shiftedInstances count]; i++) {
#ifdef PRIORITIZED_MANAGED_OBJECT_DETAILS
			printf("%s %d -> %d\n", [[[shiftedInstances objectAtIndex:(destPriority + i)] valueForKey:@"name"] cString], [[[shiftedInstances objectAtIndex:(destPriority + i)] valueForKey:@"priority"] intValue], destPriority + i + 1);
#endif
			[[shiftedInstances objectAtIndex:(destPriority + i)] setValue:[NSNumber numberWithInt:(destPriority + i + 1)] forKey:@"priority"];
		}
		
		[self willChangeValueForKey:@"priority"];
		[self setPrimitiveValue:[NSNumber numberWithInt:destPriority] forKey:@"priority"];
		[self didChangeValueForKey:@"priority"];
		
	}
	
	else {		
		if (destPriority > sourcePriority) {
			// Shifted instances are going up
					
			int i;
			for (i = 0; i < [shiftedInstances count]; i++) {
#ifdef PRIORITIZED_MANAGED_OBJECT_DETAILS
				printf("%s %d -> %d\n", [[[shiftedInstances objectAtIndex:i] valueForKey:@"name"] cString], [[[shiftedInstances objectAtIndex:i] valueForKey:@"priority"] intValue], sourcePriority + i);
#endif
				[[shiftedInstances objectAtIndex:i] setValue:[NSNumber numberWithInt:(sourcePriority + i)] forKey:@"priority"];
			}
			
			[self willChangeValueForKey:@"priority"];
			[self setPrimitiveValue:[NSNumber numberWithInt:(destPriority - 1)] forKey:@"priority"];
			[self didChangeValueForKey:@"priority"];
			
#ifdef PRIORITIZED_MANAGED_OBJECT_DETAILS
			printf("%s %d -> %d\n", [[self valueForKey:@"name"] cString], sourcePriority, destPriority - 1);
#endif
		}
	
		else if (destPriority < sourcePriority) {
			// Shifted instances are going down
			
			[self willChangeValueForKey:@"priority"];
			[self setPrimitiveValue:[NSNumber numberWithInt:destPriority] forKey:@"priority"];
			[self didChangeValueForKey:@"priority"];
#ifdef PRIORITIZED_MANAGED_OBJECT_DETAILS
			printf("%s %d -> %d\n", [[self valueForKey:@"name"] cString], sourcePriority, destPriority);
#endif		
			int i;
			for (i = 0; i < [shiftedInstances count]; i++) {
#ifdef PRIORITIZED_MANAGED_OBJECT_DETAILS
				printf("%s %d -> %d\n", [[[shiftedInstances objectAtIndex:i] valueForKey:@"name"] cString], [[[shiftedInstances objectAtIndex:i] valueForKey:@"priority"] intValue], sourcePriority - i);
#endif
				[[shiftedInstances objectAtIndex:i] setValue:[NSNumber numberWithInt:(destPriority + 1 + i)] forKey:@"priority"];
			}
		}
	}
	
#ifdef PRIORITIZED_MANAGED_OBJECT_TRACE_PRIVATE_METHODS
	printf("OUT [PrioritizedManagedObject shiftInstancesFrom:%d:%d]\n", sourcePriority, destPriority);
#endif
}	

@end
