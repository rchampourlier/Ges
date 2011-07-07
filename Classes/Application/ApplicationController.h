//
//  ApplicationController.h
//  Ges
//
//  Created by NeoJF on 23/07/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// Document
#import "MyDocument.h"
#import "MyDocument_Import.h"
#import "DocumentToolbar.h"

// Transformers
#import "ArrayEmptyTransformer.h"
#import "ArrayNotEmptyTransformer.h"
#import "AvailableForAccountTransformer.h"
#import "MarkedStateImageTransformer.h"
#import "PointedStateImageTransformer.h"
#import "RChTableViewBooleanImageValueTransformer.h"


@interface ApplicationController : NSObject {
	IBOutlet NSMenuItem* toggleDocumentToolbarMenuItem;
	IBOutlet NSMenuItem* customizeDocumentToolbarMenuItem;
	IBOutlet NSMenuItem* undoMenuItem;
	IBOutlet NSMenuItem* redoMenuItem;
}

// Actions
- (IBAction)toggleToolbar:(id)sender;
- (IBAction)customizeToolbar:(id)sender;
- (IBAction)undo:(id)sender;
- (IBAction)redo:(id)sender;
- (IBAction)importCSVFile:(id)sender;
- (IBAction)exportCSVFile:(id)sender;

- (void)documentDidBecomeMain:(NSNotification*)aNotification;
- (void)documentDidResignMain:(NSNotification*)aNotification;
- (void)toolbarDidToggle:(NSNotification*)aNotification;

// <NSMenuValidation>
- (BOOL)validateMenuItem:(id <NSMenuItem>)menuItem;

@end
