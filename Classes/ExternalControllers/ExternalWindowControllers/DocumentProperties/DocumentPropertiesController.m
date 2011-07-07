//
//  DocumentPropertiesController.m
//  Ges
//
//  Created by NeoJF on 15/10/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

/**
 * Controller for the "DocumentProperties" window.
 * Provides access to the document's managedObjectContext.
 */

#import "DocumentPropertiesController.h"


@implementation DocumentPropertiesController


#pragma mark -
#pragma mark === Life cycle ===

/**
 * Override of the init method. It allows specifying the particular nib file
 * that is used with this WindowController - follows the guidelines of the Cocoa
 * documentation.
 */
- (id)init {
#ifdef DOCUMENT_PROPERTIES_CONTROLLER_TRACE_METHODS
	printf("[DocumentPropertiesController init]\n");
#endif
	
	self = [super initWithWindowNibName:@"DocumentProperties"];
	if (self != nil) {
		newAccountsCounter = 0;
		newPersonsCounter = 0;
		newModesCounter = 0;
		newPostsCounter = 0;
		newTypesCounter = 0;
	}
	
#ifdef DOCUMENT_PROPERTIES_CONTROLLER_TRACE_METHODS
	printf("[DocumentPropertiesController init] END\n");
#endif
	
	return self;
}

/**
 * Performs actions once the nib file has been loaded.
 */
- (void)awakeFromNib {
#ifdef DOCUMENT_PROPERTIES_CONTROLLER_TRACE_METHODS
	printf("IN  [DocumentPropertiesController awakeFromNib]\n");
#endif
	
	// Register table view for drag'n'drop operations
	[accountsTableView registerForDraggedTypes:[NSArray arrayWithObject:entitiesTableViewRowType]];
	[modesTableView registerForDraggedTypes:[NSArray arrayWithObject:entitiesTableViewRowType]];
	[postsTypesOutlineView registerForDraggedTypes:[NSArray arrayWithObjects:typesOutlineViewRowType, postsOutlineViewRowType, nil]];
	[personsTableView registerForDraggedTypes:[NSArray arrayWithObject:entitiesTableViewRowType]];
	
	// Set sort descriptors for array controllers
	/*NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"priority" ascending:YES];
	NSArray *sortDescriptorsArray = [NSArray arrayWithObject:sortDescriptor];
	[accountsArrayController setSortDescriptors:sortDescriptorsArray];
	[personsArrayController setSortDescriptors:sortDescriptorsArray];
	[modesArrayController setSortDescriptors:sortDescriptorsArray];
	[postsTreeController setSortDescriptors:sortDescriptorsArray];
	[typesArrayController setSortDescriptors:sortDescriptorsArray];*/
	
#ifdef DOCUMENT_PROPERTIES_CONTROLLER_TRACE_METHODS
	printf("OUT [DocumentPropertiesController awakeFromNib]\n");
#endif
}


#pragma mark -
#pragma mark === Window management ===

/**
 * Opens the properties window.
 */
