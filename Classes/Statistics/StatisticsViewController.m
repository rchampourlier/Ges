//
//  StatisticsViewController.m
//  Ges
//
//  Created by Romain Champourlier on 27/04/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "StatisticsViewController.h"


/**
 Controller for the statistics view.
 
 Data source for the statistics selection outline view:
 Depending on the selected statistics, the controller manages the creation of the needed interface components and bind them to the corresponding data, provided by the statistics module.
 
 Delegate for the statistics outline view.
 */

/*
 * TODO
 * - design specific view allowing seeing the horizontal header when horizontally scrolled
 * - allow selection of a cell, and displaying corresponding operations by double-clicking on it
 */

@interface StatisticsViewController (PrivateMethods)
- (Statistics)currentlyDisplayedStatistics;
@end

@implementation StatisticsViewController

- (id)init {
	
	self = [super init];
	if (self != nil) {
		currentlyDisplayedTC = nil;
		statisticsPostsMonthTC = nil;
		statisticsPostsYearTC = nil;
		statisticsPersonsMonthTC = nil;
		statisticsPersonsYearTC = nil;
		
		statisticsSelectionTC = [[[NSTreeController alloc] init] retain];
		[statisticsSelectionTC setChildrenKeyPath:@"children"];
		
		NSMutableDictionary *rootChild1 = [NSMutableDictionary dictionaryWithObjectsAndKeys:
										   [NSNumber numberWithBool:YES], @"isSourceGroup",
										   [NSDictionary dictionaryWithObjectsAndKeys:
											@"Posts", @"title",
											nil], @"contentDictionary", nil];
		
		NSMutableArray *rootChild1Children = [NSMutableArray array];
		[rootChild1Children addObject:[NSDictionary dictionaryWithObject:
									   [NSDictionary dictionaryWithObjectsAndKeys:
										@"Per Month", @"title",
										statisticsNamePostsMonth, @"statisticsLongName",
										nil] forKey:@"contentDictionary"]];
		[rootChild1Children addObject:[NSDictionary dictionaryWithObject:
									   [NSDictionary dictionaryWithObjectsAndKeys:
										@"Per Year", @"title",
										statisticsNamePostsYear, @"statisticsLongName",
										nil] forKey:@"contentDictionary"]];
		[rootChild1 setObject:rootChild1Children forKey:@"children"];
		
		NSMutableDictionary *rootChild2 = [NSMutableDictionary dictionaryWithObjectsAndKeys:
										   [NSNumber numberWithBool:YES], @"isSourceGroup",
										   [NSDictionary dictionaryWithObjectsAndKeys:
											@"Persons", @"title",
											nil], @"contentDictionary", nil];
		
		NSMutableArray *rootChild2Children = [NSMutableArray array];
		
		[rootChild2Children addObject:[NSDictionary dictionaryWithObject:
									   [NSDictionary dictionaryWithObjectsAndKeys:
										@"Per Month", @"title",
										statisticsNamePersonsMonth, @"statisticsLongName",
										nil] forKey:@"contentDictionary"]];
		[rootChild2Children addObject:[NSDictionary dictionaryWithObject:
									   [NSDictionary dictionaryWithObjectsAndKeys:
										@"Per Year", @"title",
										statisticsNamePersonsYear, @"statisticsLongName",
										nil] forKey:@"contentDictionary"]];
		[rootChild2 setObject:rootChild2Children forKey:@"children"];
		
		[statisticsSelectionTC insertObject:rootChild2 atArrangedObjectIndexPath:[NSIndexPath indexPathWithIndex:0]];
		[statisticsSelectionTC insertObject:rootChild1 atArrangedObjectIndexPath:[NSIndexPath indexPathWithIndex:0]];
		
		[statisticsSelectionTC setSelectionIndexPath:nil];
		[statisticsSelectionTC addObserver:self forKeyPath:@"selectionIndexPaths" options:0 context:NULL];
	}	
	return self;
}

