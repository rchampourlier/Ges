//
//  StatisticsModule.m
//  Ges
//
//  Created by Romain Champourlier on 27/04/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "StatisticsModule.h"

static NSString *childrenKeyPath = @"children";

@interface StatisticsModule (PrivateMethods)
- (int)yearOfOldestOperation;
- (NSDictionary *)reduceTotalDictionary:(NSDictionary *)dictionary forTypesSet:(id)typesSet withTitle:(NSString *)title ;
- (NSArray *)posts;
- (NSArray *)typesForPost:(id)post;
- (NSMutableArray *)completeTypesSetArray:(NSMutableArray *)treeController;
- (NSTreeController *)completeTypesSetTreeController:(NSTreeController *)treeController;
- (void)updateValuesOfRoot:(NSMutableDictionary *)rootDictionary byRemovingPost:(NSDictionary *)postDictionary;
- (void)updateValuesOfRoot:(NSMutableDictionary *)rootDictionary andPost:(NSMutableDictionary *)postDictionary byRemovingType:(NSDictionary *)typeDictionary;
- (NSArray *)balancesPerMonthForAllTypesSetAndPerson:(NSManagedObject *)person;
- (NSArray *)balancesPerYearForAllTypesSetAndPerson:(NSManagedObject *)person;
- (NSDictionary *)cumulateStatisticsEntries:(NSArray *)array;
@end


/**
 Standard statistics format:
 
	- Nodes are NSDictionary objects.
	- Node's keys are:
		. @"element":	contains a "titleCell" StatisticsCellData object, describing cell's data,
		. @"children":	contains an array of nodes, representing the children nodes,
		. @"<StatisticsColumnValueMonthIdentifierFormat>[M]M" (constructed key, StatisticsColumnValueMonthIdentifierFormat being a constant string, MM representing the month number, on 2 figures only if >9):
						contains a "valueCell" StatisticsCellData object, describing cell's data.
 */

@implementation StatisticsModule

#pragma mark -
#pragma mark === Build statistics ===

/**
 Description of the returned tree controller's structure (cardinality, if >1 items,  is indicated before
 the item item between brackets).
 
	|content	-> [#typesSet + 1] NSDictionary *typesSetDictionary
		|@"element"		-> StatisticsCellData	*typesSetCellData (titleCell)
		|@"children"	-> NSArray				*childrenArray (1)
			|[#posts] NSDictionary *postDictionary
				|@"element"		-> StatisticsCellData	*postCellData (titleCell)
				|@"children"	-> NSArray			*childrenArray (1)
					|[#types] NSDictionary	*typeDictionary
						|@"element"		-> StatisticsCellData	*typeCellData (titleCell)
						|[NSString stringWithFormat:StatisticsColumnValueMonthIdentifierFormat, monthNumber]
							-> StatisticsCellData	*typeCellDataValueMonth (valueCell)
				|[NSString stringWithFormat:StatisticsColumnValueMonthIdentifierFormat, monthNumber]
					-> StatisticsCellData	*postCellDataValueMonth (valueCell)
		|[NSString stringWithFormat:StatisticsColumnValueMonthIdentifierFormat, monthNumber]
			-> StatisticsCellData	*postCellDataValueMonth (valueCell)
 */
- (NSTreeController *)postsBalancePerMonth {
#ifdef STATISTICS_MODULE_TRACE_METHODS
	printf("IN  [StatisticsModule postsBalancePerMonth]\n");
#endif
	
	NSTreeController *postsBalancePerMonthTreeController = [[NSTreeController alloc] init];
	[postsBalancePerMonthTreeController setChildrenKeyPath:childrenKeyPath];
	
	NSTimeZone *tz = [NSTimeZone localTimeZone];
	NSManagedObjectContext* managedObjectContext = [document managedObjectContext];
	NSFetchRequest* request = [[[NSFetchRequest alloc] init] autorelease];
	StatisticsCellData *totalCellData = [StatisticsCellData parentCellWithTitle:@"Total" correspondingManagedObject:nil];
	NSMutableDictionary *totalDictionary = [NSMutableDictionary dictionaryWithObject:totalCellData forKey:@"element"];
	
	// Fetching all posts
	NSArray *posts = [self posts];
	
	NSMutableArray *allTypesSetChildren = [NSMutableArray array];
	int i = 0;
	for (NSManagedObject *post in posts) {
		NSArray *types = [self typesForPost:post];
		
		StatisticsCellData *cellData = [StatisticsCellData parentCellWithTitle:[post valueForKey:@"name"] correspondingManagedObject:post];
		NSMutableDictionary *postDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:cellData, @"element", nil];
		NSMutableArray *childrenArray = [NSMutableArray array];
		
		for (NSManagedObject *type in types) {
			StatisticsCellData *cellData = [StatisticsCellData childCellWithTitle:[type valueForKey:@"name"] correspondingManagedObject:type];
			NSMutableDictionary *typeDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:cellData, @"element", nil];
			[request setEntity:[NSEntityDescription entityForName:@"Operation" inManagedObjectContext:managedObjectContext]];
			[request setSortDescriptors:[sortDescriptorsController operationsSortDescriptors]];
			
			NSCalendarDate *today = [NSCalendarDate date];
			int startMonth = [today monthOfYear];
			//int startYear = (startMonth == 12 ? [today yearOfCommonEra] : [today yearOfCommonEra] - 1);
			int startYear = [today yearOfCommonEra] - 1
			;
			int monthCount;
			int loopMonth = startMonth;
			int loopYear = startYear;
			for (monthCount = 0; monthCount < 12; monthCount++) {
				loopMonth++;
				if (loopMonth == 13) {
					loopMonth = 1;
					loopYear = startYear + 1;
				}
				NSCalendarDate *startDate = [NSCalendarDate dateWithYear:loopYear month:loopMonth day:1 hour:0 minute:0 second:0 timeZone:tz];
				NSCalendarDate *endDate = [startDate dateByAddingYears:0 months:1 days:-1 hours:23 minutes:59 seconds:59];
				[request setPredicate:[NSPredicate predicateWithFormat:@"type == %@ AND operationDate > %@ AND operationDate < %@", type, startDate, endDate]];
			
				NSArrayController *operationsAC = [[NSArrayController alloc] init];
				[operationsAC setSelectsInsertedObjects:NO];
				[operationsAC addObjects:[managedObjectContext executeFetchRequest:request error:NULL]];
				printf("%s/%s, %d:%d, operationsAC: #%d\n", [[post valueForKey:@"name"] CSTRING], [[type valueForKey:@"name"] CSTRING], loopMonth, loopYear, [[operationsAC arrangedObjects] count]);
				
				StatisticsCellData *valueData = [StatisticsCellData childCellWithValue:[operationsAC valueForKeyPath:@"content.@sum.value"]];
				[typeDictionary setObject:valueData forKey:[NSString stringWithFormat:StatisticsColumnValueMonthIdentifierFormat, loopMonth]];

				NSNumber *totalOldValue = [totalDictionary objectForKey:[NSString stringWithFormat:StatisticsColumnValueMonthIdentifierFormat, loopMonth]];
				if (totalOldValue == nil) {
					[totalDictionary setObject:valueData forKey:[NSString stringWithFormat:StatisticsColumnValueMonthIdentifierFormat, loopMonth]];
				}
				else {
					[totalDictionary setObject:[StatisticsCellData parentCellWithValue:[NSNumber numberWithFloat:([[valueData value] floatValue] + [[totalOldValue value] floatValue])]] forKey:[NSString stringWithFormat:StatisticsColumnValueMonthIdentifierFormat, loopMonth]];
				}
				
				NSNumber *postOldValue = [postDictionary objectForKey:[NSString stringWithFormat:StatisticsColumnValueMonthIdentifierFormat, loopMonth]];
				if (postOldValue == nil) {
					[postDictionary setObject:valueData forKey:[NSString stringWithFormat:StatisticsColumnValueMonthIdentifierFormat, loopMonth]];
				}
				else {
					[postDictionary setObject:[StatisticsCellData parentCellWithValue:[NSNumber numberWithFloat:([[valueData value] floatValue] + [[postOldValue value] floatValue])]] forKey:[NSString stringWithFormat:StatisticsColumnValueMonthIdentifierFormat, loopMonth]];
				}
			}
			[childrenArray addObject:typeDictionary];

		}
		[postDictionary setObject:childrenArray forKey:childrenKeyPath];
		[allTypesSetChildren insertObject:postDictionary atIndex:i++];
	}
	[totalDictionary setObject:allTypesSetChildren forKey:childrenKeyPath];
	[postsBalancePerMonthTreeController insertObject:totalDictionary atArrangedObjectIndexPath:[NSIndexPath indexPathWithIndex:0]];

	[self completeTypesSetTreeController:postsBalancePerMonthTreeController];

