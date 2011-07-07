#import "MyDocument.h"

static NSString* GesDocumentToolbarIdentifier = @"GesDocumentToolbarIdentifier";
static NSString* AddCreditOperationToolbarItemIdentifier = @"AddCreditOperationToolbarItemIdentifier";
static NSString* CloneOperationToolbarItemIdentifier = @"CloneOperationToolbarItemIdentifier";
static NSString* DocumentPropertiesToolbarItemIdentifier = @"DocumentPropertiesToolbarItemIdentifier";
static NSString* AddDebitOperationToolbarItemIdentifier = @"AddDebitOperationToolbarItemIdentifier";
static NSString* SearchFieldToolbarItemIdentifier = @"SearchFieldToobarItemIdentifier";

@implementation MyDocument(Toolbar)

#pragma mark -
#pragma mark === NSToolbar Related Methods ===

- (void)setupToolbarForWindow:(NSWindow *)aWindow {
	// Create toolbar's components
	//toolbarDisplayModeSelectionPopUpButton = [[[NSPopUpButton alloc] init] retain];
	
    // Create a new toolbar instance, and attach it to our document window 
    toolbar = [[[DocumentToolbar alloc] initWithIdentifier:GesDocumentToolbarIdentifier] autorelease];
	
    // Set up toolbar properties: Allow customization, give a default display mode, and remember state in user defaults 
    [toolbar setAllowsUserCustomization:YES];
    [toolbar setAutosavesConfiguration:YES];
    [toolbar setDisplayMode:NSToolbarDisplayModeIconAndLabel];
	
    // We are the delegate
    [toolbar setDelegate:self];
	
    // Attach the toolbar to the document window 
    [aWindow setToolbar:toolbar];
}

/*
 * Required delegate method. Given an item identifier, this method returns an item.
 * The toolbar will use this method to obtain toolbar items that can be displayed in
 * the customization sheet, or in the toolbar itself.
 */
- (NSToolbarItem*)toolbar:(NSToolbar*)toolbar itemForItemIdentifier:(NSString*)itemIdentifier willBeInsertedIntoToolbar:(BOOL)willBeInserted {
    NSToolbarItem *toolbarItem = [[[NSToolbarItem alloc] initWithItemIdentifier: itemIdentifier] autorelease];
	
    if ([itemIdentifier isEqual:AddCreditOperationToolbarItemIdentifier]) {
		[toolbarItem setLabel:NSLocalizedString(@"toolbarLabelAddCreditOperation", nil)];
        [toolbarItem setPaletteLabel:NSLocalizedString(@"toolbarLabelAddCreditOperation", nil)];
        [toolbarItem setToolTip:NSLocalizedString(@"toolbarToolTipAddPositive", nil)];
        [toolbarItem setImage:[NSImage imageNamed: @"Add_32x32"]];
        [toolbarItem setTarget:self];
        [toolbarItem setAction:@selector(addOperationCredit:)];
	}
	
	else if ([itemIdentifier isEqual:CloneOperationToolbarItemIdentifier]) {
        [toolbarItem setLabel:NSLocalizedString(@"toolbarLabelClone", nil)];
        [toolbarItem setPaletteLabel:NSLocalizedString(@"toolbarLabelClone", nil)];
        [toolbarItem setToolTip:NSLocalizedString(@"toolbarToolTipClone", nil)];
        [toolbarItem setImage:[NSImage imageNamed: @"Add_32x32"]];
        [toolbarItem setTarget:self];
        [toolbarItem setAction:@selector(cloneOperations:)];
    }
	
	else if ([itemIdentifier isEqual:DocumentPropertiesToolbarItemIdentifier]) {
        [toolbarItem setLabel:NSLocalizedString(@"toolbarLabelProperties", nil)];
        [toolbarItem setPaletteLabel:NSLocalizedString(@"toolbarLabelProperties", nil)];
        [toolbarItem setToolTip:NSLocalizedString(@"toolbarToolTipProperties", nil)];
        [toolbarItem setImage:[NSImage imageNamed: @"Configure_32x32"]];
        [toolbarItem setTarget:self];
        [toolbarItem setAction:@selector(openDocumentProperties:)];
    }
	
	else if ([itemIdentifier isEqual:AddDebitOperationToolbarItemIdentifier]) {
		[toolbarItem setLabel:NSLocalizedString(@"toolbarLabelAddDebitOperation", nil)];
        [toolbarItem setPaletteLabel:NSLocalizedString(@"toolbarLabelAddDebitOperation", nil)];
        [toolbarItem setToolTip:NSLocalizedString(@"toolbarToolTipAddNegative", nil)];
        [toolbarItem setImage:[NSImage imageNamed:@"Remove_32x32"]];
        [toolbarItem setTarget:self];
        [toolbarItem setAction:@selector(addOperationDebit:)];
	}
	
	else if ([itemIdentifier isEqual:SearchFieldToolbarItemIdentifier]) {
		[toolbarItem setLabel:NSLocalizedString(@"toolbarLabelSearchField", nil)];
		[toolbarItem setPaletteLabel:NSLocalizedString(@"toolbarLabelSearchField", nil)];
		[toolbarItem setToolTip:NSLocalizedString(@"toolbarToolTipSearchField", nil)];
		[toolbarItem setView:toolbarSearchField];
		[toolbarItem setMinSize:NSMakeSize(120, NSHeight([toolbarSearchField frame]))];
        [toolbarItem setMaxSize:NSMakeSize(200, NSHeight([toolbarSearchField frame]))];
	}
	
	else {
        // itemIdentifier referes to a toolbar item that is not provide or supported by us or Cocoa.
        // Returning nil will inform the toolbar this kind of item is not supported.
        toolbarItem = nil;
    }
    return toolbarItem;
}

