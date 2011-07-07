//
//  PropertiesAccountsTableController.m
//  Ges
//
//  Created by NeoJF on 17/10/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PropertiesEntitiesTableController.h"


/**
 * Controller for the table views displaying entities in the "Properties" window
 * of the document.
 * 
 * Registered as data source for drag'n'drop operations by:
 *	- 'accountsTableView',
 *	- 'modesTableView',
 *	- 'typesTableView'.
 *
 * For performing drag'n'drop operations, it is registered as the data source
 * of the table view (even if content is provided through bindings). Drag'n'drop
 * is used to set the order of appeareance of entities - by setting their 'priority'
 * value.
 *
 * Provides IBActions for:
 *	- 'accountsModesAssociationModesTableView': Responds to user's clicks to associate
 * clicked row's mode to selected account.
 *	- 'modesTableView': Responds to user's clicks to set the 'allowsValueDate' property
 * of the clicked mode.
 */


@implementation PropertiesEntitiesTableController


#pragma mark -
#pragma mark === Life cycle ===

/**
 * Called once nib file has been loaded.
 *
 * Register self as an observer of 'accountsArrayController's selection.
 */
- (void)awakeFromNib {
	[[documentPropertiesController accountsArrayController] addObserver:self forKeyPath:@"selection" options:0 context:nil];
}


#pragma mark -
#pragma mark === KVO ===

/**
 * Called when an observed property changed.
 *
 * Observed properties are:
 *	- 'selection' of 'accountsArrayController': It is observed to determine
 * when the modesTableView of the 'Accounts/modes association' tab must be
 * reloaded to display the availability of the modes for the newly selected
 * account.
 */
- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(id)context {
	if (object == [documentPropertiesController accountsArrayController]) {
		// Selected account did change.
		[accountsModesAssociationModesTableView reloadData];
	}
}


#pragma mark -
#pragma mark === Drag'n'drop management

/**
 * Called when a drag operation is initiated from the table view. Since the drag'n'drop
 * operation is confined within the table view, we only copy the row indexes in the
 * pasteboard (following TableView Drag'N'Drop programming Guide from Apple).
 */
- (BOOL)tableView:(NSTableView *)tv writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard*)pboard  {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];
    [pboard declareTypes:[NSArray arrayWithObject:entitiesTableViewRowType] owner:self];
    [pboard setData:data forType:entitiesTableViewRowType];
    return YES;
}

/**
 * Called by the table view to determine if the drop destination is valid.
 * The drop operation is only validated if it is a "drop above" operation,
 * since it is used to sort the rows.
 */
- (NSDragOperation)tableView:(NSTableView*)tv validateDrop:(id <NSDraggingInfo>)info proposedRow:(int)row proposedDropOperation:(NSTableViewDropOperation)op {
	if (op == NSTableViewDropAbove) {
		return NSDragOperationEvery;
	}
	else {
		return NSDragOperationNone;
	}
}

/**
 * Accepts a drop operation.
 *
 * The priority value is equal to the row position of the entity in the table view.
 * The dragged entity is updated with a priority value equal to the index of the row
 * where it is dropped. All entities between the dragged and the drop rows are shifted
 * consequently.
 */