- (void)dealloc {
	if (statisticsPostsMonthTC != nil) {
		[statisticsPostsMonthTC release];
	}
	if (statisticsPostsYearTC != nil) {
		[statisticsPostsYearTC release];
	}
	if (statisticsPersonsMonthTC != nil) {
		[statisticsPersonsYearTC release];
	}
	if (statisticsPersonsYearTC != nil) {
		[statisticsPersonsYearTC release];
	}
	
	[statisticsSelectionTC removeObserver:self forKeyPath:@"selectionIndexPaths"];
	[statisticsSelectionTC release];
	[super dealloc];
}

/**
 * Called once the nib file has been loaded.
 * 
 * Binds the statistics selection tree controller to the corresponding outline view.
 */
- (void)awakeFromNib {
	printf("IN  [StatisticsViewController awakeFromNib]\n");
	[statisticsSelectionView setAppearance:kSourceList_NumbersAppearance];
	
	[statisticsSelectionView bind:@"content" toObject:statisticsSelectionTC withKeyPath:@"arrangedObjects" options:nil];
	[[[statisticsSelectionView tableColumns] objectAtIndex:0] bind:@"value" toObject:statisticsSelectionTC withKeyPath:@"arrangedObjects.contentDictionary" options:nil];
	[statisticsSelectionView bind:@"selectionIndexPaths" toObject:statisticsSelectionTC withKeyPath:@"selectionIndexPaths" options:nil];
	
	[statisticsSelectionView expandItem:[statisticsSelectionView itemAtRow:0]];
	[statisticsSelectionView expandItem:[statisticsSelectionView itemAtRow:3]];
	
	[(NSTableColumn *)[[dataView tableColumns] objectAtIndex:0] setDataCell:[[StatisticsCell alloc] init]];
	[dataView registerForDraggedTypes:[NSArray arrayWithObjects:PasteboardRowTypePost, PasteboardRowTypeType, PasteboardRowTypeTypesSet, nil]];
	
	printf("OUT [StatisticsViewController awakeFromNib]\n");
}

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(id)context {
	printf("IN  [StatisticsViewController observeValueForKeyPath:...]\n");
	
	if ([displayedStatisticsLongName isEqualToString:statisticsNamePostsMonth] ||
		[displayedStatisticsLongName isEqualToString:statisticsNamePersonsMonth]) {
		[self hideStatisticsPerMonth];
	}
	else if ([displayedStatisticsLongName isEqualToString:statisticsNamePostsYear] ||
			 [displayedStatisticsLongName isEqualToString:statisticsNamePersonsYear]) {
		[self hideStatisticsPerYear];
	}
	
	if ([[statisticsSelectionTC selectedObjects] count] != 0) {
		displayedStatisticsLongName = [[[statisticsSelectionTC selectedObjects] objectAtIndex:0] valueForKeyPath:@"contentDictionary.statisticsLongName"];
		if ([displayedStatisticsLongName isEqualToString:statisticsNamePostsMonth]) {
			[self displayStatisticsPostsPerMonth];
		}
		else if ([displayedStatisticsLongName isEqualToString:statisticsNamePostsYear]) {
			[self displayStatisticsPostsPerYear];
		}
		else if ([displayedStatisticsLongName isEqualToString:statisticsNamePersonsYear]) {
			[self displayStatisticsPersonsPerYear];
		}
		else if ([displayedStatisticsLongName isEqualToString:statisticsNamePersonsMonth]) {
			[self displayStatisticsPersonsPerMonth];
		}
	}
	
	printf("OUT [StatisticsViewController observeValueForKeyPath:...]\n");
}


#pragma mark -
#pragma mark === Generic statistics display methods ===