#ifdef STATISTICS_MODULE_TRACE_METHODS
	printf("OUT [StatisticsModule postsBalancePerMonth]\n");
#endif
	
	return postsBalancePerMonthTreeController;
}

/**
 * Description of the returned tree controller's structure (the cardinality is
 * indicated between parenthesis).
 *
 * NSTreeController		*postsBalancePerYear - returned object
 *	|content	-> NSDictionary	*postDictionary (#posts)
 *		|@"element"		-> StatisticsCellData	*postCellData (1/titleCell)
 *		|@"children"	-> NSArray			*childrenArray (1)
 *			|[]NSDictionary	*typeDictionary (#types)
 *				|@"element"		-> StatisticsCellData	*typeCellData (1/titleCell)
 *				|[NSString stringWithFormat:StatisticsColumnValueYearIdentifierFormat, yearNumber]
 *								-> StatisticsCellData	*typeCellDataValueYear (1/valueCell)
 *		|[NSString stringWithFormat:StatisticsColumnValueYearIdentifierFormat, yearNumber]
 *						-> StatisticsCellData	*postCellDataValueYear (1/valueCell)
 */
- (NSTreeController *)postsBalancePerYear {
#ifdef STATISTICS_MODULE_TRACE_METHODS
	printf("IN  [StatisticsModule postsBalancePerYear]\n");
#endif

	NSTreeController *postsBalancePerYearTreeController = [[NSTreeController alloc] init];
	[postsBalancePerYearTreeController setChildrenKeyPath:childrenKeyPath];

	NSTimeZone *tz = [NSTimeZone localTimeZone];
	NSManagedObjectContext* managedObjectContext = [document managedObjectContext];
	NSFetchRequest* request = [[[NSFetchRequest alloc] init] autorelease];
	StatisticsCellData *totalCellData = [StatisticsCellData parentCellWithTitle:@"Total" correspondingManagedObject:nil];
	NSMutableDictionary *totalDictionary = [NSMutableDictionary dictionaryWithObject:totalCellData forKey:@"element"];
	
	// Fetching all posts
	NSArray *posts = [self posts];

	int endYear = [self yearOfOldestOperation];

	NSMutableArray *allTypesSetChildren = [NSMutableArray array];
	int i = 0;
	for (NSManagedObject *post in posts) {
		NSArray *types = [self typesForPost:post];

		StatisticsCellData *cellData = [StatisticsCellData parentCellWithTitle:[post valueForKey:@"name"] correspondingManagedObject:post];
		NSMutableDictionary *postDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:cellData, @"element", nil];
		NSMutableArray *childrenArray = [NSMutableArray array];
		
		for (NSManagedObject *type in types) {
			StatisticsCellData *cellData = [StatisticsCellData childCellWithTitle:[type valueForKey:@"name"] correspondingManagedObject:type];
			NSMutableDictionary *typeDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:cellData, @"element", nil];
			
			// Preparing fetch request for fetching operations of current type for each year
			[request setEntity:[NSEntityDescription entityForName:@"Operation" inManagedObjectContext:managedObjectContext]];
			[request setSortDescriptors:[sortDescriptorsController operationsSortDescriptors]];
			
			NSCalendarDate *today = [NSCalendarDate date];
			int year = [today yearOfCommonEra];
						
			while (year >= endYear) {
				NSCalendarDate *startDate = [NSCalendarDate dateWithYear:year month:1 day:1 hour:0 minute:0 second:0 timeZone:tz];
				NSCalendarDate *endDate = [startDate dateByAddingYears:1 months:0 days:-1 hours:23 minutes:59 seconds:59];
				[request setPredicate:[NSPredicate predicateWithFormat:@"type == %@ AND operationDate > %@ AND operationDate < %@", type, startDate, endDate]];
				
				NSArrayController *operationsAC = [[NSArrayController alloc] init];
				[operationsAC setSelectsInsertedObjects:NO];
				[operationsAC addObjects:[managedObjectContext executeFetchRequest:request error:NULL]];
				StatisticsCellData *valueData = [StatisticsCellData childCellWithValue:[operationsAC valueForKeyPath:@"content.@sum.value"]];
				[typeDictionary setObject:valueData forKey:[NSString stringWithFormat:StatisticsColumnValueYearIdentifierFormat, year]];
								
				NSNumber *totalOldValue = [totalDictionary objectForKey:[NSString stringWithFormat:StatisticsColumnValueYearIdentifierFormat, year]];
				if (totalOldValue == nil) {
					[totalDictionary setObject:valueData forKey:[NSString stringWithFormat:StatisticsColumnValueYearIdentifierFormat, year]];
				}
				else {
					[totalDictionary setObject:[StatisticsCellData parentCellWithValue:[NSNumber numberWithFloat:([[valueData value] floatValue] + [[totalOldValue value] floatValue])]] forKey:[NSString stringWithFormat:StatisticsColumnValueYearIdentifierFormat, year]];
				}
				
				NSNumber *postOldValue = [postDictionary objectForKey:[NSString stringWithFormat:StatisticsColumnValueYearIdentifierFormat, year]];
				if (postOldValue == nil) {
					[postDictionary setObject:valueData forKey:[NSString stringWithFormat:StatisticsColumnValueYearIdentifierFormat, year]];
				}
				else {
					[postDictionary setObject:[StatisticsCellData parentCellWithValue:[NSNumber numberWithFloat:([[valueData value] floatValue] + [[postOldValue value] floatValue])]] forKey:[NSString stringWithFormat:StatisticsColumnValueYearIdentifierFormat, year]];
				}
				
				year--;
			}
			[childrenArray addObject:typeDictionary];
			
		}
		[postDictionary setObject:childrenArray forKey:childrenKeyPath];
		//[postsBalancePerYearTreeController insertObject:postDictionary atArrangedObjectIndexPath:[NSIndexPath indexPathWithIndex:i++]];
		[allTypesSetChildren insertObject:postDictionary atIndex:i++];
	}
	[totalDictionary setObject:allTypesSetChildren forKey:childrenKeyPath];
	[postsBalancePerYearTreeController insertObject:totalDictionary atArrangedObjectIndexPath:[NSIndexPath indexPathWithIndex:0]];
	
	[self completeTypesSetTreeController:postsBalancePerYearTreeController];
	
