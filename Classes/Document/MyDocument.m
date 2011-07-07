/*  MyDocument.m
 *  Ges
 *
 *  Created by Romain Champourlier on 17/07/05. All rights reserved.
 */

/**
 * Override of the NSPersistentDocument class for the specific document managed by this
 * application.
 *
 * Delegate for:
 *	- the main window.
 *
 */


#import "MyDocument.h"


static NSString* softwareVersionPersistentStoreMetadataKey = @"SoftwareVersion";
static NSString* currentVersion = @"0.8.1";


@interface DocumentPropertiesController : NSObject
- (id)initWithDocument:(NSDocument *)document;
@end

@interface MyDocument (PrivateMethods)
- (IBAction)cloneOperations:(id)sender;
@end

@implementation MyDocument


#pragma mark -
#pragma mark === Object's life ===

- (id)init {
#ifdef MY_DOCUMENT_TRACE_LIFE_CYCLE
	printf("IN  [MyDocument init]\n");
#endif

	self = [super init];
	if (self != nil) {
		operationsRearrangingTimer = nil;
		
		/*
		 * These 3 variables are used to save the last values of
		 * 'selection.account', 'selection.mode' and 'selection.type'
		 * observed properties of the 'operationsArrayController' since
		 * options of the KVO observeValue... method are unavailable for
		 * the NSArrayController class.
		 */
		/*selectionAccountLastValue = nil;
		selectionModeLastValue = nil;
		selectionTypeLastValue = nil;*/
		
		// Controllers
		documentPropertiesController = nil;
		
		/* These flags are updated within several methods that are called during the loading
		 * of the application, the document, and CoreData's data. Depending on the value of
		 * this flags, some actions are triggered in other classes.
		 */
		isAccountsArrayControllerLoaded = NO;
		isEditionSelectionSourceListViewFilled = NO;
		isManagedObjectContextLoaded = NO;
		isPersonsArrayControllerLoaded = NO;
		isPostsArrayControllerLoaded = NO;
	}
	
#ifdef MY_DOCUMENT_TRACE_LIFE_CYCLE
	printf("OUT [MyDocument init]\n");
#endif	
	
	return self;
}

- (void)dealloc {
#ifdef MY_DOCUMENT_TRACE_LIFE_CYCLE
	printf("[MyDocument dealloc]\n");
#endif
	
	[super dealloc];
	
#ifdef MY_DOCUMENT_TRACE_LIFE_CYCLE
	printf("[MyDocument dealloc] END\n");
#endif
}

- (void)awakeFromNib {
#ifdef MY_DOCUMENT_TRACE_LIFE_CYCLE
	printf("IN  [MyDocument awakeFromNib]\n");
#endif
	
	/* Sets the sort descriptors for entities' array controllers.
	 * All entities will appear sorted by 'priority' in any view using the
	 * array controller's 'arrangedObjects' property.
	 */
	NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"priority" ascending:YES];
	NSArray* sortDescriptorsArray = [NSArray arrayWithObject:sortDescriptor];
	[accountsArrayController setSortDescriptors:sortDescriptorsArray];
	[modesArrayController setSortDescriptors:sortDescriptorsArray];
	[typesArrayController setSortDescriptors:sortDescriptorsArray];
	[selectedOperationAvailableModesArrayController setSortDescriptors:sortDescriptorsArray];
	
	// TESTING: I hope this will prevent cases where main array controllers are not loaded
	//[accountsArrayController prepareContent];
	//[modesArrayController prepareContent];
	//[typesArrayController prepareContent];
	// Load data for all known array controllers
	NSError *error;
	if (![accountsArrayController fetchWithRequest:nil merge:YES error:&error] ||
		![accountGroupsArrayController fetchWithRequest:nil merge:YES error:&error] ||
		![personsArrayController fetchWithRequest:nil merge:YES error:&error] ||
		![operationsArrayController fetchWithRequest:nil merge:YES error:&error] ||
		![modesArrayController fetchWithRequest:nil merge:YES error:&error] ||
		![typesArrayController fetchWithRequest:nil merge:YES error:&error] ||
		![postsArrayController fetchWithRequest:nil merge:YES error:&error]) {
		/* The first causing an error stops the execution of the if's condition. If no error happens,
		 * all array controllers are fetched.
		 */
		//printf("errorDescription: %s\n", [[error localizedDescription] CSTRING]);
		printf("error while loading array controllers\n");
	}
	else {
		printf("all array controllers loaded\n");
		[editionSelectionSourceListController fillSourceListView];
		/* Called only once MyDocument is awakeFromNib, since doing it when accountsBalanceController is awake from nib is to early, data model not being loaded at the moment (but required).
		 */
		[accountsBalanceController addObservers];
	}
	
#ifdef MY_DOCUMENT_TRACE_LIFE_CYCLE
	printf("OUT [MyDocument awakeFromNib]\n");
#endif	
}

