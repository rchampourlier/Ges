//
//  StatisticsViewController.h
//  Ges
//
//  Created by Romain Champourlier on 27/04/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#ifndef STATISTICS_VIEW_CONTROLLER_H
#define STATISTICS_VIEW_CONTROLLER_H

#import <Cocoa/Cocoa.h>

#import "DebugDefines.h"
#import "StatisticsConstants.h"
#import "DocumentPropertiesController.h"
#import "PasteboardTypes.h"

#import "MyDocument.h"
#import "NSTreeController_Extensions.h"
#import "PrioritizedManagedObject.h"
#import "SortDescriptorsController.h"
#import "SourceListView.h"
#import "StatisticsCell.h"
#import "StatisticsModule.h"

static NSString *statisticsNamePostsMonth = @"postsMonth";
static NSString *statisticsNamePostsYear = @"postsYear";
static NSString *statisticsNamePersonsMonth = @"personsMonth";
static NSString *statisticsNamePersonsYear = @"personsYear";

@interface StatisticsViewController : NSObject {

	// Views
	IBOutlet NSOutlineView		*dataView;
	IBOutlet SourceListView		*statisticsSelectionView;
	
	// Misc
	NSTreeController			*statisticsSelectionTC;
	NSString					*displayedStatisticsLongName;
	IBOutlet StatisticsModule	*statisticsModule;
	IBOutlet NSButton			*addNewTypesSetButton;
	
	// Statistics results data controllers
	NSTreeController			*currentlyDisplayedTC;
	NSTreeController			*statisticsPostsMonthTC;
	NSTreeController			*statisticsPostsYearTC;
	NSTreeController			*statisticsPersonsMonthTC;
	NSTreeController			*statisticsPersonsYearTC;
}

- (id)init;
- (void)dealloc;
- (void)awakeFromNib;

- (void)displayStatisticsPerMonthWithTreeController:(NSTreeController *)aTree;
- (void)hideStatisticsPerMonth;
- (void)displayStatisticsPerYearWithTreeController:(NSTreeController *)aTree;
- (void)hideStatisticsPerYear;

- (void)displayStatisticsPostsPerMonth;
- (void)displayStatisticsPostsPerYear;
- (void)displayStatisticsPersonsPerMonth;
- (void)displayStatisticsPersonsPerYear;

- (IBAction)addNewTypesSet:(id)sender;
- (void)delete;

/*
 * Drag'n'drop management
 */
- (BOOL)outlineView:(NSOutlineView *)outlineView writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pboard;
- (NSDragOperation)outlineView:(NSOutlineView *)outlineView validateDrop:(id < NSDraggingInfo >)info proposedItem:(id)item proposedChildIndex:(NSInteger)index;
- (BOOL)outlineView:(NSOutlineView *)outlineView acceptDrop:(id < NSDraggingInfo >)info item:(id)item childIndex:(NSInteger)index;


@end

#endif
