//
//  ExternalWindowController.m
//  Ges
//
//  Created by NeoJF on 25/10/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "ExternalWindowController.h"


@implementation ExternalWindowController

#pragma mark -
#pragma mark === Life cycle ===

/**
 * Inits the instance. Sets its associated "MyDocument" to "aDocument".
 */
- (id)initWithDocument:(MyDocument*)aDocument {
#ifdef EXTERNAL_WINDOW_CONTROLLER_TRACE_LIFE_CYCLE
	printf("[ExternalWindowController initWithDocument:%p]\n", aDocument);
#endif
	
	self = [self init];
	if (self != nil) {
		document = aDocument;
		managedObjectContext = [document managedObjectContext];
	}
	return self;
}


#pragma mark -
#pragma mark === Managed window ===

/**
 * Opens the window managed by the controller.
 *
 * This method must be implemented by subclasses. It does not do anything in
 * this class.
 */
- (void)openWindow {
}

/**
 * Closes the window managed by the controller.
 *
 * This method must be implemented by subclasses. It does not do anything in
 * this class.
 */
- (void)closeWindow {
}

#pragma mark -
#pragma mark === Accessors ===


/**
 * Returns the shared MyDocument instance.
 */
- (MyDocument *)document {
	return document;
}

/**
 * Returns the "managedObjectContext" of the associated instance of
 * "MyDocument".
 */
- (NSManagedObjectContext*)managedObjectContext {
	return managedObjectContext;
}


@synthesize managedObjectContext;
@end
