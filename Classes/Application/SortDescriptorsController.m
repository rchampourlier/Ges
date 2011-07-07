//
//  SortDescriptorsController.m
//  Ges
//
//  Created by NeoJF on 23/10/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "SortDescriptorsController.h"

/**
 * Provides in a single class a common way to manage sort descriptors of the
 * different kinds of entities used by the program:
 *	- operations,
 *	- accounts,
 *	- modes,
 *  - posts,
 *	- types.
 *
 * This class is intended to be instantiated for each group of array controllers
 * which requires its services. In particular, each nib file containing array
 * controllers of previously indicated entities should use an instance of this
 * class to bind array controllers' 'sortDescriptors' properties with the corresponding
 * property of the 'SortDescriptorsController' instance.
 */
@implementation SortDescriptorsController


#pragma mark -
#pragma mark === Life cycle ===

/**
 * Inits the 'SortDescriptorsController'.
 *
 * Creates the initial sort descriptors for all managed entity types.
 */
- (id)init {
	self = [super init];
	if (self != nil) {
		prioritySortDescriptors = [SortDescriptorsController prioritySortDescriptors];
		operationsSortDescriptors = [SortDescriptorsController operationsSortDescriptors];
	}
	return self;
}

/**
 * Deallocates the 'SortDescriptorsController'.
 *
 * Release previously retained objects, essentially sort descriptors.
 */
- (void)dealloc {
	[prioritySortDescriptors release];
	[operationsSortDescriptors release];
	[super dealloc];
}

#pragma mark -
#pragma mark === Managing sort descriptors ===

/**
 * Returns the default sort descriptors for operations.
 * 
 * These descriptors are the same than the one set at initialization 
 * of the controller. It may be useful to use these descriptors for array
 * controllers which are intended to keep sorted in the same way.
 */
+ (NSArray*)operationsSortDescriptors {
	NSSortDescriptor* operationDateSD = [[NSSortDescriptor alloc] initWithKey:@"operationDate" ascending:NO];
	NSSortDescriptor* operationDescriptionSD = [[NSSortDescriptor alloc] initWithKey:@"operationDescription" ascending:YES];
	return [NSArray arrayWithObjects:operationDateSD, operationDescriptionSD, nil];
}

/**
 * Returns the an array containing a single NSSortDescriptor instance. This sort
 * descriptor sorts on the "priority" property available in most of entities used
 * in the application.
 */
+ (NSArray *)prioritySortDescriptors {
	NSSortDescriptor* prioritySD = [[NSSortDescriptor alloc] initWithKey:@"priority" ascending:YES];
	return [NSArray arrayWithObject:prioritySD];
}

@synthesize prioritySortDescriptors;
@synthesize operationsSortDescriptors;

@end