#ifdef STATISTICS_MODULE_TRACE_METHODS
	printf("OUT [StatisticsModule postsBalancePerYear]\n");
#endif

	return postsBalancePerYearTreeController;
}


- (NSTreeController *)personsBalancePerMonth {
#ifdef STATISTICS_MODULE_TRACE_METHODS
	printf("IN  [StatisticsModule personsBalancePerMonth]\n");
#endif
	
	// Definition of local instances and variables
	NSFetchRequest* request = [[NSFetchRequest alloc] init];
	NSTimeZone *tz = [NSTimeZone localTimeZone];
	NSManagedObjectContext* managedObjectContext = [document managedObjectContext];
	NSTreeController *personsBalancePerMonthTreeController = [[NSTreeController alloc] init];
	NSMutableDictionary *totalDictionary = [NSMutableDictionary dictionaryWithObject:[StatisticsCellData parentCellWithTitle:@"All operations" correspondingManagedObject:nil] forKey:@"element"];
	
	// Setting parameters of local instances
	[personsBalancePerMonthTreeController setChildrenKeyPath:childrenKeyPath];
	
	// Getting persons
	//printf("personsArrayController: %d\n", [[personsArrayController arrangedObjects] count]);
	
	int i = 0;
	NSArray *persons = [personsArrayController arrangedObjects];
	NSMutableArray *balancesForAllPersonsArray = [NSMutableArray array];
	for (NSManagedObject *person in persons) {
		// Going through all persons
		
		// Building person's data dictionary
		NSMutableDictionary *personDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:[StatisticsCellData childCellWithTitle:[person valueForKey:@"name"] correspondingManagedObject:person], @"element", nil];
		
		// Preparing fetch request for fetching operations of current person for each year
		NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Operation" inManagedObjectContext:managedObjectContext];
		[request setEntity:entityDescription];
		[request setSortDescriptors:[NSArray array]];
		
		// Fetching operations for last 12 months, each month apart
		NSCalendarDate *today = [NSCalendarDate date];
		int startMonth = [today  monthOfYear];
		int startYear = (startMonth == 12 ? [today yearOfCommonEra] : [today yearOfCommonEra] - 1);
		int monthCount;
		int loopMonth = startMonth;
		int loopYear = startYear;
		for (monthCount = 0; monthCount < 12; monthCount++) {
			loopMonth++;
			if (loopMonth == 13) {
				loopMonth = 1;
				loopYear = startYear + 1;
			}
			NSCalendarDate *startDate = [NSCalendarDate dateWithYear:loopYear month:loopMonth day:1 hour:0 minute:0 second:0 timeZone:tz];
			NSCalendarDate *endDate = [startDate dateByAddingYears:0 months:1 days:-1 hours:23 minutes:59 seconds:59];
			[request setPredicate:[NSPredicate predicateWithFormat:@"person == %@ AND operationDate > %@ AND operationDate < %@", person, startDate, endDate]];
						
			NSArrayController *operationsAC = [[NSArrayController alloc] init];
			[operationsAC addObjects:[managedObjectContext executeFetchRequest:request error:NULL]];
			StatisticsCellData *valueData = [StatisticsCellData childCellWithValue:[operationsAC valueForKeyPath:@"content.@sum.value"]];
			[personDictionary setObject:valueData forKey:[NSString stringWithFormat:StatisticsColumnValueMonthIdentifierFormat, loopMonth]];
		}
		
		// TODO: previous loop instructions are duplicate with the ones in the following method call.
		NSArray *balancesForAllTypesSetAndPersonArray = [self balancesPerMonthForAllTypesSetAndPerson:person];
		[personDictionary setObject:balancesForAllTypesSetAndPersonArray forKey:childrenKeyPath];
		
		[balancesForAllPersonsArray addObject:personDictionary];
		[personsBalancePerMonthTreeController insertObject:personDictionary atArrangedObjectIndexPath:[NSIndexPath indexPathWithIndex:i++]];
	}
	
	NSLog(@"starting creating all persons entry");
	[self cumulateStatisticsEntries:balancesForAllPersonsArray];
	