- (BOOL)tableView:(NSTableView *)aTableView acceptDrop:(id <NSDraggingInfo>)info row:(int)row dropOperation:(NSTableViewDropOperation)operation {
   
	NSPasteboard* pboard = [info draggingPasteboard];
    NSData* rowData = [pboard dataForType:entitiesTableViewRowType];
    NSIndexSet* rowIndexes = [NSKeyedUnarchiver unarchiveObjectWithData:rowData];
    int dragRow = [rowIndexes firstIndex];
	
	NSManagedObject *draggedObject;
	
	if (aTableView == accountsTableView) {
		draggedObject = [[accountsArrayController arrangedObjects] objectAtIndex:dragRow];
	}
	else if (aTableView == personsTableView) {
		draggedObject = [[personsArrayController arrangedObjects] objectAtIndex:dragRow];
	}
	else if (aTableView == modesTableView) {
		draggedObject = [[modesArrayController arrangedObjects] objectAtIndex:dragRow];
	}
	
	int destPriority = row;
	int sourcePriority = [[draggedObject valueForKey:@"priority"] intValue];
		
	if (destPriority > sourcePriority) {
		destPriority--;
	}
	[draggedObject setValue:[NSNumber numberWithInt:destPriority] forKey:@"priority"];
	
	/*if (aTableView == accountsTableView) {
		draggedObject = [[accountsArrayController arrangedObjects] objectAtIndex:dragRow];
	}
	else if (aTableView == personsTableView) {
		draggedObject = [[personsArrayController arrangedObjects] objectAtIndex:dragRow];
	}
	else if (aTableView == modesTableView) {
		draggedObject = [[modesArrayController arrangedObjects] objectAtIndex:dragRow];
	}*/
	
	if (aTableView == accountsTableView) {
		[[documentPropertiesController document] rearrangeAccountsArrayControllers:self];
	}
	else if (aTableView == personsTableView) {
		[[documentPropertiesController document] rearrangePersonsArrayControllers:self];
		[personsArrayController rearrangeObjects];
	}
	else if (aTableView == modesTableView) {
		[[documentPropertiesController document] rearrangeModesArrayControllers:self];
	}
	
	/*NSManagedObjectContext *managedObjectContext = [documentPropertiesController managedObjectContext];
	NSEntityDescription *entityDescription;
	
	if (aTableView == accountsTableView) {
		entityDescription = [NSEntityDescription entityForName:EntityNameAccount inManagedObjectContext:managedObjectContext];
	}
	else if (aTableView == modesTableView) {
		entityDescription = [NSEntityDescription entityForName:EntityNameMode inManagedObjectContext:managedObjectContext];
	}

	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	[request setEntity:entityDescription];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"priority == %@", [NSNumber numberWithInt:dragRow]];
	[request setPredicate:predicate];
	
	NSManagedObject* dragEntity;
	
	NSError* error = nil;
	NSArray* array = [managedObjectContext executeFetchRequest:request error:&error];
	if (array == nil) {
		// TODO: Deal with error...
	}
	else {
		dragEntity = [array objectAtIndex:0];
	}
	
	if ((dragRow != row) && (dragRow - row != -1)) {
		// Entity dragged to another row.
		
		if (dragRow > row) {
			// Entity dragged up.
			predicate = [NSPredicate predicateWithFormat:@"priority >= %@ AND priority < %@", [NSNumber numberWithInt:row], [NSNumber numberWithInt:dragRow]];
		}
		else {
			// Entity dragged down.
			predicate = [NSPredicate predicateWithFormat:@"priority < %@ AND priority > %@", [NSNumber numberWithInt:row], [NSNumber numberWithInt:dragRow]];
		}
		[request setPredicate:predicate];
		
		NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"priority" ascending:YES];
		[request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
		[sortDescriptor release];

		array = [managedObjectContext executeFetchRequest:request error:&error];
		if (array == nil) {
			// TODO: Deal with error...
		}
		else {
			int i;
			
			if (dragRow > row) {
				// Drag entity dragged up, intermediate entities shifted down.
				for (i = 0; i < [array count]; i++) {
					NSManagedObject* entity = [array objectAtIndex:i];
					[entity setValue:[NSNumber numberWithInt:(row + i + 1)] forKey:@"priority"];
				}
				[dragEntity setValue:[NSNumber numberWithInt:row] forKey:@"priority"];
			}
			else {
				// Drag entity dragged down, intermediate entities shifted up.
				for (i = 0; i < [array count]; i++) {
					NSManagedObject* entity = [array objectAtIndex:i];
					[entity setValue:[NSNumber numberWithInt:(dragRow + i)] forKey:@"priority"];
				}
				[dragEntity setValue:[NSNumber numberWithInt:row-1] forKey:@"priority"];
			}
		}
		
	}
	
	if (aTableView == accountsTableView) {
		[[documentPropertiesController accountsArrayController] rearrangeObjects];
	}
	else if (aTableView == modesTableView) {
		[[documentPropertiesController modesArrayController] rearrangeObjects];
	}*/
	
	return YES;
}


#pragma mark -
#pragma mark === IBActions ===

/**
 * Action for the accountsModesAssociationModesTableView.
 */
