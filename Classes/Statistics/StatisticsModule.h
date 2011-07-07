//
//  StatisticsModule.h
//  Ges
//
//  Created by Romain Champourlier on 27/04/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NSTreeController_Extensions.h"

#import "DebugDefines.h"
#import "ModelConstants.h"
#import "SortDescriptorsController.h"
#import "StatisticsConstants.h"
#import "StatisticsCellData.h"

#ifdef TRACE_ALL_L1
#define STATISTICS_MODULE_TRACE_METHODS
#endif

typedef enum {
	StatisticsPostsBalanceMonth,
	StatisticsPostsBalanceYear,
	StatisticsPersonsBalanceMonth,
	StatisticsPersonsBalanceYear
} Statistics;

@interface StatisticsModule : NSObject {

	IBOutlet NSArrayController				*personsArrayController;
	IBOutlet NSArrayController				*operationsArrayController;
	IBOutlet NSPersistentDocument			*document;
	IBOutlet NSTreeController				*postsTypesTreeController;
	IBOutlet SortDescriptorsController		*sortDescriptorsController;
}

- (NSTreeController *)postsBalancePerMonth;
- (NSTreeController *)postsBalancePerYear;
- (NSTreeController *)personsBalancePerMonth;
- (NSTreeController *)personsBalancePerYear;

- (NSTreeController *)updateStatistics:(Statistics)statistics forTypesSet:(NSTreeController *)treeController;

@end