#ifdef STATISTICS_MODULE_TRACE_METHODS
	printf("OUT [StatisticsModule personsBalancePerMonth]\n");
#endif
	
	[request release];
	
	return personsBalancePerMonthTreeController;
}

- (NSTreeController *)personsBalancePerYear {
#ifdef STATISTICS_MODULE_TRACE_METHODS
	printf("IN  [StatisticsModule personsBalancePerYear]\n");
#endif
	
	// Definition of local instances and variables
	NSFetchRequest* request = [[[NSFetchRequest alloc] init] autorelease];
	NSTimeZone *tz = [NSTimeZone localTimeZone];
	NSManagedObjectContext* managedObjectContext = [document managedObjectContext];
	NSTreeController *personsBalancePerYearTreeController = [[NSTreeController alloc] init];
	NSMutableDictionary *totalDictionary = [NSMutableDictionary dictionaryWithObject:[StatisticsCellData parentCellWithTitle:@"Total" correspondingManagedObject:nil] forKey:@"element"];
	
	// Setting parameters of local instances
	[personsBalancePerYearTreeController setChildrenKeyPath:childrenKeyPath];
	
	// Fetching the oldest operation
	/*NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Operation" inManagedObjectContext:managedObjectContext];
	[request setEntity:entityDescription];
	[request setSortDescriptors:[sortDescriptorsController operationsSortDescriptors]];*/
	int endYear = [self yearOfOldestOperation];
		
	int i = 0;
	NSArray *persons = [personsArrayController arrangedObjects];
	NSMutableArray *balancesForAllPersonsArray = [NSMutableArray array];
	for (NSManagedObject *person in persons) {
		// Going through all persons
		
		// Building person's data dictionary
		NSMutableDictionary *personDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:[StatisticsCellData childCellWithTitle:[person valueForKey:@"name"] correspondingManagedObject:person], @"element", nil];
					
		// Preparing fetch request for fetching operations of current person for each year
		NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Operation" inManagedObjectContext:managedObjectContext];
		[request setEntity:entityDescription];
		[request setSortDescriptors:[NSArray array]];
		
		// Getting current year
		NSCalendarDate *today = [NSCalendarDate date];
		int year = [today yearOfCommonEra];
		
		// Fetching operations for each year
		while (year >= endYear) {
			
			// Building fetch predicate
			NSCalendarDate *startDate = [NSCalendarDate dateWithYear:year month:1 day:1 hour:0 minute:0 second:0 timeZone:tz];
			NSCalendarDate *endDate = [startDate dateByAddingYears:1 months:0 days:-1 hours:23 minutes:59 seconds:59];
			NSPredicate *predicate = [NSPredicate predicateWithFormat:@"person == %@ AND operationDate > %@ AND operationDate < %@", person, startDate, endDate];
			[request setPredicate:predicate];
			
			NSArrayController *operationsAC = [[NSArrayController alloc] init];
			[operationsAC addObjects:[managedObjectContext executeFetchRequest:request error:NULL]];
			StatisticsCellData *valueData = [StatisticsCellData childCellWithValue:[operationsAC valueForKeyPath:@"content.@sum.value"]];
			[personDictionary setObject:valueData forKey:[NSString stringWithFormat:StatisticsColumnValueYearIdentifierFormat, year]];
			
			year--;
		}

		NSArray *balancesForAllTypesSetAndPersonArray = [self balancesPerYearForAllTypesSetAndPerson:person];
		[personDictionary setObject:balancesForAllTypesSetAndPersonArray forKey:childrenKeyPath];
		
		[balancesForAllPersonsArray addObject:personDictionary];
		[personsBalancePerYearTreeController insertObject:personDictionary atArrangedObjectIndexPath:[NSIndexPath indexPathWithIndex:i++]];
	}

	NSLog(@"starting creating all persons entry");
	[self cumulateStatisticsEntries:balancesForAllPersonsArray];

#ifdef STATISTICS_MODULE_TRACE_METHODS
	printf("OUT [StatisticsModule personsBalancePerYear]\n");
	#endif
	
	return personsBalancePerYearTreeController;
}


#pragma mark -
#pragma mark === Manage types sets ===

/*
 Given a tree controller containing statistics arranged by types set (root node's children are typesSet
 nodes, providing a complete hierarchy for correspondant statistics), this method returns an updated 
 tree controller which includes newly created or updated typesSets' statistics.
 */
 
- (NSTreeController *)updateStatistics:(Statistics)statistics forTypesSet:(NSTreeController *)treeController {
	printf("IN  [StatisticsModule updateStatistics:forTypesSet]\n");
	
	int treeControllerCount = [(NSArray *)[treeController content] count];
	
	int i;
	for (i = 0; i < treeControllerCount - 1; i++) {
		// Remove all lines of the tree controller (first level), except the last one which is the "Total" line.
		[treeController removeObjectAtArrangedObjectIndexPath:[NSIndexPath indexPathWithIndex:0]];
	}
	
	[self completeTypesSetTreeController:treeController];
	
	printf("OUT [StatisticsModule updateForTypesSet:]\n");
	return treeController;
}

