//
//  ExternalViewController.m
//  Ges
//
//  Created by NeoJF on 22/10/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "ExternalViewController.h"


@implementation ExternalViewController

#pragma mark -
#pragma mark === Life cycle ===

/**
 * Inits the instance. Sets its associated "MyDocument" to "aDocument".
 */
- (id)initWithDocument:(MyDocument*)aDocument {
	self = [self init];
	if (self != nil) {
		document = aDocument;
		managedObjectContext = [document managedObjectContext];
	}
	return self;
}


#pragma mark -
#pragma mark === Accessors ===

/**
 * Returns the "managedObjectContext" of the associated instance of
 * "MyDocument".
 */
- (NSManagedObjectContext*)managedObjectContext {
	return managedObjectContext;
}

/**
 * Returns the view for the "Quick Statistics" view in the main window.
 * Will be displayed within the main tab view of the main document's window.
 */
- (NSView*)view {
	return view;
}


#pragma mark -
#pragma mark === <NibOwner> ===

/**
 * Returns array controllers managing accounts of the nib owner.
 *
 * This method must be implemented by subclasses. Returns nil for this class.
 */
/*- (NSArray*)accountsArrayControllers {
	return nil;
}*/

/**
 * Returns array controllers managing modes of the nib owner.
 *
 * This method must be implemented by subclasses. Returns nil for this class.
 */
/*- (NSArray*)modesArrayControllers {
	return nil;
}*/

/**
 * Returns array controllers managing operations of the nib owner.
 *
 * This method must be implemented by subclasses. Returns nil for this class.
 */
/*- (NSArray*)operationsArrayControllers {
	return nil;
}*/

/**
 * Returns array controllers managing types of the nib owner.
 *
 * This method must be implemented by subclasses. Returns nil for this class.
 */
/*- (NSArray*)typesArrayControllers {
	return nil;
}*/

@synthesize managedObjectContext;
@synthesize document;
@synthesize view;
@end
