//
//  PropertiesTableViewController.m
//  Ges
//
//  Created by NeoJF on 15/10/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

/**
 * Controller for the "PropertiesTableView" of the "DocumentProperties"
 * window.
 * Provides the data of the table view - the different "properties" that
 * can be edited - and responds to user's row selection by displaying
 * the corresponding tab in the properties tab view.
 */


#import "PropertiesTableViewController.h"


@implementation PropertiesTableViewController

- (void)awakeFromNib {
	[self setPropertiesSelectionIndexes:[NSIndexSet indexSetWithIndex:0]];
}

#pragma mark -
#pragma mark === KVO: accessors ===

- (NSArray *)properties {
	NSArray* array = [NSArray arrayWithObjects:@"Accounts", @"Modes", @"Posts and types", @"Modes to account association", @"Persons", nil];
	return array;
}

- (NSIndexSet *)propertiesSelectionIndexes {
	return propertiesSelectionIndexes;
}


#pragma mark -
#pragma mark === KVC: accessors ===

/**
 * Updates the instance variable with the provided index set and
 * display the tab view item corresponding to the selection.
 */
- (void)setPropertiesSelectionIndexes:(NSIndexSet*)indexes {
	propertiesSelectionIndexes = indexes;
	
	if ([propertiesSelectionIndexes count] == 1) {
		[propertiesTabView selectTabViewItemAtIndex:[propertiesSelectionIndexes firstIndex]];
	}
}

@end