@end


#pragma mark -
#pragma mark === Private methods ===

@implementation StatisticsModule (PrivateMethods)

/*
 Being given totalDictionary, this method returns a "sub-dictionary", constructed from totalDictionary
 but only including lines for types included in typesSet.
 
 - totalDictionary: the dictionary for the "Total" entry of the statistics
 - typesSet: the typesSet to provide statistics for
 - title: typesSet's title
 */
- (NSDictionary *)reduceTotalDictionary:(NSDictionary *)totalDictionary forTypesSet:(id)typesSet withTitle:(NSString *)title {
	printf("IN  [StatisticsModule reduceTotalDictionary:forTypesSet:%s]\n", [[typesSet valueForKey:@"name"] CSTRING]);
	
	NSMutableDictionary *reducedDictionary = [totalDictionary mutableCopyWithZone:nil];
	[reducedDictionary setObject:[StatisticsCellData parentCellWithTitle:title correspondingManagedObject:nil] forKey:@"element"];
	
	// Building the set of posts for which at least one type is in typesSet		
	NSMutableArray *reducedDictionaryPostsArray = [[totalDictionary valueForKey:childrenKeyPath] mutableCopy];
	NSMutableArray *postsTypesHierarchyToKeepArray = [NSMutableArray array]; // Will be an array of mutableArrays. At the root level, one array per post. For each post array, one array of values indicating included types' priorities.
	int totalPostsCount = [reducedDictionaryPostsArray count]; // total number of posts
	int i;
	for (i = 0; i < totalPostsCount; i++) {
		[postsTypesHierarchyToKeepArray addObject:[NSMutableArray array]];
	}
	
	// Adding the types in typesSet into the corresponding post's mutable array in postsTypesHierarchyToKeepArray
	NSMutableSet *posts = [NSMutableSet set];
	NSSet *types = [typesSet valueForKey:@"types"];
	for (NSManagedObject *type in types) {
		[posts addObject:[type valueForKey:@"post"]];
		[[postsTypesHierarchyToKeepArray objectAtIndex:[[type valueForKeyPath:@"post.priority"] unsignedIntValue]] addObject:[type valueForKey:@"priority"]]; // this one is crashing because of an empty postsTypesHierarchyToKeepArray array
	}
	
	for (i = totalPostsCount - 1; i >= 0; i--) {
		if ([[postsTypesHierarchyToKeepArray objectAtIndex:i] count] == 0) {
			// No type for this post has to be included in the reduced dictionary. Mutable array in reducedDictionaryPostsArray for this post will be removed.
			[self updateValuesOfRoot:reducedDictionary byRemovingPost:[reducedDictionaryPostsArray objectAtIndex:i]];
			[reducedDictionaryPostsArray removeObjectAtIndex:i];
		}
		else {
			NSMutableDictionary *reducedDictionaryPost = [[reducedDictionaryPostsArray objectAtIndex:i] mutableCopy];
			NSMutableArray *reducedDictionaryTypesArray = [[reducedDictionaryPost valueForKey:childrenKeyPath] mutableCopy];
			for (NSDictionary *reducedDictionaryType in [reducedDictionaryPost valueForKey:childrenKeyPath]) {
				StatisticsCellData *cellData = [reducedDictionaryType valueForKey:@"element"];
				NSManagedObject *cellObject = cellData.correspondingObject;
				
				NSNumber *reducedDictionaryTypePriority = [cellObject valueForKey:@"priority"];
				if (![(NSArray *)[postsTypesHierarchyToKeepArray objectAtIndex:i] containsObject:reducedDictionaryTypePriority]) {
					[self updateValuesOfRoot:reducedDictionary andPost:reducedDictionaryPost byRemovingType:reducedDictionaryType];
					[reducedDictionaryTypesArray removeObject:reducedDictionaryType];
				}
			}
			[reducedDictionaryPost setObject:reducedDictionaryTypesArray forKey:childrenKeyPath];
			[reducedDictionaryPostsArray replaceObjectAtIndex:i withObject:reducedDictionaryPost];
		}
	}
	[reducedDictionary setObject:reducedDictionaryPostsArray forKey:childrenKeyPath];
	
	printf("OUT [StatisticsModule reduceTotalDictionary:forTypesSet:]\n");
	
	// UPDATED
	//[reducedDictionary release]; // cause exception, linking object probably not finding it anymore
	return reducedDictionary;
}

- (NSArray *)posts {
	NSManagedObjectContext* managedObjectContext = [document managedObjectContext];
	NSFetchRequest* request = [[[NSFetchRequest alloc] init] autorelease];
	[request setEntity:[NSEntityDescription entityForName:EntityNamePost inManagedObjectContext:managedObjectContext]];
	[request setSortDescriptors:[sortDescriptorsController prioritySortDescriptors]];
	return [managedObjectContext executeFetchRequest:request error:NULL];
}	

- (NSArray *)typesForPost:(id)post {
	NSManagedObjectContext* managedObjectContext = [document managedObjectContext];
	NSFetchRequest* request = [[[NSFetchRequest alloc] init] autorelease];
	[request setEntity:[NSEntityDescription entityForName:EntityNameType inManagedObjectContext:managedObjectContext]];
	[request setSortDescriptors:[sortDescriptorsController prioritySortDescriptors]];
	[request setPredicate:[NSPredicate predicateWithFormat:@"post == %@", post]];
	return [managedObjectContext executeFetchRequest:request error:NULL];
}

- (int)yearOfOldestOperation {
	NSFetchRequest* request = [[[NSFetchRequest alloc] init] autorelease];
	NSManagedObjectContext* managedObjectContext = [document managedObjectContext];
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Operation" inManagedObjectContext:managedObjectContext];
	[request setEntity:entityDescription];
	[request setSortDescriptors:[sortDescriptorsController operationsSortDescriptors]];
	return [[NSCalendarDate dateWithTimeIntervalSinceReferenceDate:[[[[managedObjectContext executeFetchRequest:request error:NULL] lastObject] valueForKey:@"operationDate"] timeIntervalSinceReferenceDate]] yearOfCommonEra];
}