- (void)displayStatisticsPerYearWithTreeController:(NSTreeController *)aTree {
	[dataView bind:@"content" toObject:aTree withKeyPath:@"arrangedObjects" options:nil];
	[[[dataView tableColumns] objectAtIndex:0] bind:@"value" toObject:aTree withKeyPath:@"arrangedObjects.element" options:nil];
	
	// Configuring the data view
	NSFont *columnFont = [(NSCell *)[[[dataView tableColumns] objectAtIndex:0] dataCell] font];
	NSTableColumn *column;
	
	unsigned int indexes[] = {0};
	int numberOfYear = [(NSDictionary *)[aTree objectAtArrangedIndexPath:[NSIndexPath indexPathWithIndexes:indexes length:1]] count] - 2;
	
	int year = [[NSCalendarDate date] yearOfCommonEra];
	int endYear = year - numberOfYear;
	while (year >= endYear) {
		column = [[NSTableColumn alloc] initWithIdentifier:[NSString stringWithFormat:StatisticsColumnValueYearIdentifierFormat, year]];
		[[column headerCell] setStringValue:[NSString stringWithFormat:@"%d", year]];
		[column setWidth:StatisticsColumnValueWidth];
		[column setEditable:NO];
		
		NSCell *dataCell = [[StatisticsCell alloc] init];
		[dataCell setFont:columnFont];
		[dataCell setAlignment:NSRightTextAlignment];
		[column setDataCell:dataCell];
		[column bind:@"value" toObject:aTree withKeyPath:[NSString stringWithFormat:@"arrangedObjects.%@", [NSString stringWithFormat:StatisticsColumnValueYearIdentifierFormat, year]] options:nil];
		[dataView addTableColumn:column];
		
		year--;
	}
}

- (void)hideStatisticsPerYear {
	[dataView unbind:@"content"];
	[[[dataView tableColumns] objectAtIndex:0] unbind:@"value"];
	
	NSArray *tableColumns = [dataView tableColumns];
	int numberOfColumns = [tableColumns count];
	
	int i = numberOfColumns - 1;
	while (i > 0) {
		NSTableColumn *tableColumn = [tableColumns objectAtIndex:i];
		[dataView removeTableColumn:tableColumn];
		i--;
	}
}

- (void)displayStatisticsPerMonthWithTreeController:(NSTreeController *)aTree {
	[dataView bind:@"content" toObject:aTree withKeyPath:@"arrangedObjects" options:nil];
	[[[dataView tableColumns] objectAtIndex:0] bind:@"value" toObject:aTree withKeyPath:@"arrangedObjects.element" options:nil];
	
	// Configuring the data view for 'months-of-the-year statistics' display.
	NSFont *columnFont = [(NSCell *)[[[dataView tableColumns] objectAtIndex:0] dataCell] font];
	NSTableColumn *column;
	
	// Other 12 columns: month values
	NSArray *shortMonthSymbols = [[[NSDateFormatter alloc] init] shortMonthSymbols];
	NSCalendarDate *today = [NSCalendarDate date];
	int startMonth = [today  monthOfYear];
	int loopMonth = startMonth;
	int loopYear = [today yearOfCommonEra];
	int monthCount;
	for (monthCount = 0; monthCount < 12; monthCount++) {
		column = [[NSTableColumn alloc] initWithIdentifier:[NSString stringWithFormat:StatisticsColumnValueMonthIdentifierFormat, loopMonth]];
		[[column headerCell] setStringValue:[NSString stringWithFormat:@"%@ %02d", [shortMonthSymbols objectAtIndex:loopMonth - 1], loopYear % 100]];
		[column setWidth:StatisticsColumnValueWidth];
		[column setEditable:NO];
		[column setDataCell:[[StatisticsCell alloc] init]];
		[[column dataCell] setFont:columnFont];
		[[column dataCell] setAlignment:NSRightTextAlignment];
		[column bind:@"value" toObject:aTree withKeyPath:[NSString stringWithFormat:@"arrangedObjects.%@", [NSString stringWithFormat:StatisticsColumnValueMonthIdentifierFormat, loopMonth]] options:nil];
		[dataView addTableColumn:column];
		
		loopMonth--;
		if (loopMonth == 0) {
			loopMonth = 12;
			loopYear--;
		}
	}
	
}