- (void)openWindow {
#ifdef DOCUMENT_PROPERTIES_CONTROLLER_TRACE_METHODS
	printf("[DocumentPropertiesController openWindow]\n");
#endif
	
	[NSApp beginSheet:[self window] modalForWindow:[document windowForSheet] modalDelegate:document didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
	
#ifdef DOCUMENT_PROPERTIES_CONTROLLER_TRACE_METHODS
	printf("[DocumentPropertiesController openWindow] END\n");
#endif
}

/**
 * Closes the properties window.
 *
 * Rearrange array controllers for all kinds of entities - except operations. This
 * may be needed to take account in other nib files of modifications done in
 * document properties.
 *
 * TODO:
 *	- Array controllers should only be rearranged if needed to optimize code.
 */
- (void)closeWindow {
#ifdef DOCUMENT_PROPERTIES_CONTROLLER_TRACE_METHODS
	printf("[DocumentPropertiesController closeWindow]\n");
#endif
	
	//[document rearrangeAccountsArrayControllers:self];
	//[document rearrangeModesArrayControllers:self];
	[document rearrangePostsArrayControllers:self];
	[document rearrangeTypesArrayControllers:self];
	
	[NSApp endSheet:[self window]];
	[[self window] orderOut:self];
	
#ifdef DOCUMENT_PROPERTIES_CONTROLLER_TRACE_METHODS
	printf("[DocumentPropertiesController closeWindow] END\n");
#endif
}

/**
 * IBAction for closing the properties window.
 */
- (IBAction)closeProperties:(id)sender {
#ifdef DOCUMENT_PROPERTIES_CONTROLLER_TRACE_METHODS
	printf("[DocumentPropertiesController closeProperties:]\n");
#endif
	[self closeWindow];
#ifdef DOCUMENT_PROPERTIES_CONTROLLER_TRACE_METHODS
	printf("[DocumentPropertiesController closeProperties:] END\n");
#endif
}


#pragma mark -
#pragma mark === Accessors ===

/**
 * Returns the associated document's managed object context.
 */
- (NSManagedObjectContext*)managedObjectContext {
#ifdef DOCUMENT_PROPERTIES_CONTROLLER_TRACE_METHODS
	printf("[DocumentPropertiesController managedObjectContext]\n");
#endif
	
	return [document managedObjectContext];
}

/**
 * Returns the array controller for accounts objects.
 */
- (NSArrayController*)accountsArrayController {
	return accountsArrayController;
}

/**
 * Returns the array controller for modes objects.
 */
- (NSArrayController*)modesArrayController {
	return modesArrayController;
}

/**
 * Returns the array controller for types objects.
 */
- (NSArrayController*)typesArrayController {
	return typesArrayController;
}

#pragma mark -
#pragma mark === Other ===

/**
 * Returns the account currently selected within the accountsArrayController.
 * If no account is selected, or several accounts are selected, returns nil.
 */
- (NSManagedObject *)selectedAccount {
	NSArray *selectedAccounts = [accountsArrayController selectedObjects];
	if ([selectedAccounts count] == 1) {
		return [selectedAccounts objectAtIndex:0];
	}
	else {
		return nil;
	}
}


#pragma mark -
#pragma mark === Data ===


#pragma mark -
#pragma mark === IBActions ===

- (IBAction)addAccount:(id)sender {
#ifdef DOCUMENT_PROPERTIES_CONTROLLER_TRACE_METHODS
	printf("[DocumentPropertiesController addAccount]\n");
#endif
	
	// Seeking an available default name
	NSString* defaultName;
	NSArray* accountsWithDefaultName;
	
	do {
		newAccountsCounter++;
		defaultName = [NSString stringWithFormat:@"%@ %d", NSLocalizedString(@"accountDefaultName", nil), newAccountsCounter];
		NSFetchRequest* request = [[[NSFetchRequest alloc] init] autorelease];
		[request setEntity:[NSEntityDescription entityForName:EntityNameAccount inManagedObjectContext:managedObjectContext]];
		[request setPredicate:[NSPredicate predicateWithFormat:@"name == %@", defaultName]];
		accountsWithDefaultName = [managedObjectContext executeFetchRequest:request error:NULL];
	}
	while ([accountsWithDefaultName count] > 0);
	
	// Inserting the new account in managed object context
	NSManagedObject* newAccount = [NSEntityDescription insertNewObjectForEntityForName:EntityNameAccount inManagedObjectContext:managedObjectContext];
	NSMutableSet* availableModesSet = [newAccount mutableSetValueForKey:@"availableModes"];

	// Setting initial values
	[newAccount setValue:defaultName forKey:@"name"];
	int priority = [accountsTableView numberOfRows];
	[newAccount setValue:[NSNumber numberWithInt:priority] forKey:@"priority"];
	[availableModesSet addObjectsFromArray:[modesArrayController content]];
		
	[self rearrangeAccountsArrayControllers:self];
	[document rearrangeAccountsArrayControllers:self];
	
	[accountsTableView selectRow:priority byExtendingSelection:NO];
	[accountsTableView editColumn:0 row:priority withEvent:nil select:YES];
		
#ifdef DOCUMENT_PROPERTIES_CONTROLLER_TRACE_METHODS
	printf("[DocumentPropertiesController addAccount] END\n");
#endif
}

- (IBAction)removeAccount:(id)sender {
#ifdef DOCUMENT_PROPERTIES_CONTROLLER_TRACE_METHODS
	printf("[DocumentPropertiesController removeAccount:]\n");
#endif
	
	int numberOfDeletedOperations = [[[[accountsArrayController selectedObjects] objectAtIndex:0] valueForKey:@"operations"] count];
	
	if (numberOfDeletedOperations > 0) {
		NSAlert* alert = [[[NSAlert alloc] init] autorelease];
		[alert setMessageText:NSLocalizedString(@"deletingAccountConfirmationAlertMessage", nil)];
		[alert setInformativeText:[NSString stringWithFormat:NSLocalizedString(@"deletingAccountConfirmationAlertInfo", nil), numberOfDeletedOperations]];
		[alert addButtonWithTitle:NSLocalizedString(@"deletingAccountConfirmationAlertButtonYes", nil)];
		[alert addButtonWithTitle:NSLocalizedString(@"deletingAccountConfirmationAlertButtonNo", nil)];
		[alert setIcon:[NSImage imageNamed:@"Barred_64x64"]];
		[alert beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:[[accountsArrayController selectedObjects] objectAtIndex:0]];
	}
	else {
		[self removeAccount];
	}
	
#ifdef DOCUMENT_PROPERTIES_CONTROLLER_TRACE_METHODS
	printf("[DocumentPropertiesController removeAccount:] END\n");
#endif
}

- (void)removeAccount {
#ifdef DOCUMENT_PROPERTIES_CONTROLLER_TRACE_METHODS
	printf("[DocumentPropertiesController removeAccount]\n");
#endif
	
	[[self managedObjectContext] deleteObject:[[accountsArrayController selectedObjects] objectAtIndex:0]];
	[[self managedObjectContext] processPendingChanges];
	
#ifdef DOCUMENT_PROPERTIES_CONTROLLER_TRACE_METHODS
	printf("[DocumentPropertiesController removeAccount] END\n");
#endif
}

- (IBAction)addMode:(id)sender {
#ifdef DOCUMENT_PROPERTIES_CONTROLLER_TRACE_METHODS
	printf("[DocumentPropertiesController addMode:]\n");
#endif
	
	// Seeking an available default name
	NSString* defaultName;
	NSArray* modesWithDefaultName;
	
	do {
		newModesCounter++;
		defaultName = [NSString stringWithFormat:@"%@ %d", NSLocalizedString(@"modeDefaultName", nil), newModesCounter];
		NSFetchRequest* request = [[[NSFetchRequest alloc] init] autorelease];
		[request setEntity:[NSEntityDescription entityForName:EntityNameMode inManagedObjectContext:managedObjectContext]];
		[request setPredicate:[NSPredicate predicateWithFormat:@"name == %@", defaultName]];
		modesWithDefaultName = [managedObjectContext executeFetchRequest:request error:NULL];
	}
	while ([modesWithDefaultName count] > 0);
	
	// Inserting the new mode in managed object context
	NSManagedObject* newMode = [NSEntityDescription insertNewObjectForEntityForName:EntityNameMode inManagedObjectContext:managedObjectContext];
	
	// Setting initial values
	[newMode setValue:defaultName forKey:@"name"];
	int priority = [modesTableView numberOfRows];
	[newMode setValue:[NSNumber numberWithInt:priority] forKey:@"priority"];

	// The created mode is added to the 'availableModes' relationship of each account.
	NSArray* accountsArray = [accountsArrayController content];
	for (id loopItem in accountsArray) {
		NSMutableSet* availableModesSet = [loopItem mutableSetValueForKey:@"availableModes"];
		[availableModesSet addObject:newMode];
	}
	
	[managedObjectContext processPendingChanges];
	[modesTableView selectRow:priority byExtendingSelection:NO];
	[modesTableView editColumn:0 row:priority withEvent:nil select:YES];

	[document addModeToSelection:newMode];
	
#ifdef DOCUMENT_PROPERTIES_CONTROLLER_TRACE_METHODS
	printf("[DocumentPropertiesController addMode:] END\n");
#endif
}

- (IBAction)removeMode:(id)sender {
#ifdef DOCUMENT_PROPERTIES_CONTROLLER_TRACE_METHODS
	printf("[DocumentPropertiesController removeMode:]\n");
#endif
	
	int numberOfDeletedOperations = [[[[modesArrayController selectedObjects] objectAtIndex:0] valueForKey:@"operations"] count];
	
	if (numberOfDeletedOperations > 0) {
		NSAlert* alert = [[[NSAlert alloc] init] autorelease];
		[alert setMessageText:NSLocalizedString(@"deletingModeConfirmationAlertMessage", nil)];
		[alert setInformativeText:[NSString stringWithFormat:NSLocalizedString(@"deletingModeConfirmationAlertInfo", nil), numberOfDeletedOperations]];
		[alert addButtonWithTitle:NSLocalizedString(@"deletingModeConfirmationAlertButtonYes", nil)];
		[alert addButtonWithTitle:NSLocalizedString(@"deletingModeConfirmationAlertButtonNo", nil)];
		[alert setIcon:[NSImage imageNamed:@"Barred_64x64"]];
		[alert beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:[[modesArrayController selectedObjects] objectAtIndex:0]];
	}
	else {
		[self removeMode];
	}
	
#ifdef DOCUMENT_PROPERTIES_CONTROLLER_TRACE_METHODS
	printf("[DocumentPropertiesController removeMode:] END\n");
#endif
}

- (IBAction)addPost:(id)sender {
#ifdef DOCUMENT_PROPERTIES_CONTROLLER_TRACE_METHODS
	printf("[DocumentPropertiesController addPost:]\n");
#endif
	
	// Seeking an available default name
	NSString* defaultName;
	NSArray* postsWithDefaultName;
	
	do {
		newPostsCounter++;
		defaultName = [NSString stringWithFormat:@"%@ %d", NSLocalizedString(@"postDefaultName", nil), newPostsCounter];
		NSFetchRequest* request = [[[NSFetchRequest alloc] init] autorelease];
		[request setEntity:[NSEntityDescription entityForName:EntityNamePost inManagedObjectContext:managedObjectContext]];
		[request setPredicate:[NSPredicate predicateWithFormat:@"name == %@", defaultName]];
		postsWithDefaultName = [managedObjectContext executeFetchRequest:request error:NULL];
	}
	while ([postsWithDefaultName count] > 0);
	
	// Inserting the new post in managed object context
	NSManagedObject* newPost = [NSEntityDescription insertNewObjectForEntityForName:EntityNamePost inManagedObjectContext:managedObjectContext];
	
	// Setting initial values
	[newPost setValue:defaultName forKey:@"name"];
	
	int newPostPriority;
	NSArray *selectedObjects = [postsTreeController selectedObjects];
	NSManagedObject *selectedObject;
	
	if ([selectedObjects count]) {
		// An object is selected.
		
		selectedObject = [selectedObjects objectAtIndex:0];
		
		if ([[[selectedObject entity] name] isEqualToString:EntityNamePost]) {
			// The selected object is a Post.
			newPostPriority = [[selectedObject valueForKey:@"priority"] intValue] + 1;
		}
		else {
			newPostPriority = [[selectedObject valueForKeyPath:@"post.priority"] intValue] + 1;
		}
	}
	else {
		newPostPriority = 0;
	}
		
	[newPost setValue:[NSNumber numberWithInt:newPostPriority] forKey:@"priority"];
	
	[managedObjectContext processPendingChanges];
	[postsTreeController rearrangeObjects];
	
	int newPostRow = [postsTypesOutlineView rowForItem:[postsTreeController outlineItemForObject:newPost]];
	[postsTypesOutlineView selectRow:newPostRow byExtendingSelection:NO];
	[postsTypesOutlineView editColumn:0 row:newPostRow withEvent:nil select:YES];
	
#ifdef DOCUMENT_PROPERTIES_CONTROLLER_TRACE_METHODS
	printf("[DocumentPropertiesController addPost:] END\n");
#endif
}

- (IBAction)addType:(id)sender {
#ifdef DOCUMENT_PROPERTIES_CONTROLLER_TRACE_METHODS
	printf("[DocumentPropertiesController addType:]\n");
#endif
	
	// Getting the new type's post
	NSManagedObject *parentPost;

	/*
	 * Sometimes, the selectedObjects array is not correctly determined. This leads 
	 * to a bad priority assignment. Not particularly severe, but I couldn't find a 
	 * wayaround.
	 */
	NSArray *selectedObjects = [postsTreeController selectedObjects];

	NSManagedObject *selectedObject;
	int newTypePriority;
	
	if ([selectedObjects count]) {
		selectedObject = [selectedObjects objectAtIndex:0];
		
		if ([[[selectedObject entity] name] isEqualToString:EntityNamePost]) {
			// The selected object is a Post.
			parentPost = selectedObject;
			newTypePriority = 0;
		}
		else {
			// The selected object is a Type.
			parentPost = [selectedObject valueForKey:@"post"];
			//printf("%s %d\n", [[selectedObject valueForKey:@"name"] cString], [[selectedObject valueForKey:@"priority"] intValue]);
			newTypePriority = [[selectedObject valueForKey:@"priority"] intValue] + 1;
		}
	}
	else {
		NSFetchRequest* request = [[[NSFetchRequest alloc] init] autorelease];
		[request setEntity:[NSEntityDescription entityForName:EntityNamePost inManagedObjectContext:managedObjectContext]];
		[request setPredicate:[NSPredicate predicateWithFormat:@"priority == 0"]];
		parentPost = [[managedObjectContext executeFetchRequest:request error:NULL] objectAtIndex:0];
		newTypePriority = 0;
	}
	
	// Seeking an available default name
	NSString* defaultName;
	NSArray* typesWithDefaultName;
	
	do {
		newTypesCounter++;
		defaultName = [NSString stringWithFormat:@"%@ %d", NSLocalizedString(@"typeDefaultName", nil), newTypesCounter];
		NSFetchRequest* request = [[[NSFetchRequest alloc] init] autorelease];
		[request setEntity:[NSEntityDescription entityForName:EntityNameType inManagedObjectContext:managedObjectContext]];
		[request setPredicate:[NSPredicate predicateWithFormat:@"name == %@", defaultName]];
		typesWithDefaultName = [managedObjectContext executeFetchRequest:request error:NULL];
	}
	while ([typesWithDefaultName count] > 0);
	
	// Inserting the new type in managed object context
	NSManagedObject* newType = [NSEntityDescription insertNewObjectForEntityForName:EntityNameType inManagedObjectContext:managedObjectContext];
	
	// Setting initial values
	[newType setValue:parentPost forKey:@"post"];
	[newType setValue:defaultName forKey:@"name"];
		
	[managedObjectContext processPendingChanges];
	[postsTreeController rearrangeObjects];
	
	NSSet *parentPostTypes = [parentPost valueForKey:@"types"];
	NSArray *parentPostTypesArray = [parentPostTypes allObjects];
		
	[postsTypesOutlineView expandItem:[postsTreeController outlineItemForObject:parentPost]];
	int newTypeRow = [postsTypesOutlineView rowForItem:[postsTreeController outlineItemForObject:newType]];
	
	[postsTypesOutlineView selectRow:newTypeRow byExtendingSelection:NO];
	[postsTypesOutlineView editColumn:0 row:newTypeRow withEvent:nil select:YES];
	
#ifdef DOCUMENT_PROPERTIES_CONTROLLER_TRACE_METHODS
	printf("[DocumentPropertiesController addType:] END\n");
#endif
}

/**
 * Action responding to the "Delete selected item" in the "Posts and types"
 * panel.
 */
- (IBAction)removePostOrType:(id)sender {
#ifdef DOCUMENT_PROPERTIES_CONTROLLER_TRACE_METHODS
	printf("IN  [DocumentPropertiesController removePostOrType:]\n");
#endif
	
	NSArray *selectedObjects = [postsTreeController selectedObjects];
	
	if ([selectedObjects count]) {
		// An object is selected.
		
		NSManagedObject *selectedObject = [selectedObjects objectAtIndex:0];
		
		if ([[[selectedObject entity] name] isEqualToString:EntityNamePost]) {
			// The selected object is a Post.
			
			NSArray *deletedTypes = [[selectedObject valueForKey:@"types"] allObjects];
			int numberOfDeletedTypes = [deletedTypes count] ;
			int numberOfDeletedOperations = 0;
			for (id loopItem in deletedTypes) {
				numberOfDeletedOperations += [[loopItem valueForKeyPath:@"operations.@count"] intValue];
			}
			
			if (numberOfDeletedTypes > 0 || numberOfDeletedOperations > 0) {
				NSAlert* alert = [[[NSAlert alloc] init] autorelease];
				[alert setMessageText:NSLocalizedString(@"deletingPostConfirmationAlertMessage", nil)];
				[alert setInformativeText:[NSString stringWithFormat:NSLocalizedString(@"deletingPostConfirmationAlertInfo", nil), numberOfDeletedTypes, numberOfDeletedOperations]];
				[alert addButtonWithTitle:NSLocalizedString(@"deletingPostConfirmationAlertButtonYes", nil)];
				[alert addButtonWithTitle:NSLocalizedString(@"deletingPostConfirmationAlertButtonNo", nil)];
				[alert setIcon:[NSImage imageNamed:@"Barred_64x64"]];
				[alert beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:selectedObject];
			}
			
			else {
				[self removeObject:selectedObject];
			}
		}
		else {
			// The selected object is a Type.
			
			int numberOfDeletedOperations = [[selectedObject valueForKeyPath:@"operations.@count"] intValue];
			
			if (numberOfDeletedOperations > 0) {
				NSAlert* alert = [[[NSAlert alloc] init] autorelease];
				[alert setMessageText:NSLocalizedString(@"deletingTypeConfirmationAlertMessage", nil)];
				[alert setInformativeText:[NSString stringWithFormat:NSLocalizedString(@"deletingTypeConfirmationAlertInfo", nil), numberOfDeletedOperations]];
				[alert addButtonWithTitle:NSLocalizedString(@"deletingTypeConfirmationAlertButtonYes", nil)];
				[alert addButtonWithTitle:NSLocalizedString(@"deletingTypeConfirmationAlertButtonNo", nil)];
				[alert setIcon:[NSImage imageNamed:@"Barred_64x64"]];
				[alert beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:selectedObject];
			}
			
			else {
				[self removeObject:selectedObject];
			}
		}
	}
	
#ifdef DOCUMENT_PROPERTIES_CONTROLLER_TRACE_METHODS
	printf("OUT [DocumentPropertiesController removePostOrType:]\n");
#endif
}

/**
 * Action called when the "New person" button is pressed.
 */
- (IBAction)addPerson:(id)sender {
#ifdef DOCUMENT_PROPERTIES_CONTROLLER_TRACE_METHODS
	printf("IN  [DocumentPropertiesController addPerson:]\n");
#endif
	
	// Seeking an available default name
	NSString* defaultName;
	NSArray* personsWithDefaultName;
		
	do {
		newPersonsCounter++;
		defaultName = [NSString stringWithFormat:@"%@ %d", NSLocalizedString(@"personDefaultName", nil), newPersonsCounter];
		NSFetchRequest* request = [[[NSFetchRequest alloc] init] autorelease];
		[request setEntity:[NSEntityDescription entityForName:EntityNamePerson inManagedObjectContext:managedObjectContext]];
		[request setPredicate:[NSPredicate predicateWithFormat:@"name == %@", defaultName]];
		personsWithDefaultName = [managedObjectContext executeFetchRequest:request error:NULL];
	}
	while ([personsWithDefaultName count] > 0);
	
	// Inserting the new person in managed object context
	NSManagedObject* newPerson = [NSEntityDescription insertNewObjectForEntityForName:EntityNamePerson inManagedObjectContext:managedObjectContext];
	
	// Setting initial values
	[newPerson setValue:defaultName forKey:@"name"];
	int priority = [personsTableView numberOfRows];
	[newPerson setValue:[NSNumber numberWithInt:priority] forKey:@"priority"];
	
	printf("%s %d\n", [[newPerson valueForKey:@"name"] cStringUsingEncoding:NSASCIIStringEncoding], [[newPerson valueForKey:@"priority"] intValue]);
	
	[managedObjectContext processPendingChanges];
	
	[personsTableView selectRow:priority byExtendingSelection:NO];
	[personsTableView editColumn:0 row:priority withEvent:nil select:YES];

#ifdef DOCUMENT_PROPERTIES_CONTROLLER_TRACE_METHODS
	printf("OUT [DocumentPropertiesController addPerson:]\n");
#endif
}

/**
 * Action called when the "Delete selected person" button is pressed.
 */
- (IBAction)removePerson:(id)sender {
#ifdef DOCUMENT_PROPERTIES_CONTROLLER_TRACE_METHODS
	printf("IN  [DocumentPropertiesController removePerson:]\n");
#endif
	
	int numberOfDeletedOperations = [[[[personsArrayController selectedObjects] objectAtIndex:0] valueForKey:@"operations"] count];
	
	if (numberOfDeletedOperations > 0) {
		NSAlert* alert = [[[NSAlert alloc] init] autorelease];
		[alert setMessageText:NSLocalizedString(@"deletingPersonConfirmationAlertMessage", nil)];
		[alert setInformativeText:[NSString stringWithFormat:NSLocalizedString(@"deletingPersonConfirmationAlertInfo", nil), numberOfDeletedOperations]];
		[alert addButtonWithTitle:NSLocalizedString(@"deletingPersonConfirmationAlertButtonYes", nil)];
		[alert addButtonWithTitle:NSLocalizedString(@"deletingPersonConfirmationAlertButtonNo", nil)];
		[alert setIcon:[NSImage imageNamed:@"Barred_64x64"]];
		[alert beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:[[personsArrayController selectedObjects] objectAtIndex:0]];
	}
	else {
		[self removePerson];
	}
	
#ifdef DOCUMENT_PROPERTIES_CONTROLLER_TRACE_METHODS
	printf("OUT [DocumentPropertiesController removePerson:]\n");
#endif
}


#pragma mark -
#pragma mark === Objects deletion ===

- (void)removeMode {
#ifdef DOCUMENT_PROPERTIES_CONTROLLER_TRACE_METHODS
	printf("[DocumentPropertiesController removeMode]\n");
#endif
	
	[[self managedObjectContext] deleteObject:[[modesArrayController selectedObjects] objectAtIndex:0]];
	[[self managedObjectContext] processPendingChanges];
	
#ifdef DOCUMENT_PROPERTIES_CONTROLLER_TRACE_METHODS
	printf("[DocumentPropertiesController removeMode] END\n");
#endif
}

- (void)removePerson {
#ifdef DOCUMENT_PROPERTIES_CONTROLLER_TRACE_METHODS
	printf("IN  [DocumentPropertiesController removePerson]\n");
#endif
	
	[[self managedObjectContext] deleteObject:[[personsArrayController selectedObjects] objectAtIndex:0]];
	[[self managedObjectContext] processPendingChanges];
	
#ifdef DOCUMENT_PROPERTIES_CONTROLLER_TRACE_METHODS
	printf("OUT [DocumentPropertiesController removePerson] END\n");
#endif
}

#pragma mark -
#pragma mark === Other ===

/**
 * Removes the provided object from the document's managedObjectContext.
 * In order to keep correct priorities for the other objects of the same
 * kind, the provided object's priority is set to the last available
 * position.
 */
- (void)removeObject:(NSManagedObject *)object {
#ifdef DOCUMENT_PROPERTIES_CONTROLLER_TRACE_METHODS
	printf("[DocumentPropertiesController removeObject:]\n");
#endif
	
	if ([[[object entity] name] isEqualToString:EntityNameAccount]) {
		// Removing an Account.
		[object setValue:[NSNumber numberWithInt:[[accountsArrayController content] count]] forKey:@"priority"];
	}
	else if ([[[object entity] name] isEqualToString:EntityNameMode]) {
		// Removing a mode
		[object setValue:[NSNumber numberWithInt:[[modesArrayController content] count]] forKey:@"priority"];
	}
	else if ([[[object entity] name] isEqualToString:EntityNamePost]) {
		// Removing a post.
		[object setValue:[NSNumber numberWithInt:[[typesArrayController content] count]] forKey:@"priority"];
	}
	else if ([[[object entity] name] isEqualToString:EntityNameType]) {
		// Removing a type.
		[object setValue:[NSNumber numberWithInt:[[postsArrayController content] count]] forKey:@"priority"];
	}

	[[self managedObjectContext] deleteObject:object];
	[[self managedObjectContext] processPendingChanges];
	
#ifdef DOCUMENT_PROPERTIES_CONTROLLER_TRACE_METHODS
	printf("[DocumentPropertiesController removeObject:] END\n");
#endif
}

- (void)alertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo {
#ifdef DOCUMENT_PROPERTIES_CONTROLLER_TRACE_METHODS
	printf("[DocumentPropertiesController alertDidEnd:::]\n");
#endif
	
	NSObject *contextObject = (NSObject *)contextInfo;
	
	if ([[contextObject class] isSubclassOfClass:[NSManagedObject class]]) {
		/*
		 * The context of the alert is a NSManagedObject. It may be a post, or a type,
		 * which was going to be removed. Consequent action is implemented here.
		 */
		if (returnCode == NSAlertFirstButtonReturn) {
			// "Yes" button clicked.
			[self removeObject:(NSManagedObject *)contextObject];
		}
	}
	
#ifdef DOCUMENT_PROPERTIES_CONTROLLER_TRACE_METHODS
	printf("[DocumentPropertiesController alertDidEnd:::] END\n");
#endif
}


#pragma mark -
#pragma mark === Responder chain IBActions ===

/**
 * Depending on the current properties view, allows deletion of the selected entity
 * through the responder chain action event 'delete:'.
 *
 * This action is intended to be reached through the responders chain. For this
 * reason, other 'delete:' methods should be available in previous responders in
 * case other entities should be deleted.
 */
- (IBAction)delete:(id)sender {
#ifdef DOCUMENT_PROPERTIES_CONTROLLER_TRACE_METHODS
	printf("[DocumentPropertiesController delete:]\n");
#endif
	
	int row = [propertiesTableView selectedRow];
	switch (row) {
		case 0:
			// Properties: accounts
			[self removeAccount:self];
			break;
		case 1:
			// Properties: modes
			[self removeMode:self];
			break;
		case 2:
			// Properties: posts and types
			[self removePostOrType:self];
			break;
	}
	
#ifdef DOCUMENT_PROPERTIES_CONTROLLER_TRACE_METHODS
	printf("[DocumentPropertiesController delete:] END\n");
#endif
}


- (void)rearrangeAccountsArrayControllers:(id)sender {
#ifdef DOCUMENT_PROPERTIES_CONTROLLER_TRACE_METHODS
	printf("[DocumentPropertiesController rearrangeAccountsArrayControllers:]\n");
#endif
	
	[accountsArrayController rearrangeObjects];
	
#ifdef DOCUMENT_PROPERTIES_CONTROLLER_TRACE_METHODS
	printf("[DocumentPropertiesController rearrangeAccountsArrayControllers:] END\n");
#endif
	
}

- (void)rearrangePersonsArrayControllers:(id)sender {
#ifdef DOCUMENT_PROPERTIES_CONTROLLER_TRACE_METHODS
	printf("[DocumentPropertiesController rearrangePersonsArrayControllers:]\n");
#endif
	
	[personsArrayController rearrangeObjects];

#ifdef DOCUMENT_PROPERTIES_CONTROLLER_TRACE_METHODS
	printf("[DocumentPropertiesController rearrangePersonsArrayControllers:] END\n");
#endif
}

- (void)rearrangeModesArrayControllers:(id)sender {
#ifdef DOCUMENT_PROPERTIES_CONTROLLER_TRACE_METHODS
	printf("[DocumentPropertiesController rearrangeModesArrayControllers:]\n");
#endif
	
	[modesArrayController rearrangeObjects];
	[modesAvailableForSelectedAccountArrayController rearrangeObjects];
	
#ifdef DOCUMENT_PROPERTIES_CONTROLLER_TRACE_METHODS
	printf("[DocumentPropertiesController rearrangeModesArrayControllers:] END\n");
#endif
}

- (void)rearrangePostsArrayControllers:(id)sender {
#ifdef DOCUMENT_PROPERTIES_CONTROLLER_TRACE_METHODS
	printf("[DocumentPropertiesController rearrangePostsArrayControllers:]\n");
#endif
	
	[postsTreeController rearrangeObjects];
	
#ifdef DOCUMENT_PROPERTIES_CONTROLLER_TRACE_METHODS
	printf("[DocumentPropertiesController rearrangePostsArrayControllers:] END\n");
#endif
}

- (void)rearrangeTypesArrayControllers:(id)sender {
#ifdef DOCUMENT_PROPERTIES_CONTROLLER_TRACE_METHODS
	printf("[DocumentPropertiesController rearrangeTypesArrayControllers:]\n");
#endif
	
	[typesArrayController rearrangeObjects];
	
#ifdef DOCUMENT_PROPERTIES_CONTROLLER_TRACE_METHODS
	printf("[DocumentPropertiesController rearrangeTypesArrayControllers:] END\n");
#endif
}

/*@synthesize newTypesCounter;
@synthesize newAccountsCounter;
@synthesize postsTypesOutlineView;
@synthesize modesTableView;
@synthesize propertiesTableView;
@synthesize accountsTableView;
@synthesize postsTreeController;
@synthesize modesAvailableForSelectedAccountArrayController;
@synthesize accountsArrayController;
@synthesize postsArrayController;
@synthesize typesArrayController;
@synthesize modesArrayController;
@synthesize newModesCounter;
@synthesize operationsArrayController;
@synthesize newPostsCounter;*/
@end
