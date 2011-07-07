//
//  PropertiesAccountsTableController.h
//  Ges
//
//  Created by NeoJF on 17/10/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "ModelConstants.h"
#import "DocumentPropertiesConstants.h"
#import "PasteboardTypes.h"

#import "DocumentPropertiesController.h"


/*
 * Alert context
 */

// Alert identification keys
static NSString* alertContextManagingOperations = @"alertContextManagingOperations";
static NSString* alertContextLosingValueDates = @"alertContextLosingValueDates";

// Alert context dictionary keys
static NSString* alertContextInfoContextKey = @"alertContextInfoContext";
static NSString* alertContextInfoManagingOperationsModeKey = @"alertContextInfoManagingOperationsMode";
static NSString* alertContextInfoManagingOperationsAccountKey = @"alertContextInfoManagingOperationsAccount";
static NSString* alertContextInfoManagingOperationsOperationsKey = @"alertContextInfoManagingOperationsOperations";
static NSString* AlertContextInfoLosingValueDatesModeKey = @"AlertContextInfoLosingValueDatesMode";

@interface PropertiesEntitiesTableController : NSObject {

	// Table views
	IBOutlet NSTableView *accountsModesAssociationModesTableView;
	IBOutlet NSTableView *accountsTableView;
	IBOutlet NSTableView *personsTableView;
	IBOutlet NSTableView *modesTableView;

	// Dependences
	IBOutlet DocumentPropertiesController	*documentPropertiesController;
	IBOutlet NSArrayController				*accountsArrayController;
	IBOutlet NSArrayController				*personsArrayController;
	IBOutlet NSArrayController				*modesArrayController;
	MyDocument								*document;
}


/*
 * Life cycle
 */
- (void)awakeFromNib;


/*
 * KVO
 */
- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(id)context;


/*
 * Drag'n'drop management
 */
- (BOOL)tableView:(NSTableView *)tv writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard*)pboard;
- (NSDragOperation)tableView:(NSTableView*)tv validateDrop:(id <NSDraggingInfo>)info proposedRow:(int)row proposedDropOperation:(NSTableViewDropOperation)op;
- (BOOL)tableView:(NSTableView *)aTableView acceptDrop:(id <NSDraggingInfo>)info row:(int)row dropOperation:(NSTableViewDropOperation)operation;


/*
 * IBActions
 */
- (IBAction)accountsModesAssociationModesTableViewClicked:(id)sender;
- (IBAction)modesTableViewClicked:(id)sender;


/*
 * Alerts
 */
- (void)alertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo;
- (void)removeAsAvailableMode:(NSManagedObject *)mode fromAccount:(NSManagedObject *)account deletingOperations:(NSArray *)operationsArray;

@end