- (void)hideStatisticsPerMonth {
	[dataView unbind:@"content"];
	[[[dataView tableColumns] objectAtIndex:0] unbind:@"value"];
	
	// Other 12 columns: month values
	NSArray *shortMonthSymbols = [[[NSDateFormatter alloc] init] shortMonthSymbols];
	NSCalendarDate *today = [NSCalendarDate date];
	int startMonth = [today  monthOfYear];
	int loopMonth = startMonth;
	int loopYear = [today yearOfCommonEra];
	int monthCount;
	for (monthCount = 0; monthCount < 12; monthCount++) {
		[dataView removeTableColumn:[dataView tableColumnWithIdentifier:[NSString stringWithFormat:StatisticsColumnValueMonthIdentifierFormat, loopMonth]]];
		
		loopMonth--;
		if (loopMonth == 0) {
			loopMonth = 12;
			loopYear--;
		}
	}
}


#pragma mark -
#pragma mark === Statistics selection ===

- (void)displayStatisticsPostsPerMonth {
	printf("IN  [StatisticsViewController displayStatisticsPostsPerMonth]\n");
	
	if (currentlyDisplayedTC != nil) {
		[dataView unbind:@"selectionIndexPaths"];
	}
	
	if (statisticsPostsMonthTC == nil) {
		statisticsPostsMonthTC = [statisticsModule postsBalancePerMonth];
	}
	
	currentlyDisplayedTC = statisticsPostsMonthTC;
	[dataView bind:@"selectionIndexPaths" toObject:currentlyDisplayedTC withKeyPath:@"selectionIndexPaths" options:nil];
	[self displayStatisticsPerMonthWithTreeController:statisticsPostsMonthTC];
	
	printf("OUT [StatisticsViewController displayStatisticsPostsPerMonth]\n");
}

- (void)displayStatisticsPostsPerYear {
	printf("IN  [StatisticsViewController displayStatisticsPostsPerYear]\n");
	
	if (currentlyDisplayedTC != nil) {
		[dataView unbind:@"selectionIndexPaths"];
	}
	
	if (statisticsPostsYearTC == nil) {
		statisticsPostsYearTC = [statisticsModule postsBalancePerYear];
	}
	
	currentlyDisplayedTC = statisticsPostsYearTC;
	[dataView bind:@"selectionIndexPaths" toObject:currentlyDisplayedTC withKeyPath:@"selectionIndexPaths" options:nil];
	[self displayStatisticsPerYearWithTreeController:statisticsPostsYearTC];
	
	printf("OUT [StatisticsViewController displayStatisticsPostsPerYear]\n");
}

- (void)displayStatisticsPersonsPerMonth {
	printf("IN  [StatisticsViewController displayStatisticsPersonsPerMonth]\n");
	
	if (currentlyDisplayedTC != nil) {
		[dataView unbind:@"selectionIndexPaths"];
	}
	
	if (statisticsPersonsMonthTC == nil) {
		statisticsPersonsMonthTC = [statisticsModule personsBalancePerMonth];
	}
	
	currentlyDisplayedTC = statisticsPersonsMonthTC;
	[dataView bind:@"selectionIndexPaths" toObject:currentlyDisplayedTC withKeyPath:@"selectionIndexPaths" options:nil];
	[self displayStatisticsPerMonthWithTreeController:statisticsPersonsMonthTC];
	
	printf("OUT [StatisticsViewController displayStatisticsPersonsPerMonth]\n");
}

- (void)displayStatisticsPersonsPerYear {
	printf("IN  [StatisticsViewController displayStatisticsPersonsPerYear]\n");
	
	if (currentlyDisplayedTC != nil) {
		[dataView unbind:@"selectionIndexPaths"];
	}
	
	if (statisticsPersonsYearTC == nil) {
		statisticsPersonsYearTC = [statisticsModule personsBalancePerYear];
	}
	
	currentlyDisplayedTC = statisticsPersonsYearTC;
	[dataView bind:@"selectionIndexPaths" toObject:currentlyDisplayedTC withKeyPath:@"selectionIndexPaths" options:nil];
	[self displayStatisticsPerYearWithTreeController:statisticsPersonsYearTC];
	
	printf("OUT [StatisticsViewController displayStatisticsPersonsPerYear]\n");
}


#pragma mark -
#pragma mark === Manage types set ===

