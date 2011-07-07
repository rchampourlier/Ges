//  MyDocument.h
//  Ges
//
//  Created by NeoJF on 17/07/05.
//  Copyright __MyCompanyName__ 2005 . All rights reserved.


#import <Cocoa/Cocoa.h>
#import "stdio.h"
#import "string.h"
#import "stdlib.h"

// Debug
#import "DebugDefines.h"

// Constants
#import "DocumentConstants.h"
#import "ModelConstants.h"
#import "NotificationConstants.h"

// Classes
#import "AccountsBalanceController.h"
#import "DisplayModeViewController.h"
#import "DocumentToolbar.h"
#import "EditionSelectionSourceListController.h"
#import "FilterController.h"
#import "ModelInstancesUser.h"
#import "NibViewController.h"
#import "NibWindowController.h"
#import "OperationManagedObject.h"
#import "PrioritizedManagedObject.h"
#import "PointedStateSelectorView.h"
#import "SortDescriptorsController.h"


#ifdef TRACE_ALL_L1
#define MY_DOCUMENT_TRACE_METHODS
#define MY_DOCUMENT_TRACE_LIFE_CYCLE
#endif

#ifdef TRACE_ALL_L2
#define MY_DOCUMENT_TRACE_DATA
#define MY_DOCUMENT_TRACE_ACCESSORS
#endif

#ifdef TRACE_ALL_L3
#define MY_DOCUMENT_TRACE_KVO
#define MY_DOCUMENT_TRACE_OTHER
#define MY_DOCUMENT_TRACE_ALL
#endif

#ifdef BENCHMARK_ALL
#define MY_DOCUMENT_BENCHMARK
#endif

// OTHER DEBUGS
/*#define MY_DOCUMENT_TRACE_DATA
#define MY_DOCUMENT_TRACE_OTHER*/


// CONSTANTS

// Alert context info
static NSString*	AlertContextInfoConfigurationNeeded				= @"AlertConfigurationNeeded";
static NSString*	AlertContextInfoAccountSelectedModeNotAvailable = @"AlertAccountSelectedModeNotAvailable";
static NSString*	AlertContextInfoTransferRemovingDualOperation	= @"AlertContextInfoTransferRemovingDualOperation";
static NSString*	AlertContextInfoContextKey						= @"AlertContextInfoContextKey";
static NSString*	AlertContextInfoTransferOperationKey			= @"alertContextInfoTransferOperationKey";

// Notification names
static NSString* DocumentDidBecomeMainNotificationName = @"DocumentDidBecomeMain";
static NSString* DocumentDidResignMainNotificationName = @"DocumentDidResignMain";

// TEMP
static int newTypeCount = 0;

// GUI controls tags
#define	CONTROL_TAG_EDITION_ACCOUNT		0101
#define	CONTROL_TAG_EDITION_MODE		0102
#define	CONTROL_TAG_EDITION_TYPE		0103


/*
 * Class declaration
 */

@class DocumentPropertiesController;
@class PointedStateSelectorView;


@interface MyDocument : NSPersistentDocument <ModelInstancesUser> {

	// Entities array controllers
	IBOutlet NSArrayController	*accountsArrayController;
	IBOutlet NSArrayController	*accountGroupsArrayController;
	IBOutlet NSArrayController	*personsArrayController;
	IBOutlet NSArrayController	*operationsArrayController;
	IBOutlet NSArrayController	*modesArrayController;
	IBOutlet NSArrayController	*typesArrayController;
	IBOutlet NSArrayController	*postsArrayController;
	
	// Dependent set array controllers
	IBOutlet NSArrayController	*selectedOperationAvailableModesArrayController;
	IBOutlet NSArrayController	*typesOfPostArrayController;
		
	// Controllers
	NSObject <NibWindowController, ModelInstancesUser>	*documentPropertiesController;
	IBOutlet AccountsBalanceController					*accountsBalanceController;
	IBOutlet DisplayModeViewController					*displayModeViewController;
	IBOutlet EditionSelectionSourceListController		*editionSelectionSourceListController;
	IBOutlet FilterController							*filterController;
	
	// GUI elements
	IBOutlet NSTextField				*editionValueTextField;
	IBOutlet PointedStateSelectorView	*pointedStateSelectorView;
	
	// Toolbar
	NSToolbar				*toolbar;
	NSPopUpButton			*toolbarDisplayModeSelectionPopUpButton;
	IBOutlet NSSearchField	*toolbarSearchField;

	
	// ------------------ //
	// Internal variables
	// ------------------ //
	
	// KVO change options compensation
	/*NSManagedObject*		selectionAccountLastValue;
	NSManagedObject*		selectionModeLastValue;
	NSManagedObject*		selectionTypeLastValue;*/
	NSManagedObject			*lastOperationArrayControllerSelection;
	
	// Misc
	NSTimer*				operationsRearrangingTimer;
	
	/* Flags relative to document loading.
	 * Enable to determine what actions need to be performed during application/document loading, depending
	 * on the level of loading of CoreData's data (are managed object context and model created and loaded,
	 * etc.).
	 */
	BOOL					isAccountsArrayControllerLoaded;
	BOOL					isEditionSelectionSourceListViewFilled;
	BOOL					isManagedObjectContextLoaded;
	BOOL					isPersonsArrayControllerLoaded;
	BOOL					isPostsArrayControllerLoaded;
}


// Life cycle
- (id)init;
- (void)awakeFromNib;
- (void)removeObservers;

// Data management
- (IBAction)addOperation:(id)sender;
- (IBAction)addOperationCredit:(id)sender;
- (IBAction)addOperationDebit:(id)sender;
- (void)addOperation;
- (OperationManagedObject *)cloneOperation:(OperationManagedObject *)anOperation;
- (IBAction)delete:(id)sender;
- (IBAction)propertyEdited:(id)sender;
- (IBAction)settingTransfer:(id)sender;
- (void)addTypesSet;
- (void)removeTypesSet:(PrioritizedManagedObject *)typesSet;

// Manage document properties
- (IBAction)openDocumentProperties:(id)sender;
- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;

- (IBAction)operationDatePickerAction:(id)sender;
- (void)rearrangeOperationsOnTimer:(NSTimer *)aTimer;

// KVO & Notifications selectors
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(id)context;

// Delegate: NSWindow
- (void)windowWillClose:(NSNotification *)aNotification;

// Accessors
- (NSArray *)arrangedOperations;
- (id <NibWindowController>)documentPropertiesController;

// Dependences for document properties
- (void)addAccountToSelection:(NSManagedObject *)account;
- (void)addModeToSelection:(NSManagedObject *)mode;
- (void)addTypeToSelection:(NSManagedObject *)type;

@property (retain) NSTextField					*editionValueTextField;
@property (retain) FilterController				*filterController;
@property (retain) NSSearchField				*toolbarSearchField;
@property (readonly) NSArrayController			*operationsArrayController;
@property (retain) NSTimer						*operationsRearrangingTimer;
@property (retain) NSPopUpButton				*toolbarDisplayModeSelectionPopUpButton;
@property (retain) NSToolbar					*toolbar;
@property (retain) PointedStateSelectorView		*pointedStateSelectorView;
@end


@interface MyDocument(Toolbar)

- (void)setupToolbarForWindow:(NSWindow *)aWindow;
- (void)toggleToolbar;
- (void)customizeToolbar;
- (NSToolbar *)toolbar;

@end