/**
 Being provided an array containing the "all types" typesSet NSDictionary entry, returns a NSTreeController object containing this entry, completed by the typesSet in use in the document.
 */
- (NSMutableArray *)completeTypesSetArray:(NSMutableArray *)array {
#ifdef STATISTICS_MODULE_TRACE_METHODS
	printf("IN  [StatisticsModule completeTypesSetArray::]\n");
#endif
	
	NSManagedObjectContext *managedObjectContext = [document managedObjectContext];
	NSFetchRequest *typesSetRequest = [[[NSFetchRequest alloc] init] autorelease];
	[typesSetRequest setEntity:[NSEntityDescription entityForName:EntityNameTypesSet inManagedObjectContext:managedObjectContext]];
	[typesSetRequest setSortDescriptors:[SortDescriptorsController prioritySortDescriptors]];
	NSArray *typesSets = [managedObjectContext executeFetchRequest:typesSetRequest error:NULL];

	NSDictionary *totalDictionary = [array objectAtIndex:0];
	for (id typesSet in typesSets) {
		[array insertObject:[self reduceTotalDictionary:totalDictionary forTypesSet:typesSet withTitle:[typesSet valueForKey:@"name"]] atIndex:[[typesSet valueForKey:@"priority"] intValue]];
	}
	
#ifdef STATISTICS_MODULE_TRACE_METHODS
	printf("OUT [StatisticsModule completeTypesSetArray::]\n");
#endif
	
	return array;
}

- (NSTreeController *)completeTypesSetTreeController:(NSTreeController *)treeController {
#ifdef STATISTICS_MODULE_TRACE_METHODS
	printf("IN  [StatisticsModule completeTypesSetTreeController::]\n");
#endif
	
	NSManagedObjectContext *managedObjectContext = [document managedObjectContext];
	NSFetchRequest *typesSetRequest = [[[NSFetchRequest alloc] init] autorelease];
	[typesSetRequest setEntity:[NSEntityDescription entityForName:EntityNameTypesSet inManagedObjectContext:managedObjectContext]];
	[typesSetRequest setSortDescriptors:[SortDescriptorsController prioritySortDescriptors]];
	NSArray *typesSets = [managedObjectContext executeFetchRequest:typesSetRequest error:NULL];
	NSDictionary *totalDictionary = [[treeController objectAtArrangedIndexPath:[NSIndexPath indexPathWithIndex:0]] retain];
	for (id typesSet in typesSets) {
		[treeController insertObject:[self reduceTotalDictionary:totalDictionary forTypesSet:typesSet withTitle:[typesSet valueForKey:@"name"]] atArrangedObjectIndexPath:[NSIndexPath indexPathWithIndex:[[typesSet valueForKey:@"priority"] intValue]]];
	}
	[totalDictionary release];
	
#ifdef STATISTICS_MODULE_TRACE_METHODS
	printf("OUT [StatisticsModule completeTypesSetTreeController::]\n");
#endif
	
	return treeController;
}

- (void)updateValuesOfRoot:(NSMutableDictionary *)rootDictionary byRemovingPost:(NSDictionary *)postDictionary {
	printf("IN  [StatisticsModule updateValuesOfRoot:byRemovingPost:]\n");
	
	NSArray *keys = [rootDictionary allKeys];
	for (NSString *key in keys) {
		if (![key isEqualToString:@"element"] && ![key isEqualToString:childrenKeyPath]) {
			StatisticsCellData *newRootCellData = [[rootDictionary objectForKey:key] copy];
			float newValue = [[newRootCellData value] floatValue] - [[[postDictionary objectForKey:key] value] floatValue];
			[newRootCellData setValue:[NSNumber numberWithFloat:newValue]];
			[rootDictionary setObject:newRootCellData forKey:key];
		}
	}
	printf("OUT [StatisticsModule updateRootValuesOf:byRemovingPost:]\n");
}

- (void)updateValuesOfRoot:(NSMutableDictionary *)rootDictionary andPost:(NSMutableDictionary *)postDictionary byRemovingType:(NSDictionary *)typeDictionary {
	printf("IN  [StatisticsModule updateValuesOfRoot:andPost:byRemovingType:]\n");
	
	NSArray *keys = [postDictionary allKeys];
	for (NSString *key in keys) {
		if (![key isEqualToString:@"element"] && ![key isEqualToString:childrenKeyPath]) {
			StatisticsCellData *newRootCellData = [[rootDictionary objectForKey:key] copy];
			StatisticsCellData *newPostCellData = [[postDictionary objectForKey:key] copy];
			float rootNewValue = [[newRootCellData value] floatValue] - [[[typeDictionary objectForKey:key] value] floatValue];
			float postNewValue = [[newPostCellData value] floatValue] - [[[typeDictionary objectForKey:key] value] floatValue];
			[newRootCellData setValue:[NSNumber numberWithFloat:rootNewValue]];
			[newPostCellData setValue:[NSNumber numberWithFloat:postNewValue]];
			[rootDictionary setObject:newRootCellData forKey:key];
			[postDictionary setObject:newPostCellData forKey:key];
		}
	}
	printf("OUT [StatisticsModule updatePostValuesOf:byRemovingType:]\n");
}

/**
 Returns an array of NSDictionary entries, one for each typesSet registered in the document, plus the one containing all types. Each entry respects the common statistics format with balance values for each level, from typesSet to types (see class definition comment).
 */
