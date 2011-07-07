//
//  AccountManagedObject.m
//  Ges
//
//  Created by Romain Champourlier on 29/08/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "AccountManagedObject.h"


@implementation AccountManagedObject

/**
 * Sets the filterState flag of the receiver.
 * Overriding this method allows us to send a notification to the task's default center.
 * This notification is currently only used by the FilterController to update the filter.
 *
 * TODO: may regroup under the same parent class account and mode managed object classes.
 */
- (void)setFilterState:(NSNumber *)filterState {
#ifdef ACCOUNT_MANAGED_OBJECT_TRACE_METHODS
	printf("IN  [AccountManagedObject(%s) setFilterState:%d]\n", [[self valueForKey:@"name"] cString], [filterState intValue]);
#endif
	
	//if (filterState != [self valueForKey:@"filterState"]) {
	if (! [filterState isEqualToNumber:[self valueForKey:@"filterState"]]) {
		NSNumber *originalFilterState = [self valueForKey:@"filterState"];
		
		[self willChangeValueForKey:@"filterState"];
		[self setPrimitiveValue:filterState forKey:@"filterState"];
		[self didChangeValueForKey:@"filterState"];
	
		if (AMOPostingFilterStateModifiedNotification) {
			//NSArray *accountsIn = [NSArray arrayWithObject:self];
			//NSArray *accountsOut = [NSArray array];
			//NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:accountsIn, NotificationUserInfoKeyAccountsIn, accountsOut, NotificationUserInfoKeyAccountsOut, nil];

			
			NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
									  self, NotificationUserInfoKeyFilterStateObject,
									  originalFilterState, NotificationUserInfoKeyFilterStateOriginal,
									  filterState, NotificationUserInfoKeyFilterStateTarget,
									  nil];

#ifdef ACCOUNT_MANAGED_OBJECT_TRACE_NOTIFICATIONS
			printf("=== AccountManagedObject posting notification:%s\n", [NotificationNameAccountFilterStateModified cStringUsingEncoding:NSUTF8StringEncoding]);
#endif
			[[NSNotificationCenter defaultCenter] postNotificationName:NotificationNameAccountFilterStateModified object:self userInfo:userInfo];
		}
	}

#ifdef ACCOUNT_MANAGED_OBJECT_TRACE_METHODS
	printf("OUT [AccountManagedObject(%s) setFilterState:] END\n", [[self valueForKey:@"name"] cString]);
#endif
}

+ (void)startPostingFilterStateModifiedNotification {
	AMOPostingFilterStateModifiedNotification = YES;
}

+ (void)stopPostingFilterStateModifiedNotification {
	AMOPostingFilterStateModifiedNotification = NO;
}

@end