- (IBAction)addNewTypesSet:(id)sender {
	printf("IN  [StatisticsViewController addNewTypesSet]\n");
	
	[(MyDocument *)[[NSDocumentController sharedDocumentController] currentDocument] addTypesSet];
	if (statisticsPostsMonthTC != nil) {
		[statisticsPostsMonthTC release];
		statisticsPostsMonthTC = nil;
	}
	[statisticsModule updateStatistics:[self currentlyDisplayedStatistics] forTypesSet:currentlyDisplayedTC];
	[dataView reloadData];
	//[self displayStatisticsPostsPerMonth];
	
	printf("OUT [StatisticsViewController addNewTypesSet]\n");
}

- (void)delete {
	printf("IN  [StatisticsViewController delete]\n");
	
	// TODO: actions on data model should be sent to MyDocument instance
	
	MyDocument *document = (MyDocument *)[[NSDocumentController sharedDocumentController] currentDocument];
	NSManagedObjectContext *moc = [document managedObjectContext];
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	[request setEntity:[NSEntityDescription entityForName:EntityNameTypesSet inManagedObjectContext:moc]];
	[request setSortDescriptors:[SortDescriptorsController prioritySortDescriptors]];
	
	NSArray *typesSets = [moc executeFetchRequest:request error:NULL];
	NSArray *selectionIndexPaths = [currentlyDisplayedTC selectionIndexPaths];
	for (NSIndexPath *indexPath in selectionIndexPaths) {
		PrioritizedManagedObject *selectedTypesSet = [typesSets objectAtIndex:[indexPath indexAtPosition:0]];
		int indexPathLength = [indexPath length];
		if (indexPathLength == 1) {
			// A typesSet is selected. The typesSet itself should be deleted.
			//printf("removing typesSet <%s>\n", [[selectedTypesSet valueForKey:@"name"] CSTRING]);
			[document removeTypesSet:selectedTypesSet];
		}
		else if (indexPathLength == 2) {
			// A post is selected. All its types must be removed of the parent typesSet.
			[request setEntity:[NSEntityDescription entityForName:EntityNamePost inManagedObjectContext:moc]];
			
			/*StatisticsCellData *cellData = [[currentlyDisplayedTC objectAtArrangedIndexPath:indexPath] valueForKeyPath:@"element"];
			NSManagedObjectID *cellMOID = cellData.correspondingManagedObjectID;
			NSManagedObject *cellMO = [moc objectWithID:cellMOID];*/
			
			[request setPredicate:[NSPredicate predicateWithFormat:@"priority == %@", [[currentlyDisplayedTC objectAtArrangedIndexPath:indexPath] valueForKeyPath:@"element.correspondingObject.priority"]]];
			NSManagedObject *post = [[moc executeFetchRequest:request error:NULL] objectAtIndex:0];
			//printf("all types of post <%s> should be removed from typesSet <%s>\n", [[post valueForKey:@"name"] CSTRING], [[selectedTypesSet valueForKey:@"name"] CSTRING]);
			NSMutableSet *typesMutableSet = [selectedTypesSet mutableSetValueForKey:@"types"];
			for (NSManagedObject *type in [post valueForKey:@"types"]) {
				[typesMutableSet removeObject:type];
				//printf("type <%s> of post <%s> removed from typesSet <%s>\n", [[type valueForKey:@"name"] CSTRING], [[post valueForKey:@"name"] CSTRING], [[selectedTypesSet valueForKey:@"name"] CSTRING]);
			}
		}
		else {
			// A type is selected. Should be removed from the parent typesSet.
			[request setEntity:[NSEntityDescription entityForName:EntityNamePost inManagedObjectContext:moc]];
			NSUInteger indexes[2];
			indexes[0] = [indexPath indexAtPosition:0];
			indexes[1] = [indexPath indexAtPosition:1];
			NSIndexPath *postIndexPath = [NSIndexPath indexPathWithIndexes:indexes length:2];
			
			/*StatisticsCellData *cellData = [[currentlyDisplayedTC objectAtArrangedIndexPath:postIndexPath] valueForKeyPath:@"element"];
			NSManagedObjectID *cellMOID = cellData.correspondingManagedObjectID;
			NSManagedObject *cellMO = [moc objectWithID:cellMOID];*/
			
			[request setPredicate:[NSPredicate predicateWithFormat:@"priority == %@", [[[currentlyDisplayedTC objectAtArrangedIndexPath:postIndexPath] valueForKeyPath:@"element.correspondingObject.priority"] valueForKey:@"priority"]]];
			NSManagedObject *post = [[moc executeFetchRequest:request error:NULL] objectAtIndex:0];
			[request setEntity:[NSEntityDescription entityForName:EntityNameType inManagedObjectContext:moc]];
			
			/*cellData = [[currentlyDisplayedTC objectAtArrangedIndexPath:indexPath] valueForKeyPath:@"element"];
			cellMOID = cellData.correspondingManagedObjectID;
			cellMO = [moc objectWithID:cellMOID];*/
			
			[request setPredicate:[NSPredicate predicateWithFormat:@"post == %@ AND priority = %@", post, [[[currentlyDisplayedTC objectAtArrangedIndexPath:indexPath] valueForKeyPath:@"element.correspondingObject.priority"] valueForKey:@"priority"]]];
			NSManagedObject *type = [[moc executeFetchRequest:request error:NULL] objectAtIndex:0];
			//printf("type <%s> of post <%s> should be removed from typesSet <%s>\n", [[type valueForKey:@"name"] CSTRING], [[post valueForKey:@"name"] CSTRING], [[selectedTypesSet valueForKey:@"name"] CSTRING]);
			NSMutableSet *typesMutableSet = [selectedTypesSet mutableSetValueForKey:@"types"];
			[typesMutableSet removeObject:type];
		}
	}
	
	Statistics statistics = [self currentlyDisplayedStatistics];
	[statisticsModule updateStatistics:statistics forTypesSet:currentlyDisplayedTC];
	[dataView reloadData];
	
	printf("OUT [StatisticsViewController delete]\n");
}


