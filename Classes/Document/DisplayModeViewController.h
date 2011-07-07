//
//  DisplayModeViewController.h
//  Ges
//
//  Created by Romain Champourlier on 17/08/08.
//  Copyright 2008. All rights reserved.
//

#ifndef DISPLAY_MODE_VIEW_CONTROLLER_H
#define DISPLAY_MODE_VIEW_CONTROLLER_H

#import <Cocoa/Cocoa.h>

typedef enum {ModeViewEdition, ModeViewStatistics} ModeView;

@interface DisplayModeViewController : NSObject {
	IBOutlet NSTabView		*mainTabView;
	IBOutlet NSTabViewItem	*editionDisplayModeTabViewItem;
	IBOutlet NSTabViewItem	*statisticsDisplayModeTabViewItem;
	
	IBOutlet NSView			*editionDisplayModeView;
	IBOutlet NSView			*statisticsDisplayModeView;
	
	IBOutlet NSButton		*editionModeSelectionButton;
	IBOutlet NSButton		*statisticsModeSelectionButton;
	
	ModeView				displayedModeView;
}

- (void)awakeFromNib;

// Main tab view control
- (IBAction)displayEditionView:(id)sender;
- (IBAction)displayStatisticsView:(id)sender;

@property (readonly) ModeView displayedModeView;

@end

#endif