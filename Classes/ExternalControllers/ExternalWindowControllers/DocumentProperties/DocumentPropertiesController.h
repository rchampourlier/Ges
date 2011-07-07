//
//  DocumentPropertiesController.h
//  Ges
//
//  Created by NeoJF on 15/10/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "DebugDefines.h"
#import "DocumentPropertiesConstants.h"
#import "ModelConstants.h"
#import "PasteboardTypes.h"

#import "ExternalWindowController.h"
#import "ModelInstancesUser.h"
#import "NSTreeController_Extensions.h"

#ifndef TRACE_ALL
//#define DOCUMENT_PROPERTIES_CONTROLLER_TRACE_METHODS
#endif


/*
 * Inheritance: ExternalWindowController -> NSWindowController <NibWindowController>
 */
@interface DocumentPropertiesController : ExternalWindowController <ModelInstancesUser> {
	
	// Array and tree controllers
	IBOutlet NSArrayController	*accountsArrayController;
	IBOutlet NSArrayController	*personsArrayController;
	IBOutlet NSArrayController	*modesArrayController;
	IBOutlet NSArrayController	*modesAvailableForSelectedAccountArrayController;
	IBOutlet NSArrayController	*operationsArrayController;
	IBOutlet NSArrayController *postsArrayController;
	IBOutlet NSArrayController	*typesArrayController;
	IBOutlet NSTreeController	*postsTreeController;
	
	// GUI components
	IBOutlet NSTableView*	accountsTableView;
	IBOutlet NSTableView*	personsTableView;
	IBOutlet NSTableView*	modesTableView;
	IBOutlet NSTableView*	propertiesTableView;
	IBOutlet NSOutlineView*	postsTypesOutlineView;
	
	// Internal variables
	int newAccountsCounter;
	int newPersonsCounter;
	int newModesCounter;
	int newPostsCounter;
	int newTypesCounter;
}


/*
 * Life cycle
 */
- (id)init;
- (void)awakeFromNib;


/*
 * Window management
 */
- (void)openWindow;
- (void)closeWindow;
- (IBAction)closeProperties:(id)sender;


/*
 * Accessors
 */
- (NSManagedObjectContext*)managedObjectContext;
- (NSArrayController*)accountsArrayController;
- (NSArrayController*)modesArrayController;
- (NSArrayController*)typesArrayController;

/*
 * Other
 */
- (NSManagedObject*)selectedAccount;


/*
 * Data
 */

// IBActions
- (IBAction)addAccount:(id)sender;
- (IBAction)removeAccount:(id)sender;
- (IBAction)addMode:(id)sender;
- (IBAction)removeMode:(id)sender;
- (IBAction)addPost:(id)sender;
- (IBAction)addType:(id)sender;
- (IBAction)removePostOrType:(id)sender;
- (IBAction)addPerson:(id)sender;
- (IBAction)removePerson:(id)sender;

// Objects deletion
- (void)removeAccount;
- (void)removePerson;
- (void)removeMode;
- (void)removeObject:(NSManagedObject *)object;

/*
 * Responder chain IBActions
 */
- (IBAction)delete:(id)sender;

@end