#pragma mark -
#pragma mark === Drag'n'drop management


/**
 * Called when a drag operation is initiated from the table view. Since the drag'n'drop
 * operation is confined within the table view, we only copy the row indexes in the
 * pasteboard (following TableView Drag'N'Drop programming Guide from Apple).
 */
- (BOOL)outlineView:(NSOutlineView *)outlineView writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pboard {
	printf("IN  [StatisticsViewController outlineView:writeItems:toPasteboard:]\n");
	
	NSMutableArray *selectedPostTypes = [NSMutableArray array]; // an array which will contains dictionaries describing each selected typesSet item: "type" key -> the type of the item (typesSet, post, or type); "correspondingManagedObject" key -> the corresponding managed object. nil for the typesSet's level "Total" item.
	NSMutableArray *selectedPosts = [NSMutableArray array]; // idem, for posts
	NSMutableArray *selectedTypes = [NSMutableArray array]; // idem, for types

	for (NSTreeNode *item in items) {
		NSIndexPath *itemIndexPath = [item indexPath];
		
		NSString *pboardDataType;
		NSDictionary *representedObject = [item representedObject];
		StatisticsCellData *cellData = [representedObject objectForKey:@"element"];		
		
		/****
		 To write to pasteboard a reference to the managed object dragged, the
		 only way seems to use the NSURL representation of the object.
		 Other representations are not serializable.
		 ****/
		
		NSDictionary *itemDictionary;
		switch ([itemIndexPath length]) {
			case 1:
				// Item is a typesSet
				pboardDataType = PasteboardRowTypeTypesSet;
				
				if (cellData.correspondingObject == nil) {
					// Total typesSet selected
					itemDictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"totalTypesSet", @"type", nil];
					printf("added dictionary: typesSet=total\n");
				}
				else {
					itemDictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"typesSet", @"type", cellData.correspondingObjectURL, @"correspondingObjectURL", nil];
					printf("added dictionary: typesSet=%s\n", [[[(NSManagedObjectID *)[itemDictionary objectForKey:@"correspondingManagedObjectID"] URIRepresentation] path] CSTRING]);
				}
				[selectedPostTypes addObject:itemDictionary];
				break;
				
			case 2:
				// Item is a post
				pboardDataType = PasteboardRowTypePost;
				
				itemDictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"post", @"type", cellData.correspondingObjectURL, @"correspondingObjectURL", nil];
				[selectedPosts addObject:itemDictionary];
				
				printf("added dictionary: post=%s\n", [[[(NSManagedObjectID *)[itemDictionary objectForKey:@"correspondingManagedObjectID"] URIRepresentation] path] CSTRING]);
				break;

			case 3:
				// Item is a type
				pboardDataType = PasteboardRowTypePost;
				
				itemDictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"type", @"type", cellData.correspondingObjectURL, @"correspondingObjectURL", nil];
				[selectedTypes addObject:itemDictionary];
				
				printf("added dictionary: type=%s\n", [[[(NSManagedObjectID *)[itemDictionary objectForKey:@"correspondingManagedObjectID"] URIRepresentation] path] CSTRING]);
				break;
		}
	}
	
	NSData *postTypesData = [NSKeyedArchiver archivedDataWithRootObject:selectedPostTypes];
	NSData *postsData = [NSKeyedArchiver archivedDataWithRootObject:selectedPosts];
	NSData *typesData = [NSKeyedArchiver archivedDataWithRootObject:selectedTypes];
	
	[pboard declareTypes:[NSArray arrayWithObjects:PasteboardRowTypeTypesSet, PasteboardRowTypePost, PasteboardRowTypeType, nil] owner:self];
	[pboard setData:postTypesData forType:PasteboardRowTypeTypesSet];
	[pboard setData:postsData forType:PasteboardRowTypePost];
	[pboard setData:typesData forType:PasteboardRowTypeType];

	printf("OUT [StatisticsViewController outlineView:writeItems:toPasteboard:]\n");
	return YES;
}

