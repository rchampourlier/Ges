//
//  ExternalWindowController.h
//  Ges
//
//  Created by NeoJF on 25/10/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "MyDocument.h"

@interface ExternalWindowController : NSWindowController <NibWindowController> {

	// Dependences
	MyDocument*				document;
	NSManagedObjectContext*	managedObjectContext;
}

// Life cycle
- (id)initWithDocument:(MyDocument*)aDocument;

// Managed window
- (void)openWindow;
- (void)closeWindow;

// Accessors
- (MyDocument *)document;
- (NSManagedObjectContext*)managedObjectContext;

@property (retain,getter=managedObjectContext) NSManagedObjectContext*	managedObjectContext;
@end
