//
//  StatisticsOutlineView.h
//  Ges
//
//  Created by Romain Champourlier on 06/02/09.
//  Copyright 2009. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "StatisticsViewController.h"

@interface StatisticsOutlineView : NSOutlineView {
	IBOutlet StatisticsViewController	*statisticsViewController;
}

- (IBAction)delete:(id)sender;

@end