- (NSArray *)balancesPerMonthForAllTypesSetAndPerson:(NSManagedObject *)person {
#ifdef STATISTICS_MODULE_TRACE_METHODS
	printf("IN  [StatisticsModule balancesPerMonthForAllTypesSetAndPerson:%s]\n", [[person valueForKey:@"name"] CSTRING]);
#endif
	
	/*NSTreeController *balancesForPersonTC = [[NSTreeController alloc] init];
	[balancesForPersonTC setChildrenKeyPath:childrenKeyPath];*/
	NSMutableArray *balancesForTypesSetArray = [NSMutableArray array];
	
	NSTimeZone *tz = [NSTimeZone localTimeZone];
	NSManagedObjectContext* managedObjectContext = [document managedObjectContext];
	NSFetchRequest* request = [[[NSFetchRequest alloc] init] autorelease];
	StatisticsCellData *totalCellData = [StatisticsCellData parentCellWithTitle:@"Total" correspondingManagedObject:nil];
	NSMutableDictionary *totalDictionary = [NSMutableDictionary dictionaryWithObject:totalCellData forKey:@"element"];
	
	// Fetching all posts
	NSArray *posts = [self posts];
	
	NSMutableArray *allTypesSetChildren = [NSMutableArray array];
	int i = 0;
	for (NSManagedObject *post in posts) {
		NSArray *types = [self typesForPost:post];
		
		StatisticsCellData *cellData = [StatisticsCellData parentCellWithTitle:[post valueForKey:@"name"] correspondingManagedObject:post];
		NSMutableDictionary *postDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:cellData, @"element", nil];
		NSMutableArray *childrenArray = [NSMutableArray array];
		
		for (NSManagedObject *type in types) {
			StatisticsCellData *cellData = [StatisticsCellData childCellWithTitle:[type valueForKey:@"name"] correspondingManagedObject:type];
			NSMutableDictionary *typeDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:cellData, @"element", nil];
			[request setEntity:[NSEntityDescription entityForName:@"Operation" inManagedObjectContext:managedObjectContext]];
			[request setSortDescriptors:[sortDescriptorsController operationsSortDescriptors]];
			
			NSCalendarDate *today = [NSCalendarDate date];
			int startMonth = [today monthOfYear];
			int startYear = (startMonth == 12 ? [today yearOfCommonEra] : [today yearOfCommonEra] - 1);
			int monthCount;
			int loopMonth = startMonth;
			int loopYear = startYear;
			for (monthCount = 0; monthCount < 12; monthCount++) {
				loopMonth++;
				if (loopMonth == 13) {
					loopMonth = 1;
					loopYear = startYear + 1;
				}
				NSCalendarDate *startDate = [NSCalendarDate dateWithYear:loopYear month:loopMonth day:1 hour:0 minute:0 second:0 timeZone:tz];
				NSCalendarDate *endDate = [startDate dateByAddingYears:0 months:1 days:-1 hours:23 minutes:59 seconds:59];
				[request setPredicate:[NSPredicate predicateWithFormat:@"type == %@ AND operationDate > %@ AND operationDate < %@ AND person == %@", type, startDate, endDate, person]];
				
				NSArrayController *operationsAC = [[NSArrayController alloc] init];
				[operationsAC setSelectsInsertedObjects:NO];
				[operationsAC addObjects:[managedObjectContext executeFetchRequest:request error:NULL]];
				
				StatisticsCellData *valueData = [StatisticsCellData childCellWithValue:[operationsAC valueForKeyPath:@"content.@sum.value"]];
				[typeDictionary setObject:valueData forKey:[NSString stringWithFormat:StatisticsColumnValueMonthIdentifierFormat, loopMonth]];
				
				NSNumber *totalOldValue = [totalDictionary objectForKey:[NSString stringWithFormat:StatisticsColumnValueMonthIdentifierFormat, loopMonth]];
				if (totalOldValue == nil) {
					[totalDictionary setObject:valueData forKey:[NSString stringWithFormat:StatisticsColumnValueMonthIdentifierFormat, loopMonth]];
				}
				else {
					[totalDictionary setObject:[StatisticsCellData parentCellWithValue:[NSNumber numberWithFloat:([[valueData value] floatValue] + [[totalOldValue value] floatValue])]] forKey:[NSString stringWithFormat:StatisticsColumnValueMonthIdentifierFormat, loopMonth]];
				}
				
				NSNumber *postOldValue = [postDictionary objectForKey:[NSString stringWithFormat:StatisticsColumnValueMonthIdentifierFormat, loopMonth]];
				if (postOldValue == nil) {
					[postDictionary setObject:valueData forKey:[NSString stringWithFormat:StatisticsColumnValueMonthIdentifierFormat, loopMonth]];
				}
				else {
					[postDictionary setObject:[StatisticsCellData parentCellWithValue:[NSNumber numberWithFloat:([[valueData value] floatValue] + [[postOldValue value] floatValue])]] forKey:[NSString stringWithFormat:StatisticsColumnValueMonthIdentifierFormat, loopMonth]];
				}
			}
			[childrenArray addObject:typeDictionary];
			
		}
		[postDictionary setObject:childrenArray forKey:childrenKeyPath];
		[allTypesSetChildren insertObject:postDictionary atIndex:i++];
	}
	[totalDictionary setObject:allTypesSetChildren forKey:childrenKeyPath];
	[balancesForTypesSetArray insertObject:totalDictionary atIndex:0];
	
	[self completeTypesSetArray:balancesForTypesSetArray];
	
#ifdef STATISTICS_MODULE_TRACE_METHODS
	printf("OUT [StatisticsModule postsBalancePerMonth]\n");
#endif
	
	return balancesForTypesSetArray;
}

/**
 Returns an array of NSDictionary entries, one for each typesSet registered in the document, plus the one containing all types. Each entry respects the common statistics format with balance values for each level, from typesSet to types (see class definition comment).
 */
