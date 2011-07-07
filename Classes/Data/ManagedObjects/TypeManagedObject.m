//
//  TypeManagedObject.m
//  Ges
//
//  Created by NeoJF on 28/05/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "TypeManagedObject.h"


@implementation TypeManagedObject

- (id)initWithEntity:(NSEntityDescription *)entity insertIntoManagedObjectContext:(NSManagedObjectContext *)context {
#ifdef TYPE_MANAGED_OBJECT_LIFE_CYCLE
	printf("IN  [TypeManagedObject initWithEntity::]\n");
#endif
	
	self = [super initWithEntity:entity insertIntoManagedObjectContext:context];
	if (self != nil) {
		[self setPrimitiveValue:[NSNumber numberWithInt:NSOnState] forKey:@"filterState"];
	}
	
#ifdef TYPE_MANAGED_OBJECT_LIFE_CYCLE
	printf("OUT [TypeManagedObject initWithEntity::]\n");
#endif
	
	return self;
}


- (NSArray *)selectShiftedInstancesFrom:(int)sourcePriority to:(int)destPriority {
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	[request setEntity:[self entity]];
	NSArray *sortDescriptors = [NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"priority" ascending:YES]];
	[request setSortDescriptors:sortDescriptors];
	
	if (sourcePriority == -1) {
		// Receiver is new. Shifting down all existing instances under dest position.
		
		[request setPredicate:[NSPredicate predicateWithFormat:@"post == %@ AND priority >= %d", [self valueForKey:@"post"], destPriority]];
	}
	
	else if (destPriority > sourcePriority) {
		// Receiver is going down
		
		[request setPredicate:[NSPredicate predicateWithFormat:@"post == %@ AND priority > %d AND priority <= %d", [self valueForKey:@"post"], sourcePriority, destPriority]];
	}
	
	else if (destPriority < sourcePriority) {
		// Receiver is going up
		
		[request setPredicate:[NSPredicate predicateWithFormat:@"post == %@ AND priority < %d AND priority >= %d", [self valueForKey:@"post"], sourcePriority, destPriority]];
	}
	
	return [[self managedObjectContext] executeFetchRequest:request error:NULL];
}

/**
 * Sets the post of the receiver to the specified one.
 * 
 * Overriding of the standard accessor for defining specific behavior
 * allowing to maintain sorting of the source and the destination posts
 * when a type is moved from one to another.
 */
- (void)setPost:(NSManagedObject *)post {
#ifdef TYPE_MANAGED_OBJECT_TRACE_METHODS
	printf("IN  [TypeManagedObject setPost:]\n");
#endif
		
	if (![[self valueForKey:@"post"] isEqualTo:post]) {

		/*
		 * Moving the type to the last position of its current post before
		 * changing its post. Prevents getting a hole in priorities when
		 * removing it.
		 */
		NSNumber *priority = [NSNumber numberWithInt:([[[self valueForKey:@"post"] valueForKeyPath:@"types.@count"] intValue] - 1)];

		/*
		 * Here we use the standard value key accessor, which use the one defined
		 * within PrioritizedManagedObject, thus reordering the other types within
		 * the post.
		 */
		[self setValue:priority forKey:@"priority"];
		
		priority = [NSNumber numberWithInt:[[post valueForKeyPath:@"types.@count"] intValue]];
		
		/*
		 * Here we set it directly, since this priority value is used to put the
		 * type at the last position in its new post. We don't want to affect
		 * the order in the previous post anymore.
		 */
		[self willChangeValueForKey:@"priority"];
		[self setPrimitiveValue:priority forKey:@"priority"];
		[self didChangeValueForKey:@"priority"];
		
		[self willChangeValueForKey:@"post"];
		[self setPrimitiveValue:post forKey:@"post"];
		[self didChangeValueForKey:@"post"];
	}

#ifdef TYPE_MANAGED_OBJECT_TRACE_METHODS
	printf("OUT  [TypeManagedObject setPost:]\n");
#endif
}

/**
 * Sets the filterState flag of the receiver.
 * Overriding this method allows us to update receiver's post filterState flag according
 * to the state of all its children.
 *
 * The post's filterActiveTypesCount is used in this method to quickly determine the
 * current number of receiver's post's types present in the filter, which enable us
 * to set the post's filterState state to ON, OFF, or MIXED.
 */
- (void)setFilterState:(NSNumber *)filterState {
#ifdef TYPE_MAMAGED_OBJECT_TRACE_METHODS
	printf("IN  [TypeManagedObject(%s) setFilterState:%d]\n", [[self valueForKey:@"name"] cStringUsingEncoding:NSUTF8StringEncoding], [filterState intValue]);
#endif
	
	if (! [filterState isEqualToNumber:[self valueForKey:@"filterState"]]) {
		NSNumber *originalFilterState = [self valueForKey:@"filterState"];
	
		if ([[self valueForKey:@"filterState"] boolValue]) {
			// The receiver is currently ON.

			if ([filterState intValue] != 1) {
				// Not to be set to ON. Setting to OFF.
				[self willChangeValueForKey:@"filterState"];
				[self setPrimitiveValue:[NSNumber numberWithInt:0] forKey:@"filterState"];
				[self didChangeValueForKey:@"filterState"];
			}
		}
		
		else if ([filterState intValue] != 0) {
			// The receiver is currently OFF and not to be set to OFF. Setting to ON.
			[self willChangeValueForKey:@"filterState"];
			[self setPrimitiveValue:[NSNumber numberWithInt:1] forKey:@"filterState"];
			[self didChangeValueForKey:@"filterState"];
		}
		
		[(PostManagedObject *)[self valueForKey:@"post"] typeChangedFilterStateTo:[filterState intValue]];
		
		if (TMOPostingFilterStateModifiedNotification) {
			NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
									  self, NotificationUserInfoKeyFilterStateObject,
									  originalFilterState, NotificationUserInfoKeyFilterStateOriginal,
									  filterState, NotificationUserInfoKeyFilterStateTarget,
									  nil];
					
#ifdef TYPE_MAMAGED_OBJECT_TRACE_NOTIFICATIONS
			printf("=== TypeManagedObject posting notification:%s\n", [NotificationNameTypeFilterStateModified cStringUsingEncoding:NSUTF8StringEncoding]);
#endif
			[[NSNotificationCenter defaultCenter] postNotificationName:NotificationNameTypeFilterStateModified object:self userInfo:userInfo];
		}
	}
	
#ifdef TYPE_MAMAGED_OBJECT_TRACE_METHODS_END
	printf("OUT [TypeManagedObject(%s) setFilterState:%d]\n", [[self valueForKey:@"name"] cStringUsingEncoding:NSUTF8StringEncoding], [filterState intValue]);
#endif	
}

+ (void)startPostingFilterStateModifiedNotification {
	TMOPostingFilterStateModifiedNotification = YES;
}

+ (void)stopPostingFilterStateModifiedNotification {
	TMOPostingFilterStateModifiedNotification = NO;
}

@end
