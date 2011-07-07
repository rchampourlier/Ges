//
//  PropertiesTableViewDataSource.h
//  Ges
//
//  Created by NeoJF on 15/10/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PropertiesTableViewController : NSObject {
	IBOutlet NSTabView*	propertiesTabView;
	NSIndexSet*			propertiesSelectionIndexes;
}

// KVO: accessors
- (NSArray *)properties;
- (NSIndexSet *)propertiesSelectionIndexes;

// KVC: accessors
- (void)setPropertiesSelectionIndexes:(NSIndexSet*)indexes;

@property (assign,getter=propertiesSelectionIndexes,setter=setPropertiesSelectionIndexes:) NSIndexSet*			propertiesSelectionIndexes;

@end
