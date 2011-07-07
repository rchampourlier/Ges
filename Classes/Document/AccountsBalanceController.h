//
//  AccountsBalanceController.h
//  Ges
//
//  Created by Romain Champourlier on 31/12/08.
//  Copyright 2008 Galilée Conseil & Technologies. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DebugDefines.h"
#import "ModelConstants.h"
#import "NotificationConstants.h"

#ifdef TRACE_ALL_L3
#define ACCOUNTS_BALANCE_CONTROLLER_TRACE_METHODS
#endif

@interface AccountsBalanceController : NSObject {
	IBOutlet NSTextField		*accountsBalanceTextField;
	IBOutlet NSTextField		*accountsBalanceExcludingDisabledOperationsTextField;
	IBOutlet NSTextField		*displayedOperationsBalanceTextField;
	
	IBOutlet NSArrayController	*operationsArrayController;
}

// Managing observers
- (void)addObservers;
- (void)removeObservers;

// Responding to events notifications
//- (void)accountFilterStateModified:(NSNotification *)aNotification;

// Managing balance
- (void)updateBalanceFieldsExcludingTotal:(BOOL)shouldExcludeTotal;
/*- (double)calculateBalance;
- (double)calculateBalanceExcludingDisabledOperations;*/

// Notification handlers
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(id)context;

@end