/**
 * Called by the table view to determine if the drop destination is valid.
 * The drop operation is only validated if it is a "drop above" operation,
 * since it is used to sort the rows.
 */
- (NSDragOperation)outlineView:(NSOutlineView *)outlineView validateDrop:(id < NSDraggingInfo >)info proposedItem:(id)item proposedChildIndex:(NSInteger)index {
	printf("I/O [StatisticsViewController outlineView:validateDrop:proposedItem:proposedChildIndex:]\n");
	
	/*if (op == NSTableViewDropAbove) {
	 return NSDragOperationEvery;
	 }
	 else {
	 return NSDragOperationNone;
	 }*/
	return NSDragOperationEvery;
}

/**
 * Accepts a drop operation.
 *
 * The priority value is equal to the row position of the entity in the table view.
 * The dragged entity is updated with a priority value equal to the index of the row
 * where it is dropped. All entities between the dragged and the drop rows are shifted
 * consequently.
 */
- (BOOL)outlineView:(NSOutlineView *)outlineView acceptDrop:(id < NSDraggingInfo >)info item:(id)item childIndex:(NSInteger)index {
	printf("IN  [StatisticsViewController tableView:acceptDrop:item:childIndex:]\n");
	
	NSPasteboard* pboard = [info draggingPasteboard];
    /*NSData* itemsData = [pboard dataForType:StatisticsTableViewRowType];
	 NSArray* items = [NSKeyedUnarchiver unarchiveObjectWithData:itemsData];
	 int dragRow = [rowIndexes firstIndex];
	 
	 NSManagedObject *draggedObject;*/
	
	printf("OUT [StatisticsViewController tableView:acceptDrop:item:childIndex:]\n");
	return YES;
}

@end


@implementation StatisticsViewController (PrivateMethods)

- (Statistics)currentlyDisplayedStatistics {
	if (currentlyDisplayedTC == statisticsPostsMonthTC) {
		return StatisticsPostsBalanceMonth;
	}
	else if (currentlyDisplayedTC == statisticsPostsYearTC) {
		return StatisticsPostsBalanceYear;
	}
	else if (currentlyDisplayedTC == statisticsPersonsMonthTC) {
		return StatisticsPersonsBalanceMonth;
	}
	else if (currentlyDisplayedTC == statisticsPersonsYearTC) {
		return StatisticsPersonsBalanceYear;
	}
	return -1;
}
@end