- (IBAction)accountsModesAssociationModesTableViewClicked:(id)sender {
	int clickedRow = [sender clickedRow];
	if (clickedRow > -1 && [sender clickedColumn] == 1) {
		NSManagedObject* mode = [[[documentPropertiesController modesArrayController] arrangedObjects] objectAtIndex:clickedRow];
		NSManagedObject* account = [documentPropertiesController selectedAccount];
		NSMutableSet* availableModes = [account mutableSetValueForKey:@"availableModes"];
		NSMutableSet* availableForAccounts = [mode mutableSetValueForKey:@"availableForAccounts"];
		
		if ([availableModes member:mode]) {
			/*
			 * The clicked mode is member of currently selected account. It should
			 * be removed from available modes.
			 *
			 * If it is the last available mode, an alert warns the user the operation
			 * can not be performed.
			 */
			if ([availableModes count] == 1) {
				NSAlert* alert = [[[NSAlert alloc] init] autorelease];
				[alert setMessageText:NSLocalizedString(@"lastAvailableModeAlertMessage", nil)];
				[alert setInformativeText:NSLocalizedString(@"lastAvailableModeAlertInfo", nil)];
				[alert addButtonWithTitle:NSLocalizedString(@"lastAvailableModeAlertInfoButton", nil)];
				[alert setIcon:[[NSImage alloc] initByReferencingFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Barred_64x64.png"]]];
				[alert beginSheetModalForWindow:[documentPropertiesController window] modalDelegate:nil didEndSelector:nil contextInfo:nil];
			}
			else {
				// Performing other tests before removing the mode from available ones.
				
				// Fetching all operations for the selected account and mode.
				NSManagedObjectContext* managedObjectContext = [documentPropertiesController managedObjectContext];
				NSEntityDescription* entityDescription = [NSEntityDescription entityForName:@"Operation" inManagedObjectContext:managedObjectContext];
				NSFetchRequest* request = [[[NSFetchRequest alloc] init] autorelease];
				[request setEntity:entityDescription];
				NSPredicate* predicate = [NSPredicate predicateWithFormat:@"account == %@ AND mode == %@", account, mode];
				[request setPredicate:predicate];
				
				NSArray* operationsOfThisMode = [managedObjectContext executeFetchRequest:request error:NULL];				
				int numberOfOperationsOfThisMode = [operationsOfThisMode count];
				if (numberOfOperationsOfThisMode > 0) {
					/*
					 * Operations are associated to this mode and account. Setting the mode
					 * unavailable for this account involves the deletion of these operations,
					 * what requires user's confirmation.
					 */
					NSAlert* alert = [[[NSAlert alloc] init] autorelease];
					[alert setMessageText:[NSString stringWithFormat:NSLocalizedString(@"managingOperationsRemovingAvailableModeAlertMessage", nil), [mode valueForKey:@"name"], [account valueForKey:@"name"]]];
					[alert setInformativeText:[NSString stringWithFormat:NSLocalizedString(@"managingOperationsRemovingAvailableModeAlertInfo", nil), numberOfOperationsOfThisMode]];
					[alert addButtonWithTitle:NSLocalizedString(@"managingOperationsRemovingAvailableModeAlertButtonNo", nil)];
					[alert addButtonWithTitle:NSLocalizedString(@"managingOperationsRemovingAvailableModeAlertButtonYes", nil)];
					[alert setIcon:[NSImage imageNamed:@"Barred_64x64"]];
					
					NSDictionary *alertContextInfo = [[NSDictionary dictionaryWithObjectsAndKeys:alertContextManagingOperations, alertContextInfoContextKey, mode, alertContextInfoManagingOperationsModeKey, account, alertContextInfoManagingOperationsAccountKey, operationsOfThisMode, alertContextInfoManagingOperationsOperationsKey, nil] retain];
					[alert beginSheetModalForWindow:[documentPropertiesController window] modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:alertContextInfo];
				}
				else {
					/*
					 * No operation associated to this mode for the selected account. The
					 * mode can be made unavailable for this account.
					 */
					[availableModes removeObject:mode];
					[[documentPropertiesController managedObjectContext] processPendingChanges];
				}
			}
		}
		else {
			/*
			 * The clicked mode is not member of currently selected account. It will
			 * be added to available modes.
			 */
			[availableModes addObject:mode];
			[[documentPropertiesController managedObjectContext] processPendingChanges];
		}
		
		[accountsModesAssociationModesTableView reloadData];
	}
}

/**
 * Action for the 'modesTableView'.
 */
- (IBAction)modesTableViewClicked:(id)sender {
	int clickedRow = [sender clickedRow];
	if (clickedRow > -1 && [sender clickedColumn] == 1) {
		NSManagedObjectContext* managedObjectContext = [documentPropertiesController managedObjectContext];
		NSManagedObject* mode = [[[documentPropertiesController modesArrayController] arrangedObjects] objectAtIndex:clickedRow];

		if ([[mode valueForKey:@"allowsValueDate"] boolValue]) {
			
			/*
			 * Disabling the value date. Warning the user current value dates for operations of
			 * this mode will be lost.
			 */
			
			// Constructing the alert
			NSAlert* alert = [[[NSAlert alloc] init] autorelease];
			[alert setMessageText:[NSString stringWithFormat:NSLocalizedString(@"removingValueDatesConfirmationAlertMessage", nil), [mode valueForKey:@"name"]]];
			[alert setInformativeText:[NSString stringWithFormat:NSLocalizedString(@"removingValueDatesConfirmationAlertInfo", nil), [[mode valueForKey:@"operations"] count]]];
			[alert addButtonWithTitle:NSLocalizedString(@"removingValueDatesConfirmationAlertButtonNo", nil)];
			[alert addButtonWithTitle:NSLocalizedString(@"removingValueDatesConfirmationAlertButtonYes", nil)];
			[alert setIcon:[[NSImage alloc] initByReferencingFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Barred_64x64.png"]]];
			
			// Constructing the context info dictionary. Contains the context key and the mode.
			NSDictionary* contextInfo = [[NSDictionary dictionaryWithObjectsAndKeys:alertContextLosingValueDates, alertContextInfoContextKey, mode, AlertContextInfoLosingValueDatesModeKey, nil] retain];
			
			[alert beginSheetModalForWindow:[documentPropertiesController window] modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:contextInfo];
		}
		
		else {
			/*
			 * Enabling the value date. Operations for this mode currently have no value
			 * date. All values will be set to the operation date.
			 */
			[mode setValue:[NSNumber numberWithBool:YES] forKey:@"allowsValueDate"];

			NSEnumerator* operations = [[mode valueForKey:@"operations"] objectEnumerator];
			NSManagedObject* operation;
			while (operation = [operations nextObject]) {
				[operation setValue:[operation valueForKey:@"operationDate"] forKey:@"valueDate"];
			}
			[mode setValue:[NSNumber numberWithBool:YES] forKey:@"allowsValueDate"];
		}
	}
}


#pragma mark -
#pragma mark === Alerts ===

/**
 * Handles termination of an alert.
 *
 * An alert of this class requires several kinds of information to be provided to the
 * return selector of the alert, which is done through the use of the 'contextInfo'
 * argument which is a 'NSDictionary' instance. All alerts are expected to use
 * dictionaries for their 'contextInfo'.
 */
- (void)alertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo {
	NSDictionary *alertContextInfo = (NSDictionary *)contextInfo;
	printf("alert:%s\n", [[alertContextInfo valueForKey:alertContextInfoContextKey] cString]);
	if ([[alertContextInfo valueForKey:alertContextInfoContextKey] isEqualToString:alertContextManagingOperations]) {
		if (returnCode == NSAlertSecondButtonReturn) {
			// The user chose yes.
			[self removeAsAvailableMode:[alertContextInfo valueForKey:alertContextInfoManagingOperationsModeKey] fromAccount:[alertContextInfo valueForKey:alertContextInfoManagingOperationsAccountKey] deletingOperations:[alertContextInfo valueForKey:alertContextInfoManagingOperationsOperationsKey]];
		}
	}
	
	else if ([[alertContextInfo valueForKey:alertContextInfoContextKey] isEqualToString:alertContextLosingValueDates]) {
		if (returnCode == NSAlertSecondButtonReturn) {
			// The user chose 'Yes'.
			NSManagedObject* mode = [alertContextInfo valueForKey:AlertContextInfoLosingValueDatesModeKey];
			NSEnumerator* operations = [[mode valueForKey:@"operations"] objectEnumerator];
			NSManagedObject* operation;
			while (operation = [operations nextObject]) {
				[operation setValue:nil forKey:@"valueDate"];
			}
			[mode setValue:[NSNumber numberWithBool:NO] forKey:@"allowsValueDate"];
		}
	}
	
	[alertContextInfo release];
}

/*
 * Removes the specified mode from the available modes of the selected account. If the specified
 * array is not nil, the contained operations are deleted too.
 */
- (void)removeAsAvailableMode:(NSManagedObject *)mode fromAccount:(NSManagedObject *)account deletingOperations:(NSArray *)operations {
	// Removing mode from available modes of account.
	[[account mutableSetValueForKey:@"availableModes"] removeObject:mode];
	
	if (operations != nil && [operations count] > 0) {
		// Deleting the operations having this mode.
		NSManagedObjectContext *managedObjectContext = [documentPropertiesController managedObjectContext];
		// Example: new-generation loop
		for (id loopItem in operations) {
			[managedObjectContext deleteObject:loopItem];
		}
		[managedObjectContext processPendingChanges];
	}	
}

@end
