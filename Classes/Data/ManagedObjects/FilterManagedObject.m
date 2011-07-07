//
//  FilterManagedObject.m
//  Ges
//
//  Created by Romain Champourlier on 12/04/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FilterManagedObject.h"

@interface FilterManagedObject (PrivateMethods)
- (NSSet *)setForObject:(NSManagedObject *)anObject;
- (NSMutableSet *)mutableSetForObject:(NSManagedObject *)anObject;
@end


@implementation FilterManagedObject

- (BOOL)containsObject:(NSManagedObject *)anObject {
#ifdef FILTER_MANAGED_OBJECT_TRACE_METHODS
	printf("IN  [FilterManagedObject containsObject:]\n");
#endif
	
	NSSet *set = [self setForObject:anObject];
	if (set != nil) {
#ifdef FILTER_MANAGED_OBJECT_TRACE_METHODS
		printf("OUT [FilterManagedObject containsObject:] > %s\n", [set containsObject:anObject] ? "YES" : "NO");
#endif
		return [set containsObject:anObject];
	}

#ifdef FILTER_MANAGED_OBJECT_TRACE_METHODS
	printf("OUT [FilterManagedObject containsObject:] > NO\n");
#endif
	return NO;
}

- (void)inverseObjectStateInActiveFilter:(NSManagedObject *)anObject {
#ifdef FILTER_MANAGED_OBJECT_TRACE_METHODS
	printf("IN  [FilterManagedObject inverseObjectStateInActiveFilter:]\n");
#endif
	
	if ([self containsObject:anObject]) {
		[[self mutableSetForObject:anObject] removeObject:anObject];
	}
	else {
		[[self mutableSetForObject:anObject] addObject:anObject];
	}
	
#ifdef FILTER_MANAGED_OBJECT_TRACE_METHODS
	printf("OUT [FilterManagedObject inverseObjectStateInActiveFilter:]\n");
#endif
}

- (void)includeFromSameTypeOnly:(NSManagedObject *)anObject {
#ifdef FILTER_MANAGED_OBJECT_TRACE_METHODS
	printf("IN  [FilterManagedObject inverseObjectStateInActiveFilter:]\n");
#endif
	
	[[self mutableSetForObject:anObject] setSet:[NSSet setWithObject:anObject]];

#ifdef FILTER_MANAGED_OBJECT_TRACE_METHODS
	printf("OUT [FilterManagedObject inverseObjectStateInActiveFilter:]\n");
#endif
}

- (void)include:(NSManagedObject *)anObject {
#ifdef FILTER_MANAGED_OBJECT_TRACE_METHODS
	printf("IN  [FilterManagedObject include:]\n");
#endif
	
	[[self mutableSetForObject:anObject] addObject:anObject];

#ifdef FILTER_MANAGED_OBJECT_TRACE_METHODS
	printf("OUT [FilterManagedObject include:]\n");
#endif
}


#pragma mark -
#pragma mark === PrivateMethods ===

- (NSSet *)setForObject:(NSManagedObject *)anObject {
#ifdef FILTER_MANAGED_OBJECT_TRACE_PRIVATE_METHODS
	printf("IN  [FilterManagedObject setForObject:]\n");
#endif
	
	NSString *entityName = [[anObject entity] name];
	if ([entityName isEqualToString:EntityNamePerson]) {
#ifdef FILTER_MANAGED_OBJECT_TRACE_PRIVATE_METHODS
		printf("OUT [FilterManagedObject setForObject:]\n");
#endif
		return (NSSet *)[self valueForKey:@"persons"];
	}
	return nil;
}

- (NSMutableSet *)mutableSetForObject:(NSManagedObject *)anObject {
#ifdef FILTER_MANAGED_OBJECT_TRACE_PRIVATE_METHODS
	printf("IN  [FilterManagedObject mutableSetForObject:]\n");
#endif
	
	NSString *entityName = [[anObject entity] name];
	if ([entityName isEqualToString:EntityNamePerson]) {
#ifdef FILTER_MANAGED_OBJECT_TRACE_PRIVATE_METHODS
		printf("OUT [FilterManagedObject mutableSetForObject:]\n");
#endif
		return [self mutableSetValueForKey:@"persons"];
	}
	return nil;
}

@end