/*
 * Required method.  Returns the ordered list of items to be shown in the
 * toolbar by default. If during initialization, no overriding values are
 * found in the user defaults, or if the user chooses to revert to the default
 * items this set will be used.
 */
- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar {
    return [NSArray arrayWithObjects:AddCreditOperationToolbarItemIdentifier, AddDebitOperationToolbarItemIdentifier, CloneOperationToolbarItemIdentifier,NSToolbarSeparatorItemIdentifier, DocumentPropertiesToolbarItemIdentifier, NSToolbarFlexibleSpaceItemIdentifier, SearchFieldToolbarItemIdentifier, nil];
}

/*
 * Required method. Returns the list of all allowed items by identifier. 
 * By default, the toolbar does not assume any items are allowed, even the
 * separator. So, every allowed item must be explicitly listed.  The set of
 * allowed items is used to construct the customization palette.  The order
 * of items does not necessarily guarantee the order of appearance in the palette. 
 * At minimum, you should return the default item list.
 */
- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar {
    return [NSArray arrayWithObjects:AddCreditOperationToolbarItemIdentifier, AddDebitOperationToolbarItemIdentifier, CloneOperationToolbarItemIdentifier, DocumentPropertiesToolbarItemIdentifier, SearchFieldToolbarItemIdentifier, NSToolbarFlexibleSpaceItemIdentifier, NSToolbarSpaceItemIdentifier, NSToolbarSeparatorItemIdentifier, nil];
}

/*
 * NSToolbarItemValidation extends the standard validation idea by introducing
 * this new method which is sent to validators for each visible standard NSToolbarItem 
 * with a valid target/action pair.  Note: This message is sent from NSToolbarItem's
 * validate method, however validate will not send this message for items that have 
 * custom views.
 */
- (BOOL)validateToolbarItem:(NSToolbarItem *)toolbarItem {
    BOOL enable = NO;
    
	if([[toolbarItem itemIdentifier] isEqual:DocumentPropertiesToolbarItemIdentifier]) {
        enable = YES;
    }
	else if ([[toolbarItem itemIdentifier] isEqual:AddCreditOperationToolbarItemIdentifier]) {
		enable = YES;
	}
	else if ([[toolbarItem itemIdentifier] isEqual:AddDebitOperationToolbarItemIdentifier]) {
		enable = YES;
	}
	else if ([[toolbarItem itemIdentifier] isEqual:CloneOperationToolbarItemIdentifier]) {
		enable = YES;
	}
	else if ([[toolbarItem itemIdentifier] isEqual:NSToolbarCustomizeToolbarItemIdentifier]) {
		enable = YES;
	}
	
    return enable;
}


#pragma mark -
#pragma mark === Toolbar's operations ===

- (void)toggleToolbar {
	[toolbar setVisible:![toolbar isVisible]];
}

- (void)customizeToolbar {
	[toolbar runCustomizationPalette:self];
}

#pragma mark -
#pragma mark === Accessors ===

- (NSToolbar*)toolbar {
	return toolbar;
}

@end
