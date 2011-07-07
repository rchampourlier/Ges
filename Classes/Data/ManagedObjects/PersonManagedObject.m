//
//  PersonManagedObject.m
//  Ges
//
//  Created by Romain Champourlier on 12/04/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PersonManagedObject.h"


@implementation PersonManagedObject

/**
 * Sets the filterState flag of the receiver.
 * Overriding this method allows us to send a notification to the task's default center.
 * This notification is currently only used by the FilterController to update the filter.
 *
 * TODO: may regroup under the same parent class account, person and mode managed object classes.
 */
- (void)setFilterState:(NSNumber *)filterState {
#ifdef PERSON_MANAGED_OBJECT_TRACE_METHODS
	printf("IN  [PersonManagedObject(%s) setFilterState:%d]\n", [[self valueForKey:@"name"] cString], [filterState intValue]);
#endif
	
	//if (filterState != [self valueForKey:@"filterState"]) {
	if (! [filterState isEqualToNumber:[self valueForKey:@"filterState"]]) {
		NSNumber *originalFilterState = [self valueForKey:@"filterState"];
		
		[self willChangeValueForKey:@"filterState"];
		[self setPrimitiveValue:filterState forKey:@"filterState"];
		[self didChangeValueForKey:@"filterState"];
		
		if (PersonMOPostingFilterStateModifiedNotification) {
			NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
									  self, NotificationUserInfoKeyFilterStateObject,
									  originalFilterState, NotificationUserInfoKeyFilterStateOriginal,
									  filterState, NotificationUserInfoKeyFilterStateTarget,
									  nil];
			
#ifdef PERSON_MANAGED_OBJECT_TRACE_NOTIFICATIONS
			printf("=== PersonManagedObject posting notification:%s\n", [NotificationNamePersonFilterStateModified cStringUsingEncoding:NSUTF8StringEncoding]);
#endif
			[[NSNotificationCenter defaultCenter] postNotificationName:NotificationNamePersonFilterStateModified object:self userInfo:userInfo];
		}
	}
	
#ifdef PERSON_MANAGED_OBJECT_TRACE_METHODS
	printf("OUT [PersonManagedObject(%s) setFilterState:] END\n", [[self valueForKey:@"name"] cString]);
#endif
}


#pragma mark -
#pragma mark === Class methods ===

+ (void)startPostingFilterStateModifiedNotification {
	PersonMOPostingFilterStateModifiedNotification = YES;
}

+ (void)stopPostingFilterStateModifiedNotification {
	PersonMOPostingFilterStateModifiedNotification = NO;
}

@end
