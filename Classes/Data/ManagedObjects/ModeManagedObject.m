//
//  ModeManagedObject.m
//  Ges
//
//  Created by NeoJF on 16/06/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ModeManagedObject.h"


@implementation ModeManagedObject

/**
 * Sets the filterState flag of the receiver.
 * Overriding this method allows us to send a notification to the task's default center.
 * This notification is currently only used by the FilterController to update the filter.
 */
- (void)setFilterState:(NSNumber *)filterState {
#ifdef MODE_MANAGED_OBJECT_TRACE_METHODS
	printf("IN  [ModeManagedObject setFilterState:]\n");
#endif
	
	[self willChangeValueForKey:@"filterState"];
	[self setPrimitiveValue:filterState forKey:@"filterState"];
	[self didChangeValueForKey:@"filterState"];
	
#ifdef MODE_MANAGED_OBJECT_TRACE_NOTIFICATIONS
	printf("=== ModeManagedObject posting notification:%s\n", [NotificationNameModeFilterStateModified cStringUsingEncoding:NSUTF8StringEncoding]);
#endif
	[[NSNotificationCenter defaultCenter] postNotificationName:NotificationNameModeFilterStateModified object:self];
	
#ifdef MODE_MANAGED_OBJECT_TRACE_METHODS
	printf("OUT [ModeManagedObject setFilterState:]\n");
#endif
}

@end
