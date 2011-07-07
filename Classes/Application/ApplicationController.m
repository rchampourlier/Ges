//
//  ApplicationController.m
//  Ges
//
//  Created by NeoJF on 23/07/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "ApplicationController.h"


@implementation ApplicationController


#pragma mark -
#pragma mark === Object's life ===

- (id)init {
	self = [super init];

	if (self != nil) {
		// Register to observe the DocumentDidBecomeMain and DocumentDidResignMain notifications.
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(documentDidBecomeMain:) name:DocumentDidBecomeMainNotificationName object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(documentDidResignMain:) name:DocumentDidResignMainNotificationName object:nil];
		
		[NSValueTransformer setValueTransformer:[[[ArrayEmptyTransformer alloc] init] autorelease] forName:@"ArrayEmpty"];
		[NSValueTransformer setValueTransformer:[[[ArrayNotEmptyTransformer alloc] init] autorelease] forName:@"ArrayNotEmpty"];
		[NSValueTransformer setValueTransformer:[[[AvailableForAccountTransformer alloc] init] autorelease] forName:@"AvailableForAccount"];
		[NSValueTransformer setValueTransformer:[[[MarkedStateImageTransformer alloc] init] autorelease] forName:@"MarkedStateImage"];
		[NSValueTransformer setValueTransformer:[[[PointedStateImageTransformer alloc] init] autorelease] forName:@"PointedStateImage"];
		[NSValueTransformer setValueTransformer:[[[RChTableViewBooleanImageValueTransformer alloc] init] autorelease] forName:@"TableViewBooleanImage"];
	}
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}


#pragma mark -
#pragma mark === Actions ===

- (IBAction)toggleToolbar:(id)sender {
	[[[NSDocumentController sharedDocumentController] currentDocument] toggleToolbar];
}

- (IBAction)customizeToolbar:(id)sender {
	[[[NSDocumentController sharedDocumentController] currentDocument] customizeToolbar];
}

- (IBAction)undo:(id)sender {
	//printf("[ApplicationController undo:]\n");
	[[((MyDocument *)[[NSDocumentController sharedDocumentController] currentDocument]) undoManager] undo];
}

- (IBAction)redo:(id)sender {
	//printf("[ApplicationController redo:]\n");
	[[((MyDocument *)[[NSDocumentController sharedDocumentController] currentDocument]) undoManager] redo];
}

- (IBAction)importCSVFile:(id)sender {
	[((MyDocument *)[[NSDocumentController sharedDocumentController] currentDocument]) importCSVFile];
}

- (IBAction)exportCSVFile:(id)sender {
	[((MyDocument *)[[NSDocumentController sharedDocumentController] currentDocument]) exportCSVFile];
}

#pragma mark -
#pragma mark === Delegate's methods ===

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender {
	return NO;
}


#pragma mark -
#pragma mark === Notifications' methods ===

- (void)documentDidBecomeMain:(NSNotification*)aNotification {
	MyDocument* currentDocument = [aNotification object];
	
	if ([[currentDocument toolbar] isVisible]) {
		[toggleDocumentToolbarMenuItem setTitle:NSLocalizedString(@"hideDocumentToolbar", nil)];
	}
	else {
		[toggleDocumentToolbarMenuItem setTitle:NSLocalizedString(@"showDocumentToolbar", nil)];
	}
	
	// Register to observe the ToolbarDidToggle notifications for the current document.
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toolbarDidToggle:) name:ToolbarDidToggleNotificationName object:[currentDocument toolbar]];
	
	if ([[currentDocument windowForSheet] attachedSheet] != nil) {
		[customizeDocumentToolbarMenuItem setEnabled:NO];
	}
	else {
		[customizeDocumentToolbarMenuItem setEnabled:YES];
	}
}

- (void)documentDidResignMain:(NSNotification*)aNotification {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:ToolbarDidToggleNotificationName object:nil];
}

- (void)toolbarDidToggle:(NSNotification*)aNotification {
	if ([[[aNotification userInfo] objectForKey:ToolbarDidToggleNotificationShownKey] boolValue]) {
		[toggleDocumentToolbarMenuItem setTitle:NSLocalizedString(@"hideDocumentToolbar", nil)];
	}
	else {
		[toggleDocumentToolbarMenuItem setTitle:NSLocalizedString(@"showDocumentToolbar", nil)];
	}
}

- (BOOL)validateMenuItem:(id <NSMenuItem>)menuItem {
	MyDocument* currentDocument = [[NSDocumentController sharedDocumentController] currentDocument];
	if (menuItem == (id <NSMenuItem>)undoMenuItem) {
		NSUndoManager* undoManager = [currentDocument undoManager];
		if ([undoManager canUndo]) {
			return YES;
		}
		else {
			return NO;
		}
	}
	else if (menuItem == (id <NSMenuItem>)redoMenuItem) {
		NSUndoManager* undoManager = [currentDocument undoManager];
		if ([undoManager canRedo]) {
			return YES;
		}
		else {
			return NO;
		}
	}		
	else if (menuItem == (id <NSMenuItem>)customizeDocumentToolbarMenuItem) {
		if ([[currentDocument windowForSheet] attachedSheet] != nil) {
			return NO;
		}
		else {
			return YES;
		}
	}
	return YES;
}

@end