- (void)addObservers {
#ifdef MY_DOCUMENT_TRACE_LIFE_CYCLE
	printf("IN  [MyDocument addObservers]\n");
#endif
	
	[operationsArrayController addObserver:self forKeyPath:@"selection" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
	
#ifdef MY_DOCUMENT_TRACE_LIFE_CYCLE
	printf("OUT [MyDocument addObservers]\n");
#endif
}

- (void)removeObservers {
#ifdef MY_DOCUMENT_TRACE_LIFE_CYCLE
	printf("[MyDocument removeObservers]\n");
#endif
		
#ifdef MY_DOCUMENT_TRACE_LIFE_CYCLE
	printf("[MyDocument removeObservers] END\n");
#endif	
}

#pragma mark -
#pragma mark === Data ===

/**
 Adds an operation.
 
 If configuration information has not been set, an alert is displayed.
 */
- (IBAction)addOperation:(id)sender {
#ifdef MY_DOCUMENT_TRACE_DATA
	printf("[MyDocument addOperation:]\n");
#endif
	
#ifdef MY_DOCUMENT_BENCHMARK
	NSDate* start = [NSDate date];
#endif
	
	if ([[accountsArrayController content] count] == 0
		|| [[modesArrayController content] count] == 0
		|| [[typesArrayController content] count] == 0) {

		/*
		 * No operation can be added, a category is lacking: account, mode or
		 * type.
		 */
		NSAlert* alert = [[[NSAlert alloc] init] autorelease];
		[alert setMessageText:NSLocalizedString(@"configurationNeededAlertMessage", nil)];
		[alert setInformativeText:NSLocalizedString(@"configurationNeededAlertInfo", nil)];
		[alert addButtonWithTitle:NSLocalizedString(@"configurationNeededAlertButtonGoto", nil)];
		[alert addButtonWithTitle:NSLocalizedString(@"configurationNeededAlertButtonCancel", nil)];
		[alert setIcon:[[NSImage alloc] initByReferencingFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Barred_64x64.png"]]];
		
		NSDictionary *contextInfoDict = [[NSDictionary dictionaryWithObjectsAndKeys:AlertContextInfoContextKey, AlertContextInfoConfigurationNeeded, nil] retain]; // TODO: confirm retain is needed here
		[alert beginSheetModalForWindow:[self windowForSheet] modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:contextInfoDict];
	}
	
	else {
		[self addOperation];
		// TODO: May be useful to find something faster
		//[operationsArrayController rearrangeObjects];
	}
	
#ifdef MY_DOCUMENT_BENCHMARK
	printf("[MyDocument addOperation:] %lfs\n", [[NSDate date] timeIntervalSinceDate:start]);
#endif
	
#ifdef MY_DOCUMENT_TRACE_DATA
	printf("[MyDocument addOperation:] END\n");
#endif	
}

/**
 * Adds a positive operation.
 *
 * Calls the 'addOperation:' method. Then sets the value of the operation to
 * a positive value and selects the value's text.
 */
- (IBAction)addOperationCredit:(id)sender {
#ifdef MY_DOCUMENT_TRACE_DATA
	printf("[MyDocument addOperationCredit:]\n");
#endif	

	[self addOperation:sender];
	[operationsArrayController setValue:[NSDecimalNumber numberWithInt:10] forKeyPath:@"selection.value"];
	[editionValueTextField selectText:self];

#ifdef MY_DOCUMENT_TRACE_DATA
	printf("[MyDocument addOperationCredit:] END\n");
#endif	
}

/**
 * Adds a negative operation.
 *
 * Calls the 'addOperation:' method. Then sets the value of the operation to a
 * negative value and selects the text after the sign.
 */
- (IBAction)addOperationDebit:(id)sender {
#ifdef MY_DOCUMENT_TRACE_DATA
	printf("[MyDocument addOperationDebit:]\n");
#endif	
	
	[self addOperation:sender];
	[operationsArrayController setValue:[NSDecimalNumber numberWithInt:-10] forKeyPath:@"selection.value"];
	[editionValueTextField selectText:self];
	
	// Selecting text after minus sign.
	NSText* textEditor = [[self windowForSheet] fieldEditor:YES forObject:editionValueTextField];
	NSRange range = {1, 5};
	[textEditor setSelectedRange:range];

#ifdef MY_DOCUMENT_TRACE_DATA
	printf("[MyDocument addOperationDebit:] END\n");
#endif	
}

- (void)addOperation {
#ifdef MY_DOCUMENT_TRACE_DATA
	printf("[MyDocument addOperation]\n");
#endif	

#ifdef MY_DOCUMENT_BENCHMARK
	NSDate* start = [NSDate date];
#endif
	
	NSManagedObjectContext* managedObjectContext = [self managedObjectContext];
	NSCalendarDate* today = [NSCalendarDate date];
	NSCalendarDate* todayMidday = [NSCalendarDate dateWithYear:[today yearOfCommonEra] month:[today monthOfYear] day:[today dayOfMonth] hour:12 minute:0 second:0 timeZone:nil];
	NSManagedObject* newOperation = [NSEntityDescription insertNewObjectForEntityForName:EntityNameOperation inManagedObjectContext:managedObjectContext];
	[newOperation setValue:NSLocalizedString(@"operationDefaultDescription", nil) forKey:@"operationDescription"];
	[newOperation setValue:todayMidday forKey:@"operationDate"];
	[newOperation setValue:todayMidday forKey:@"valueDate"];
	
	// TODO: implement the mechanism in FilterController with saving instead of searching each time
	// Setting operation's account
	
	NSFetchRequest *req = [[NSFetchRequest alloc] init];
	[req setEntity:[NSEntityDescription entityForName:EntityNameAccount inManagedObjectContext:managedObjectContext]];
	[req setPredicate:[NSPredicate predicateWithFormat:@"filterState == 1"]];
	[req setSortDescriptors:[SortDescriptorsController prioritySortDescriptors]];
	NSArray *results = [managedObjectContext executeFetchRequest:req error:NULL];
	NSManagedObject *account = [results objectAtIndex:0];
	[newOperation setValue:account forKey:@"account"];
	//printf("account: %s\n", [[account valueForKey:@"name"] cString]);
	
	// Setting operation's mode
	NSEnumerator *accountAvailableModesEnumerator = [[account valueForKey:@"availableModes"] objectEnumerator];
	NSManagedObject *availableMode;
	NSManagedObject *keptMode = [accountAvailableModesEnumerator nextObject];
	while (availableMode = [accountAvailableModesEnumerator nextObject]) {
		if ([[availableMode valueForKey:@"priority"] intValue] < [[keptMode valueForKey:@"priority"] intValue]) {
			keptMode = availableMode;
		}
	}
	[newOperation setValue:keptMode forKey:@"mode"];
	
	// Setting operation's post
	NSEnumerator *postsEnumerator = [[postsArrayController arrangedObjects] objectEnumerator];
	NSManagedObject *post;
	NSManagedObject *keptPost = nil;
	while ((post = [postsEnumerator nextObject]) && keptPost == nil) {
		int postFilterState = [[post valueForKey:@"filterState"] intValue];
		if (postFilterState == NSOnState || postFilterState == NSMixedState) {
			keptPost = post;
		}
	}
	if (keptPost == nil) {
		keptPost = [[postsArrayController arrangedObjects] objectAtIndex:0];
		[keptPost setValue:[NSNumber numberWithInt:1] forKey:@"filterState"];
	}
	//printf("post: %s\n", [[keptPost valueForKey:@"name"] cString]);

	[newOperation setValue:keptPost forKey:@"post"];
	/* Type automatically set along with the post (see the setPost: method definition
	 * in the OperationManagedObject implementation.
	 */
	
	[newOperation setValue:[[personsArrayController arrangedObjects] objectAtIndex:0] forKey:@"person"];
	
	[operationsArrayController rearrangeObjects];
	[operationsArrayController setSelectedObjects:[NSArray arrayWithObject:newOperation]];
	
#ifdef MY_DOCUMENT_BENCHMARK
	printf("[MyDocument addOperation] %lfs\n", [[NSDate date] timeIntervalSinceDate:start]);
#endif
	
#ifdef MY_DOCUMENT_TRACE_DATA
	printf("[MyDocument addOperation] END\n");
#endif		
}

- (IBAction)cloneOperations:(id)sender {
#ifdef MY_DOCUMENT_TRACE_DATA
	printf("IN  [MyDocument cloneOperations:]\n");
#endif
	
	NSMutableArray *newOperationsArray = [NSMutableArray array];
	
	NSEnumerator *selectedOperations = [[operationsArrayController selectedObjects] objectEnumerator];
	OperationManagedObject *operation;
	while (operation = (OperationManagedObject *)[selectedOperations nextObject]) {
		
		NSCalendarDate* today = [NSCalendarDate date];
		NSCalendarDate* todayMidday = [NSCalendarDate dateWithYear:[today yearOfCommonEra] month:[today monthOfYear] day:[today dayOfMonth] hour:12 minute:0 second:0 timeZone:nil];
		
		OperationManagedObject *newOperation = [self cloneOperation:operation];
		[newOperation setValue:todayMidday forKey:@"valueDate"];
		[newOperation setValue:todayMidday forKey:@"operationDate"];

		[newOperation setValue:[NSNumber numberWithInt:POINTED_STATE_UNSET] forKey:@"pointedState"];

		[newOperationsArray addObject:newOperation];
	}
	
	[operationsArrayController rearrangeObjects];
	[operationsArrayController setSelectedObjects:newOperationsArray];
	
#ifdef MY_DOCUMENT_TRACE_DATA
	printf("OUT [MyDocument cloneOperations:]\n");
#endif
}

/*
 TODO: clean when setting transfer to none, cancel case, etc.
 
 Currently, sender is the "Transfer" popup menu within the edition view. The action
 is then called when the popup is edited.
 
 */
- (IBAction)settingTransfer:(id)sender {
#ifdef MY_DOCUMENT_TRACE_DATA
	printf("IN  [MyDocument settingTransfer:]\n");
#endif	
	
	NSArray *selectedOperationsArray = [[operationsArrayController selectedObjects] retain]; // don't know why I have to retain it there!
	
	if ([sender indexOfSelectedItem] == 0) {
		// "No transfer" item selected
		for (id operation in selectedOperationsArray) {
			
			// Raise an alert about removing the transfer involving associated operation is deleted.
			if ([operation valueForKey:@"transferDualOperation"] != nil) {
				// TODO: provide more details in the alert screen
				NSAlert* alert = [[[NSAlert alloc] init] autorelease];
				[alert setMessageText:NSLocalizedString(@"AlertTextEditionTransferRemoveAssociatedOperationMessage", nil)];
				[alert setInformativeText:NSLocalizedString(@"AlertTextEditionTransferRemoveAssociatedOperationInfo", nil)];
				[alert addButtonWithTitle:NSLocalizedString(@"AlertTextEditionTransferRemoveAssociatedOperationButtonConfirm", nil)];
				[alert addButtonWithTitle:NSLocalizedString(@"AlertTextEditionTransferRemoveAssociatedOperationButtonCancel", nil)];
				[alert setIcon:[[NSImage alloc] initByReferencingFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Barred_64x64.png"]]]; // TODO: Make and use a warning icon	
				
				NSDictionary *contextInfoDict = [NSDictionary dictionaryWithObjectsAndKeys:AlertContextInfoContextKey, AlertContextInfoTransferOperationKey, AlertContextInfoTransferRemovingDualOperation, [operation objectID], nil];
				[alert beginSheetModalForWindow:[self windowForSheet] modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:[contextInfoDict retain]];
			}
		}
	}
	else {
		id selectedAccount = [[accountsArrayController arrangedObjects] objectAtIndex:[sender indexOfSelectedItem] - 1];
		for (id operation in selectedOperationsArray) {
			if ([operation valueForKey:@"transferDualOperation"] == nil) {
				OperationManagedObject *transferDualOperation = [self cloneOperation:operation];
				[transferDualOperation setValue:selectedAccount forKey:@"account"];
				[transferDualOperation setValue:[NSNumber numberWithFloat:-[[operation valueForKey:@"value"] floatValue]]];
				[operation setValue:transferDualOperation forKey:@"transferDualOperation"];
				[transferDualOperation setValue:operation forKey:@"transferDualOperation"];
			}
			else {
				[operation setValue:selectedAccount forKeyPath:@"transferDualOperation.account"];
			}
		}
		[operationsArrayController rearrangeObjects];
		[operationsArrayController setSelectedObjects:selectedOperationsArray];
	}
	[selectedOperationsArray release];
	
#ifdef MY_DOCUMENT_TRACE_DATA
	printf("OUT [MyDocument settingTransfer:]\n");
#endif		
}

- (void)addTypesSet {
#ifdef MY_DOCUMENT_TRACE_DATA
	printf("IN  [MyDocument addTypesSet]\n");
#endif	
	
	NSManagedObjectContext* managedObjectContext = [self managedObjectContext];

	NSString *defaultName;
	NSArray *typesSetWithDefaultName;
	unsigned int newModesCounter = -1;
	do {
		newModesCounter++;
		defaultName = [NSString stringWithFormat:@"%@ %u", NSLocalizedString(@"typesSetDefaultName", nil), newModesCounter];
		NSFetchRequest* request = [[[NSFetchRequest alloc] init] autorelease];
		[request setEntity:[NSEntityDescription entityForName:EntityNameTypesSet inManagedObjectContext:managedObjectContext]];
		[request setPredicate:[NSPredicate predicateWithFormat:@"name == %@", defaultName]];
		typesSetWithDefaultName = [managedObjectContext executeFetchRequest:request error:NULL];
	}
	while ([typesSetWithDefaultName count] > 0);
	
	NSManagedObject* newTypesSet = [NSEntityDescription insertNewObjectForEntityForName:EntityNameTypesSet inManagedObjectContext:managedObjectContext];
	
	/*NSMutableSet* typesMutableSet = [newTypesSet mutableSetValueForKey:@"types"];
	[typesMutableSet addObjectsFromArray:[typesArrayController content]];*/
	
	[newTypesSet setValue:[NSString stringWithFormat:defaultName, newTypeCount++] forKey:@"name"];
	[newTypesSet setValue:[NSNumber numberWithInt:0] forKey:@"priority"];
	
#ifdef MY_DOCUMENT_TRACE_DATA
	printf("OUT [MyDocument addTypesSet]\n");
#endif		
}

- (void)removeTypesSet:(PrioritizedManagedObject *)typesSet {
	printf("IN  [MyDocument removeTypesSet]\n");
	[typesSet prepareToRemoval];
	[[self managedObjectContext] deleteObject:typesSet];
	[[self managedObjectContext] processPendingChanges];
	printf("OUT [MyDocument removeTypesSet]\n");
}


#pragma mark -
#pragma mark === Manage document properties ===

- (IBAction)openDocumentProperties:(id)sender {
#ifdef MY_DOCUMENT_TRACE_METHODS
	printf("[MyDocument openDocumentProperties:]\n");
#endif
	
	if (documentPropertiesController == nil) {
		documentPropertiesController = [[DocumentPropertiesController alloc] initWithDocument:self];
	}
	[documentPropertiesController openWindow];
	
#ifdef MY_DOCUMENT_TRACE_METHODS
	printf("[MyDocument openDocumentProperties:] END\n");
#endif
}

/**
 * Called when the Document Properties sheet is closed. It is currently
 * the only sheet referring to MyDocument when closing.
 */
- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {
	printf("sheetDidEnd\n");
	[editionSelectionSourceListController fillSourceListView];
}

#pragma mark -
#pragma mark === Window controller associated methods ===

/**
 * Returns the name of the nib file associated to this document class.
 */
- (NSString *)windowNibName {
#ifdef MY_DOCUMENT_TRACE_OTHER
	printf("I/O [MyDocument windowNibName]\n");
#endif		

    return @"MyDocument";
}

/**
 * Performs interface initialization once it has been loaded from nib.
 */
- (void)windowControllerDidLoadNib:(NSWindowController *)windowController {
#ifdef MY_DOCUMENT_TRACE_LIFE_CYCLE
	printf("IN  [MyDocument windowControllerDidLoadNib:]\n");
#endif
	
    [super windowControllerDidLoadNib:windowController];
	[self setupToolbarForWindow:[windowController window]];
	
	// Manually setting some bindings
	
	[pointedStateSelectorView bind:@"selectedState" toObject:operationsArrayController withKeyPath:@"selection.pointedState" options:nil];
	NSDictionary *pointedStateEnabledOptions = [NSDictionary dictionaryWithObject:@"ArrayNotEmpty" forKey:NSValueTransformerNameBindingOption];
	[pointedStateSelectorView bind:@"enabled" toObject:operationsArrayController withKeyPath:@"selectedObjects" options:pointedStateEnabledOptions];
	
	/*
	 * Adding observers
	 * TODO: Indicate for what use.
	 */
	[self addObservers];
	
#ifdef MY_DOCUMENT_TRACE_LIFE_CYCLE
	printf("OUT [MyDocument windowControllerDidLoadNib:]\n");
#endif
}

- (NSError *)willPresentError:(NSError *)inError {
#ifdef MY_DOCUMENT_TRACE_METHODS
	printf("[MyDocument willPresentError:]\n");
#endif
	
	// The error is a Core Data validation error if its domain is NSCocoaErrorDomain and it is between
	// the minimum and maximum for Core Data validation error codes.
	if ([[inError domain] isEqualToString:NSCocoaErrorDomain]) {
		int errorCode = [inError code];
		if (errorCode >= NSValidationErrorMinimum && errorCode <= NSValidationErrorMaximum) {
			
			// If there are multiple validation errors, inError will be a NSValidationMultipleErrorsError
			// and all the validation errors will be in an array in the userInfo dictionary for key NSDetailedErrorsKey
			id detailedErrors = [[inError userInfo] objectForKey:NSDetailedErrorsKey];
			if (detailedErrors != nil) {
				
				// For this example we are only presenting the error messages for up to 3 validation errors at a time.
				// We are simply passing the NSLocalizedDescription for each error to the user, but one could instead
				// construct a customized, user-friendly error here. The error codes and userInfo dictionary
				// keys for validation errors are listed in <CoreData/CoreDataErrors.h>.
				
				unsigned numErrors = [detailedErrors count];							
				NSMutableString *errorString = [NSMutableString stringWithFormat:@"%u validation errors have occurred", numErrors];
				if (numErrors > 3)
					[errorString appendFormat:@".\nThe first 3 are:\n"];
				else
					[errorString appendFormat:@":\n"];
				
				unsigned i;
				for (i = 0; i < (numErrors > 3 ? 3 : numErrors); ++i) {
					[errorString appendFormat:@"%@\n", [[detailedErrors objectAtIndex:i] localizedDescription]];
				}
				
				NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:[inError userInfo]];
				[userInfo setObject:errorString forKey:NSLocalizedDescriptionKey];

#ifdef MY_DOCUMENT_TRACE_METHODS
				printf("[MyDocument willPresentError:] END\n");
#endif				
				return [NSError errorWithDomain:[inError domain] code:[inError code] userInfo:userInfo];
				
			} else {
				// As there is only one validation error, we are returning it verbatim to the user.
#ifdef MY_DOCUMENT_TRACE_METHODS
				printf("[MyDocument willPresentError:] END\n");
#endif
				return inError;
			}
		}
	}
	
#ifdef MY_DOCUMENT_TRACE_METHODS
	printf("[MyDocument willPresentError:] END\n");
#endif	
	return inError;
}


#pragma mark -
#pragma mark === KVO / Notifications selectors ===

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(id)context {
	
#ifdef MY_DOCUMENT_TRACE_KVO
	{
		char* objectName = "";
		if (object == operationsArrayController) {
			objectName = "operationsArrayController";
		}
		else if (object == accountsArrayController) {
			objectName = "accountsArrayController";
		}
		else if (object == modesArrayController) {
			objectName = "modesArrayController";
		}
		else if (object == personsArrayController) {
			objectName = "personsArrayController";
		}
		else if (object == postsArrayController) {
			objectName = "postsArrayController";
		}
		else if (object == typesArrayController) {
			objectName = "typesArrayController";
		}
		
		printf("IN  [MyDocument observeValueForKeyPath:%s ofObject:%s]\n", [keyPath cStringUsingEncoding:NSASCIIStringEncoding], objectName);
	}
#endif
	
	if (object == accountsArrayController) {
		isAccountsArrayControllerLoaded = YES;
	}
	else if (object == postsArrayController) {
		isPostsArrayControllerLoaded = YES;
	}
	else if (object == personsArrayController) {
		isPersonsArrayControllerLoaded = YES;
	}
	
	if (isAccountsArrayControllerLoaded && isPersonsArrayControllerLoaded && isPostsArrayControllerLoaded && !isEditionSelectionSourceListViewFilled) {
		isEditionSelectionSourceListViewFilled = YES;
		[editionSelectionSourceListController dataDidLoad];
	}
	
	if ([keyPath isEqualToString:@"selection"]) {
		if (lastOperationArrayControllerSelection != nil) {
			[lastOperationArrayControllerSelection removeObserver:self forKeyPath:@"account"];
		}
		NSArray *selectedOperations = [operationsArrayController valueForKey:@"selectedObjects"];
		if ([selectedOperations count] > 0) {
			lastOperationArrayControllerSelection = [selectedOperations objectAtIndex:0];
			[lastOperationArrayControllerSelection addObserver:self forKeyPath:@"account" options:0 context:NULL];
		}
		else {
			lastOperationArrayControllerSelection = nil;
		}
	}
	
	if ([keyPath isEqualToString:@"account"]) {
		printf("selection's account changed\n");
		// TODO: change mode if no more available for new selected account
		// TODO: show alert to the user if the selected account is not in the filter, in order to update the filter (add the account, or select it), or inform the operation will be hidden and rearrange the operations array controller to do it.
	}
	
#ifdef MY_DOCUMENT_TRACE_KVO
	printf("OUT [MyDocument observeValueForKeyPath:%s ofObject:]\n", [keyPath cStringUsingEncoding:NSASCIIStringEncoding]);
#endif
}


#pragma mark -
#pragma mark === Interface's events handling ===

/*
 * TODO: Should use a default or a constant to specify the time interval
 * the timer should wait before firing the rearrangement request.
 */
- (IBAction)operationDatePickerAction:(id)sender {
#ifdef MY_DOCUMENT_TRACE_METHODS
	printf("[MyDocument operationDatePickerAction:]\n");
#endif

	if (operationsRearrangingTimer == nil) {
		operationsRearrangingTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(rearrangeOperationsOnTimer:) userInfo:nil repeats:NO];
	}
	else {
		[operationsRearrangingTimer setFireDate:[[[NSDate alloc] initWithTimeIntervalSinceNow:1] autorelease]];
	}

#ifdef MY_DOCUMENT_TRACE_METHODS
	printf("[MyDocument operationDatePickerAction:] END\n");
#endif	
}

- (void)rearrangeOperationsOnTimer:(NSTimer*)aTimer {
#ifdef MY_DOCUMENT_TRACE_METHODS
	printf("[MyDocument rearrangeOperationsOnTimer:]\n");
#endif

	operationsRearrangingTimer = nil;
	//[operationsArrayController rearrangeObjects];
	// TODO: find an equivalent code for reordering the array controller, because since SnowLeopard this cause the selected operation to be deselected.
	
#ifdef MY_DOCUMENT_TRACE_METHODS
	printf("[MyDocument rearrangeOperationsOnTimer:] END\n");
#endif
}


#pragma mark -
#pragma mark === Delegate methods ===

/*
 * Called when the document's window (for which the document is the delegate) is going
 * to close.
 * It performs the unregistration of the observers registered manually with objects of
 * this document, to avoid deallocating objects having observers still registered.
 */
- (void)windowWillClose:(NSNotification*)aNotification {
#ifdef MY_DOCUMENT_TRACE_METHODS
	printf("[MyDocument windowWillClose]\n");
#endif

	//[modesArrayController removeObserver:self forKeyPath:@"selectedObject"];
	[self removeObservers];
		
#ifdef MY_DOCUMENT_TRACE_METHODS
	printf("[MyDocument windowWillClose] END\n");
#endif
}


#pragma mark -
#pragma mark === IBActions ===

/*
 'Delete' action response method for MyDocument.
 
 This method is intended to be reached through the responders chain. For this reason, other 'delete:' methods should be available in previous responders in case other entities should be deleted.
 
 Implements a special behavior when an operation with a transfer is deleted. The transfer link is removed, in order to unlink the several properties update when removing the first operation. The second is then marked for deletion.
 */
- (IBAction)delete:(id)sender {
#ifdef MY_DOCUMENT_TRACE_OTHER
	printf("[MyDocument delete:]\n");
#endif
	
	if ([displayModeViewController displayedModeView] == ModeViewEdition) {
		NSArray *operations = [operationsArrayController selectedObjects];
		for (id operation in operations) {
			if ([operation valueForKey:@"transferDualOperation"] != nil) {
				OperationManagedObject *transferDualOperation = [operation valueForKey:@"transferDualOperation"];
				[transferDualOperation setValue:nil forKey:@"transferDualOperation"];
				[operation setValue:nil forKey:@"transferDualOperation"];
				[operationsArrayController removeObject:transferDualOperation];
			}
			[operationsArrayController removeObject:operation];
		}
		//[operationsArrayController removeObjects:[operationsArrayController selectedObjects]];
	}
	[[self managedObjectContext] processPendingChanges];
	
#ifdef MY_DOCUMENT_TRACE_OTHER
	printf("[MyDocument delete:] END\n");
#endif	
}

/**
 * Target action of GUI controls reflecting properties of the selected operation.
 *
 * This action enables to perform several actions necessary when different properties
 * are changed:
 *	- Determine if the 'operationsArrayController' needs to be rearranged. This is
 * for example when the edited operation can no more be accepted by the filter.
 *	- In case the property changed is the account, determine if the mode is available
 * for the new account. In case it is not, select another mode and display a warning
 * message to indicate the change to the user.
 *
 * TODO:
 *	- Extends this technique for all editable properties of the operation that are taken
 * into account within the filter (dates, pointed and marked states, etc.).
 */
- (IBAction)propertyEdited:(id)sender {
#ifdef MY_DOCUMENT_TRACE_METHODS
	printf("[MyDocument propertyEdited:]\n");
#endif

	switch ([sender tag]) {

		case CONTROL_TAG_EDITION_ACCOUNT :
		{
			NSManagedObject* operation = [operationsArrayController valueForKey:@"selectedObject"];
			NSManagedObject* account = [operationsArrayController valueForKeyPath:@"selection.account"];
			NSManagedObject* oldMode = [operationsArrayController valueForKeyPath:@"selection.mode"];
			if (![[account valueForKey:@"availableModes"] containsObject:oldMode]) {
				// Current mode not available for new account.
				
				NSArray *selectedModes = [modesArrayController selectedObjects];
				NSSet *availableModes = [account valueForKey:@"availableModes"];
				NSManagedObject *mode = [selectedModes firstObjectCommonWithArray:[availableModes allObjects]];
				[operation setValue:mode forKey:@"mode"];
				
				NSAlert* alert = [[[NSAlert alloc] init] autorelease];
				[alert setMessageText:[NSString stringWithFormat:NSLocalizedString(@"editionAccountSelectedModeNotAvailableAlertMessage", nil), [oldMode valueForKey:@"name"], [account valueForKey:@"name"]]];
					[alert setInformativeText:[NSString stringWithFormat:NSLocalizedString(@"editionAccountSelectedModeNotAvailableAlertInfo", nil), [mode valueForKey:@"name"]]];
				[alert addButtonWithTitle:NSLocalizedString(@"editionAccountSelectedModeNotAvailableAlertButton", nil)];
				[alert setIcon:[[NSImage alloc] initByReferencingFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Barred_64x64.png"]]]; // TODO: Make and use a warning icon
				
				NSDictionary *contextInfo = [NSDictionary dictionaryWithObjectsAndKeys:AlertContextInfoContextKey, AlertContextInfoAccountSelectedModeNotAvailable, nil];
				[alert beginSheetModalForWindow:[self windowForSheet] modalDelegate:nil didEndSelector:nil contextInfo:contextInfo];
			}
				
			/*if (![filterController managedObjectAcceptedByFilter:[operationsArrayController valueForKeyPath:@"selection.account"]]) {
				// New account excluded from filter. Operations must be rearranged.
				[operationsArrayController rearrangeObjects];
			}*/
			break;
		}
			
		case CONTROL_TAG_EDITION_MODE :
		{
			/*if (![filterController managedObjectAcceptedByFilter:[operationsArrayController valueForKeyPath:@"selection.mode"]]) {
				[operationsArrayController rearrangeObjects];
			}*/
			break;
		}
			
		case CONTROL_TAG_EDITION_TYPE :
		{
			/*if (![filterController managedObjectAcceptedByFilter:[operationsArrayController valueForKeyPath:@"selection.type"]]) {
				[operationsArrayController rearrangeObjects];
			}*/
			break;
		}
	}

#ifdef MY_DOCUMENT_TRACE_METHODS
	printf("[MyDocument propertyEdited:] END\n");
#endif	
}

#pragma mark -
#pragma mark === Window's management ===

- (void)windowDidBecomeMain:(NSNotification*)aNotification {
#ifdef MY_DOCUMENT_TRACE_OTHER
	printf("IN  [MyDocument windowDidBecomeMain:]\n");
#endif

#ifdef MY_DOCUMENT_TRACE_NOTIFICATIONS
	printf("=== MyDocument posting notification:%s\n", [DocumentDidBecomeMainNotificationName cStringUsingEncoding:NSUTF8StringEncoding]);
#endif
	[[NSNotificationCenter defaultCenter] postNotificationName:DocumentDidBecomeMainNotificationName object:self];

#ifdef MY_DOCUMENT_TRACE_OTHER
	printf("OUT [MyDocument windowDidBecomeMain:]\n");
#endif
}

- (void)windowDidResignMain:(NSNotification*)aNotification {
#ifdef MY_DOCUMENT_TRACE_OTHER
	printf("IN  [MyDocument windowDidResignMain:]\n");
#endif

#ifdef MY_DOCUMENT_TRACE_NOTIFICATIONS
	printf("=== MyDocument posting notification:%s\n", [DocumentDidResignMainNotificationName cStringUsingEncoding:NSUTF8StringEncoding]);
#endif
	[[NSNotificationCenter defaultCenter] postNotificationName:DocumentDidResignMainNotificationName object:self];

#ifdef MY_DOCUMENT_TRACE_OTHER
	printf("OUT [MyDocument windowDidResignMain:]\n");
#endif
}

/**
 Callback method called when an alert did end.
 
 Currently used for the following alerts:
	- alert displayed when the document is lacking basic data (account, mode, type...),
	- alert displayed when the removal of a transfer is going to remove the corresponding dual
		operation.
 
 contextInfo is expected to be a dictionary with:
	- an object associated to the AlertContextInfoContextKey
 */
- (void)alertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo {
#ifdef MY_DOCUMENT_TRACE_OTHER
	printf("IN  [MyDocument alertDidEnd::]\n");
#endif

	NSDictionary *context = (NSDictionary *)contextInfo;
	NSString *contextString = [context objectForKey:AlertContextInfoContextKey];

	if ([contextString isEqualToString:AlertContextInfoConfigurationNeeded]) {
		if (returnCode == NSAlertFirstButtonReturn) {
			// "Go to document's configuration" button clicked
			[[alert window] orderOut:self];
			[self openDocumentProperties:self];
		}
	}
	else if ([contextString isEqualToString:AlertContextInfoTransferRemovingDualOperation]) {
		
		if (returnCode == NSAlertFirstButtonReturn) {
			// Confirmation button clicked. Transfer remains to "None" and dual operation is deleted.
			NSManagedObjectID *updatedOperationID = [context objectForKey:AlertContextInfoTransferRemovingDualOperation];
			
			NSManagedObject *updatedOperation = [[self managedObjectContext] objectWithID:updatedOperationID];
			OperationManagedObject *transferDualOperation = [updatedOperation valueForKey:@"transferDualOperation"];
			
			[updatedOperation setValue:nil forKey:@"transferDualOperation"];
			[transferDualOperation setValue:nil forKey:@"transferDualOperation"];
			[operationsArrayController removeObject:transferDualOperation];
			[operationsArrayController rearrangeObjects];
		}
		else {
			// Cancel button clicked. Transfer is changed back and dual operation is untouched.
			// TODO
		}
	}
	
	[context release];

#ifdef MY_DOCUMENT_TRACE_OTHER
	printf("OUT [MyDocument alertDidEnd::]\n");
#endif	
}

#pragma mark -
#pragma mark === Accessors ===

- (NSArray *)arrangedOperations {
#ifdef MY_DOCUMENT_TRACE_ACCESSORS
	printf("IN  [MyDocument arrangedOperations]\n");
#endif
	
	return [operationsArrayController arrangedObjects];
	
#ifdef MY_DOCUMENT_TRACE_ACCESSORS
	printf("OUT [MyDocument arrangedOperations]\n");
#endif
}

- (id <NibWindowController>)documentPropertiesController {
#ifdef MY_DOCUMENT_TRACE_ACCESSORS
	printf("I/O [MyDocument documentPropertiesController]\n");
#endif

	return documentPropertiesController;
}


#pragma mark -
#pragma mark === Dependences for document properties ===

- (void)addAccountToSelection:(NSManagedObject*)account {
	printf("IN  [MyDocument addAccountToSelection]\n");
	[accountsArrayController addSelectedObjects:[NSArray arrayWithObject:account]];
	printf("OUT [MyDocument addAccountToSelection]\n");
}

- (void)addModeToSelection:(NSManagedObject*)mode {
	printf("IN  [MyDocument addModeToSelection]\n");
	[modesArrayController addSelectedObjects:[NSArray arrayWithObject:mode]];
	printf("OUT [MyDocument addModeToSelection]\n");
}

- (void)addTypeToSelection:(NSManagedObject*)type {
	printf("IN  [MyDocument addTypeToSelection]\n");
	[typesArrayController addSelectedObjects:[NSArray arrayWithObject:type]];
	printf("OUT [MyDocument addTypeToSelection]\n");
}


// Maintaining model coherence
// TODO: should replace methods below.

- (void)rearrangeAccountsArrayControllers:(id)sender {
	printf("IN  [MyDocument rearrangeAccountsArrayControllers:]\n");
	if (sender != self) {
		[accountsArrayController rearrangeObjects];
	}
	if (sender != documentPropertiesController) {
		[documentPropertiesController rearrangeAccountsArrayControllers:self];
	}
	printf("OUT [MyDocument rearrangeAccountsArrayControllers:]\n");
}

- (void)rearrangePersonsArrayControllers:(id)sender {
	printf("IN  [MyDocument rearrangePersonsArrayControllers:]\n");
	if (sender != self) {
		[personsArrayController rearrangeObjects];
	}
	if (sender != documentPropertiesController) {
		[documentPropertiesController rearrangePersonsArrayControllers:self];
	}
	printf("OUT [MyDocument rearrangePersonsArrayControllers:]\n");
}

- (void)rearrangeModesArrayControllers:(id)sender {
	printf("IN  [MyDocument rearrangeModesArrayControllers:]\n");
	if (sender != self) {
		[modesArrayController rearrangeObjects];
		[selectedOperationAvailableModesArrayController rearrangeObjects];
	}
	if (sender != documentPropertiesController) {
		[documentPropertiesController rearrangeModesArrayControllers:self];
	}
	printf("OUT [MyDocument rearrangeModesArrayControllers:]\n");
}

- (void)rearrangePostsArrayControllers:(id)sender {
	printf("IN  [MyDocument rearrangePostsArrayControllers:]\n");
	if (sender != self) {
		[postsArrayController rearrangeObjects];
	}
	if (sender != documentPropertiesController) {
		[documentPropertiesController rearrangePostsArrayControllers:self];
	}
	printf("OUT [MyDocument rearrangePostsArrayControllers:]\n");
}

- (void)rearrangeTypesArrayControllers:(id)sender {
	printf("IN  [MyDocument rearrangeTypesArrayControllers:]\n");
	if (sender != self) {
		[typesArrayController rearrangeObjects];
	}
	if (sender != documentPropertiesController) {
		[documentPropertiesController rearrangeTypesArrayControllers:self];
	}
	printf("OUT [MyDocument rearrangeTypesArrayControllers:]\n");
}

#pragma mark -
#pragma mark === PrivateMethods ===

- (OperationManagedObject *)cloneOperation:(OperationManagedObject *)anOperation {
#ifdef MY_DOCUMENT_TRACE_DATA
	printf("IN  [MyDocument cloneOperation:]\n");
#endif
	
	NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
	OperationManagedObject *newOperation = (OperationManagedObject *)[NSEntityDescription insertNewObjectForEntityForName:EntityNameOperation inManagedObjectContext:managedObjectContext];
	
	// Setting data
	[newOperation setValue:[anOperation valueForKey:@"operationDescription"] forKey:@"operationDescription"];
	[newOperation setValue:[anOperation valueForKey:@"operationDate"] forKey:@"operationDate"];
	[newOperation setValue:[anOperation valueForKey:@"valueDate"] forKey:@"valueDate"];
	[newOperation setValue:[anOperation valueForKey:@"account"] forKey:@"account"];
	[newOperation setValue:[anOperation valueForKey:@"mode"] forKey:@"mode"];
	[newOperation setValue:[anOperation valueForKey:@"post"] forKey:@"post"];
	[newOperation setValue:[anOperation valueForKey:@"type"] forKey:@"type"];
	[newOperation setValue:[anOperation valueForKey:@"person"] forKey:@"person"];
	[newOperation setValue:[anOperation valueForKey:@"value"] forKey:@"value"];
	[newOperation setValue:[anOperation valueForKey:@"pointedState"] forKey:@"pointedState"];
	[newOperation setValue:[anOperation valueForKey:@"markedState"] forKey:@"markedState"];
	[newOperation setValue:[anOperation valueForKey:@"reference"] forKey:@"reference"];
	
#ifdef MY_DOCUMENT_TRACE_DATA
	printf("OUT [MyDocument cloneOperation:]\n");
#endif
	return newOperation;
}

#pragma mark -

@synthesize editionValueTextField;
@synthesize filterController;
@synthesize operationsArrayController;
@synthesize operationsRearrangingTimer;
@synthesize pointedStateSelectorView;
@synthesize toolbar;
@synthesize toolbarDisplayModeSelectionPopUpButton;
@synthesize toolbarSearchField;
@end
