//
//  DisplayModeViewController.m
//  Ges
//
//  Created by Romain Champourlier on 17/08/08.
//  Copyright 2008 Galilée Conseil & Technologies. All rights reserved.
//

#import "DisplayModeViewController.h"


@implementation DisplayModeViewController

#pragma mark -
#pragma mark === Life cycle ===

- (void)awakeFromNib {
	[editionModeSelectionButton setState:NSOffState];
	[statisticsModeSelectionButton setState:NSOffState];
	
	[editionDisplayModeTabViewItem setView:editionDisplayModeView];
	[statisticsDisplayModeTabViewItem setView:statisticsDisplayModeView];
	
	[self displayEditionView:self];
}

#pragma mark -
#pragma mark === Main tab view control ===

- (IBAction)displayEditionView:(id)sender {
	if (sender == editionModeSelectionButton) {
		if ([mainTabView selectedTabViewItem] == editionDisplayModeTabViewItem) {
			// Button clicked while corresponding view already displayed
			[editionModeSelectionButton setState:NSOffState];
		}
	}
	[mainTabView selectTabViewItem:editionDisplayModeTabViewItem];
	[statisticsModeSelectionButton setState:NSOnState];
	
	displayedModeView = ModeViewEdition;
}

- (IBAction)displayStatisticsView:(id)sender {
	if (sender == statisticsModeSelectionButton) {
		if ([mainTabView selectedTabViewItem] == statisticsDisplayModeTabViewItem) {
			// Button clicked while corresponding view already displayed
			[statisticsModeSelectionButton setState:NSOffState];
		}
	}
	[mainTabView selectTabViewItem:statisticsDisplayModeTabViewItem];
	[editionModeSelectionButton setState:NSOnState];
		
	displayedModeView = ModeViewStatistics;
}

@synthesize displayedModeView;

@end