- (NSArray *)balancesPerYearForAllTypesSetAndPerson:(NSManagedObject *)person {
#ifdef STATISTICS_MODULE_TRACE_METHODS
	printf("IN  [StatisticsModule balancesPerMonthForAllTypesSetAndPerson:%s]\n", [[person valueForKey:@"name"] CSTRING]);
#endif
	
	/*NSTreeController *balancesForPersonTC = [[NSTreeController alloc] init];
	 [balancesForPersonTC setChildrenKeyPath:childrenKeyPath];*/
	NSMutableArray *balancesForTypesSetArray = [NSMutableArray array];
	
	NSTimeZone *tz = [NSTimeZone localTimeZone];
	NSManagedObjectContext* managedObjectContext = [document managedObjectContext];
	NSFetchRequest* request = [[[NSFetchRequest alloc] init] autorelease];
	StatisticsCellData *totalCellData = [StatisticsCellData parentCellWithTitle:@"Total" correspondingManagedObject:nil];
	NSMutableDictionary *totalDictionary = [NSMutableDictionary dictionaryWithObject:totalCellData forKey:@"element"];
	
	int endYear = [self yearOfOldestOperation];

	// Fetching all posts
	NSArray *posts = [self posts];
	
	NSMutableArray *allTypesSetChildren = [NSMutableArray array];
	int i = 0;
	for (NSManagedObject *post in posts) {
		NSArray *types = [self typesForPost:post];
		
		StatisticsCellData *cellData = [StatisticsCellData parentCellWithTitle:[post valueForKey:@"name"] correspondingManagedObject:post];
		NSMutableDictionary *postDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:cellData, @"element", nil];
		NSMutableArray *childrenArray = [NSMutableArray array];
		
		for (NSManagedObject *type in types) {
			StatisticsCellData *cellData = [StatisticsCellData childCellWithTitle:[type valueForKey:@"name"] correspondingManagedObject:type];
			NSMutableDictionary *typeDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:cellData, @"element", nil];
			[request setEntity:[NSEntityDescription entityForName:@"Operation" inManagedObjectContext:managedObjectContext]];
			[request setSortDescriptors:[sortDescriptorsController operationsSortDescriptors]];
			
			// Getting current year
			NSCalendarDate *today = [NSCalendarDate date];
			int year = [today yearOfCommonEra];
			
			// Fetching operations for each year
			while (year >= endYear) {
				
				// Building fetch predicate
				NSCalendarDate *startDate = [NSCalendarDate dateWithYear:year month:1 day:1 hour:0 minute:0 second:0 timeZone:tz];
				NSCalendarDate *endDate = [startDate dateByAddingYears:1 months:0 days:-1 hours:23 minutes:59 seconds:59];
				NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type == %@ AND person == %@ AND operationDate > %@ AND operationDate < %@", type, person, startDate, endDate];
				[request setPredicate:predicate];
				
				NSArrayController *operationsAC = [[NSArrayController alloc] init];
				[operationsAC setSelectsInsertedObjects:NO];
				[operationsAC addObjects:[managedObjectContext executeFetchRequest:request error:NULL]];
				
				StatisticsCellData *valueData = [StatisticsCellData childCellWithValue:[operationsAC valueForKeyPath:@"content.@sum.value"]];
				[typeDictionary setObject:valueData forKey:[NSString stringWithFormat:StatisticsColumnValueYearIdentifierFormat, year]];
				
				NSNumber *totalOldValue = [totalDictionary objectForKey:[NSString stringWithFormat:StatisticsColumnValueYearIdentifierFormat, year]];
				if (totalOldValue == nil) {
					[totalDictionary setObject:valueData forKey:[NSString stringWithFormat:StatisticsColumnValueYearIdentifierFormat, year]];
				}
				else {
					[totalDictionary setObject:[StatisticsCellData parentCellWithValue:[NSNumber numberWithFloat:([[valueData value] floatValue] + [[totalOldValue value] floatValue])]] forKey:[NSString stringWithFormat:StatisticsColumnValueYearIdentifierFormat, year]];
				}
				
				NSNumber *postOldValue = [postDictionary objectForKey:[NSString stringWithFormat:StatisticsColumnValueYearIdentifierFormat, year]];
				if (postOldValue == nil) {
					[postDictionary setObject:valueData forKey:[NSString stringWithFormat:StatisticsColumnValueYearIdentifierFormat, year]];
				}
				else {
					[postDictionary setObject:[StatisticsCellData parentCellWithValue:[NSNumber numberWithFloat:([[valueData value] floatValue] + [[postOldValue value] floatValue])]] forKey:[NSString stringWithFormat:StatisticsColumnValueYearIdentifierFormat, year]];
				}
				
				// Closing the loop
				[operationsAC release];
				year--;
			}
			[childrenArray addObject:typeDictionary];
			
		}
		[postDictionary setObject:childrenArray forKey:childrenKeyPath];
		[allTypesSetChildren insertObject:postDictionary atIndex:i++];
	}
	[totalDictionary setObject:allTypesSetChildren forKey:childrenKeyPath];
	[balancesForTypesSetArray insertObject:totalDictionary atIndex:0];
	
	[self completeTypesSetArray:balancesForTypesSetArray];
	
#ifdef STATISTICS_MODULE_TRACE_METHODS
	printf("OUT [StatisticsModule postsBalancePerMonth]\n");
#endif
	
	return balancesForTypesSetArray;
}

/**
 - array: NSArray instance containing NSDictionary entries in standard statistics format (see class definition comment),
 - returns: an NSDictionary entry, following standard statistics format, representing the sum of all entries provided in array.
 
 Array content is expected to follow exactly the same hierarchy and structure.
 */
- (NSDictionary *)cumulateStatisticsEntries:(NSArray *)entriesArray  {
	NSMutableDictionary *cumulatedEntry = [NSMutableDictionary dictionary];
	
	//StatisticsCellData *cumulatedEntryTitleCellData = [StatisticsCellData parentCellWithTitle:@"CumulatedStatisticsEntry" correspondingManagedObjectPriority:nil];
	StatisticsCellData *cumulatedEntryTitleCellData = [StatisticsCellData parentCellWithTitle:@"CumulatedStatisticsEntry" correspondingManagedObject:nil];
	[cumulatedEntry setObject:cumulatedEntryTitleCellData forKey:@"element"];

	NSArray *allKeys = [(NSDictionary *)[entriesArray objectAtIndex:0] allKeys];
	for (NSString *key in allKeys) {
		if (![key isEqualToString:@"element"]) {
			if ([key isEqualToString:@"children"]) {
				NSMutableArray *childrenEntriesToCumulate = [NSMutableArray array];
			}
		}
	}
				
	
	return cumulatedEntry;
}


@end
