//
//  PostManagedObject.m
//  Ges
//
//  Created by NeoJF on 11/06/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "PostManagedObject.h"

// TODO: should update filterState when post deleted

@interface PostManagedObject (PrivateMethods)
- (void)initializeActiveTypesCount;
@end

@implementation PostManagedObject

- (id)initWithEntity:(NSEntityDescription *)entity insertIntoManagedObjectContext:(NSManagedObjectContext *)context {
#ifdef POST_MANAGED_OBJECT_LIFE_CYCLE
	printf("IN  [PostManagedObject initWithEntity::]\n");
#endif
	
	self = [super initWithEntity:entity insertIntoManagedObjectContext:context];
	if (self != nil) {
		[self setPrimitiveValue:[NSNumber numberWithBool:YES] forKey:@"filterState"];
		activeTypesCount = -1;
	}

#ifdef POST_MANAGED_OBJECT_LIFE_CYCLE_END
	printf("OUT [PostManagedObject initWithEntity::]\n");
#endif

	return self;
}


/**
 * Sets the filterState flag of the receiver.
 * Overriding this method allows us to update receiver's types filterState flags according
 * to the new value.
 */
- (void)setFilterState:(NSNumber *)filterState {
#ifdef POST_MANAGED_OBJECT_TRACE_METHODS
	printf("IN  [PostManagedObject(%s) setFilterState:%d]\n", [[self valueForKey:@"name"] cString], [filterState intValue]);
#endif
	
	int filterStateInt = [filterState intValue];
	if (! [filterState isEqualToNumber:[self valueForKey:@"filterState"]]) {
		NSNumber *originalFilterState = [self valueForKey:@"filterState"];
		int originalFilterStateInt = [originalFilterState intValue];

		[self willChangeValueForKey:@"filterState"];
		[self setPrimitiveValue:filterState forKey:@"filterState"];
		[self didChangeValueForKey:@"filterState"];

#ifdef POST_MANAGED_OBJECT_TRACE_NOTIFICATIONS
		printf("=== PostManagedObject posting notification:%s\n", [NotificationNameStopFilteringOperations cStringUsingEncoding:NSUTF8StringEncoding]);
#endif
		[[NSNotificationCenter defaultCenter] postNotificationName:NotificationNameStopFilteringOperations object:self];

		if (PMOPostingFilterStateModifiedNotification) {

			NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
									  self, NotificationUserInfoKeyFilterStateObject,
									  originalFilterState, NotificationUserInfoKeyFilterStateOriginal,
									  filterState, NotificationUserInfoKeyFilterStateTarget,
									  nil];
			
#ifdef POST_MANAGED_OBJECT_TRACE_NOTIFICATIONS
			printf("=== PostManagedObject posting notification:%s\n", [NotificationNamePostFilterStateModified cStringUsingEncoding:NSUTF8StringEncoding]);
#endif
			[[NSNotificationCenter defaultCenter] postNotificationName:NotificationNamePostFilterStateModified object:self userInfo:userInfo];
		}
				
		if (filterStateInt != NSMixedState) {
			// Post is not set to mixed state: update of its types may be required
			int typeFilterStateInt = filterStateInt;

			[self initializeActiveTypesCount];
			if ((typeFilterStateInt == NSOnState && activeTypesCount < [[self valueForKey:@"types"] count]) ||
				(typeFilterStateInt == NSOffState && activeTypesCount > 0)) {
				
				// Types should be set ON, and some are not. Or types should be set OFF, and some are not.
				NSEnumerator *types = [[[self valueForKey:@"types"] allObjects] objectEnumerator];
				NSManagedObject *type;
				while (type = [types nextObject]) {
					[type setValue:[NSNumber numberWithInt:typeFilterStateInt] forKey:@"filterState"];
				}
				//printf("-------- updating types after post filterState edition\n");
			}
			
			//[TypeManagedObject startPostingFilterStateModifiedNotification];
			
		}
		
#ifdef POST_MANAGED_OBJECT_TRACE_NOTIFICATIONS
		printf("=== PostManagedObject posting notification:%s\n", [NotificationNameStartFilteringOperations cStringUsingEncoding:NSUTF8StringEncoding]);
#endif
		[[NSNotificationCenter defaultCenter] postNotificationName:NotificationNameStartFilteringOperations object:self];
	}
	else if (filterStateInt == -1) {
		/*
		 * Notifying the change to allow the source list item update itself and display the
		 * correct number of active types.
		 */

		NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
								  self, NotificationUserInfoKeyFilterStateObject,
								  filterState, NotificationUserInfoKeyFilterStateOriginal,
								  filterState, NotificationUserInfoKeyFilterStateTarget,
								  nil];
		
#ifdef POST_MANAGED_OBJECT_TRACE_NOTIFICATIONS
		printf("=== PostManagedObject posting notification:%s\n", [NotificationNamePostFilterStateModified cStringUsingEncoding:NSUTF8StringEncoding]);
#endif
		[[NSNotificationCenter defaultCenter] postNotificationName:NotificationNamePostFilterStateModified object:self userInfo:userInfo];
	}
	
#ifdef POST_MANAGED_OBJECT_TRACE_METHODS
	printf("OUT [PostManagedObject(%s) setFilterState:%d]\n", [[self valueForKey:@"name"] cString], [filterState intValue]);
#endif
}

- (void)typeChangedFilterStateTo:(int)filterState {
#ifdef POST_MANAGED_OBJECT_TRACE_METHODS
	printf("IN  [PostManagedObject typeChangedFilterStateTo:%d]\n", filterState);
#endif
	
	if (activeTypesCount == -1) {
		[self initializeActiveTypesCount];
	}
	else {
		activeTypesCount += filterState == NSOnState ? 1 : -1;
	}
	
	id typeSet = [self valueForKey:@"types"];
		
	if (activeTypesCount == 0) {
		[self setFilterState:[NSNumber numberWithInt:NSOffState]];
	}
	else if (activeTypesCount < [typeSet count]) {
		[self setFilterState:[NSNumber numberWithInt:NSMixedState]];
	}
	else {
		[self setFilterState:[NSNumber numberWithInt:NSOnState]];
	}
	
#ifdef POST_MANAGED_OBJECT_TRACE_METHODS
	printf("OUT [PostManagedObject typeChangedFilterStateTo:%d\n", filterState);
#endif
}

- (void)initializeActiveTypesCount {
#ifdef POST_MANAGED_OBJECT_TRACE_METHODS
	printf("IN  [PostManagedObject initializeActiveTypesCount]\n");
#endif
	
	if (activeTypesCount == -1) {
		// activeTypesCount property not initialized. Counting active types.
		activeTypesCount = 0;
		NSEnumerator *types = [[[self valueForKey:@"types"] allObjects] objectEnumerator];
		id type;
		while (type = [types nextObject]) {
			if ([[type valueForKey:@"filterState"] boolValue]) {
				activeTypesCount++;
			}
		}
	}
	
#ifdef POST_MANAGED_OBJECT_TRACE_METHODS
	printf("OUT [PostManagedObject initializeActiveTypesCount]\n");
#endif
}


+ (void)startPostingFilterStateModifiedNotification {
	PMOPostingFilterStateModifiedNotification = YES;
}

+ (void)stopPostingFilterStateModifiedNotification {
	PMOPostingFilterStateModifiedNotification = NO;
}

@end
