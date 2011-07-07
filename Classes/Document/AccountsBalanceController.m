//
//  AccountsBalanceController.m
//  Ges
//
//  Created by Romain Champourlier on 31/12/08.
//  Copyright 2008 Galilée Conseil & Technologies. All rights reserved.
//

#import "AccountsBalanceController.h"


@implementation AccountsBalanceController

/**
 * Called when the instance is deallocated.
 * Performs the following task before deallocation:
 *	- removal of the registered observers
 */
- (void)dealloc {
	[self removeObservers];
	[super dealloc];
}

/**
 * Registers observers for events which need to be tracked because requiring
 * the balance to be calculated again.
 *
 * It currently relies on the text field displaying the balance for displayed
 * operations to update itself: the accounts' balance is updated each time
 * this one is updated.
 */
- (void)addObservers {
	[displayedOperationsBalanceTextField addObserver:self forKeyPath:@"objectValue" options:0 context:NULL];
	[operationsArrayController addObserver:self forKeyPath:@"selection.pointedState" options:0 context:NULL];
}

/**
 * Unregister the observers registered within the - (void)addObservers method.
 */
- (void)removeObservers {
	[displayedOperationsBalanceTextField removeObserver:self forKeyPath:@"objectValue"];
	[operationsArrayController removeObserver:self forKeyPath:@"selection.pointedState"];
}


#pragma mark -
#pragma mark === Managing balance ===

/**
 * Updates the values for both total balance and balance excluding disabled
 * operations fields.
 *
 * Performs the calculation for both values, going through every account whose
 * filterState property is equal to 1, then adding corresponding operations'
 * values.
 */
- (void)updateBalanceFieldsExcludingTotal:(BOOL)shouldExcludeTotal {
#ifdef ACCOUNTS_BALANCE_CONTROLLER_TRACE_METHODS
	printf("IN  [AccountsBalanceController updateBalanceFieldsExcludingTotal:]\n");
#endif
	
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	NSManagedObjectContext *managedObjectContext = [[[NSDocumentController sharedDocumentController] currentDocument] managedObjectContext];
	[request setEntity:[NSEntityDescription entityForName:EntityNameAccount inManagedObjectContext:managedObjectContext]];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"filterState == 1"];
	[request setPredicate:predicate];
	
	double accountsBalance = 0;
	double accountsBalanceExcludingDisabledOperations = 0;
	
	NSArray *accounts = [managedObjectContext executeFetchRequest:request error:nil];
	for (id account in accounts) {
		if (!shouldExcludeTotal) {
			accountsBalance += [[account valueForKeyPath:@"operations.@sum.value"] doubleValue];
		}
		
		[request setEntity:[NSEntityDescription entityForName:EntityNameOperation inManagedObjectContext:managedObjectContext]];
		[request setPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"account == %%@ AND pointedState != %d", POINTED_STATE_DISABLED], account]];
		NSArray *operations = [managedObjectContext executeFetchRequest:request error:nil];
		for (id operation in operations) {
			accountsBalanceExcludingDisabledOperations += [[operation valueForKey:@"value"] doubleValue];
		}
		
		// NOW CURRENT VERIFY FILES WITH UNRELATED OPERATIONS
	}
	
	if (!shouldExcludeTotal) {
		[accountsBalanceTextField setDoubleValue:accountsBalance];
	}
	[accountsBalanceExcludingDisabledOperationsTextField setDoubleValue:accountsBalanceExcludingDisabledOperations];

	// TEMP
	double manTotal = 0.0;
	NSArray *operations = [operationsArrayController arrangedObjects];
	for (id operation in operations) {
		manTotal += [[operation valueForKey:@"value"] doubleValue];
	}
	printf("%.2lf\n", manTotal);
	
#ifdef ACCOUNTS_BALANCE_CONTROLLER_TRACE_METHODS
	printf("OUT [AccountsBalanceController updateBalanceFieldsExcludingTotal:]\n");
#endif
}

#pragma mark -
#pragma mark === Notification handlers ===

/*
 Responds to event on observation of:
	- displayedOperationsBalanceTextField.objectValue,
	- operationsArrayController.selection.pointedState.
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(id)context {
	if ([keyPath isEqualToString:@"objectValue"]) {
		[self updateBalanceFieldsExcludingTotal:NO];
	}
	else {
		[self updateBalanceFieldsExcludingTotal:YES];
	}
}

@end
