//
//  FilterController.m
//  Ges
//
//  Created by NeoJF on 16/06/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "FilterController.h"

static NSString *FilterPeriodLabelTextKeyBase = @"FilterPeriodLabelText";
typedef enum {PERIOD_1DAY, PERIOD_1WEEK, PERIOD_2WEEKS, PERIOD_1MONTH, PERIOD_2MONTHS, PERIOD_6MONTHS, PERIOD_1YEAR, PERIOD_2YEARS, PERIOD_ALLTIME} PeriodLength;

@interface FilterController (PrivateMethods)
- (NSPredicate *)predicateForFilter:(FilterManagedObject *)filter;
- (void)updateFilterObjectPredicate;
- (void)loadActiveFilter;
@end

@implementation FilterController


#pragma mark -
#pragma mark === Life cycle ===

- (id)init {
#ifdef FILTER_CONTROLLER_TRACE_METHODS
	printf("IN  [FilterController init]\n");
#endif
	
	self = [super init];

	if (self != nil) {
		isFilteringOperations = YES;
		filteringOperationsLevel = 0;
		period = nil;
		
		// Predicates
		stablePredicate = [[NSPredicate predicateWithFormat:@"account.filterState == 1 AND mode.filterState == 1 AND type.filterState == 1"] retain];

		filterPredicate = stablePredicate;
		filterObjectPredicate = [[NSPredicate predicateWithValue:YES] retain];
		periodPredicate = [[NSPredicate predicateWithValue:YES] retain];
		
		activeFilter = nil;
	}

#ifdef FILTER_CONTROLLER_TRACE_METHODS
	printf("OUT [FilterController init]\n");
#endif
	
	return self;
}

- (void)dealloc {
#ifdef FILTER_CONTROLLER_TRACE_METHODS
	printf("IN  [FilterController dealloc]\n");
#endif
	
	[self removeObservers];
	
	// Release retained objects
	[filterPredicate release];
	[filterObjectPredicate release];
	[searchFieldPredicate release];
	if (period != nil) [period release];	
	
	[super dealloc];
	
#ifdef FILTER_CONTROLLER_TRACE_METHODS
	printf("OUT [FilterController dealloc]\n");
#endif		
}

- (void)awakeFromNib {
#ifdef FILTER_CONTROLLER_TRACE_METHODS
	printf("IN  [FilterController awakeFromNib]\n");
#endif	
	
	[self addObservers];

	// TODO: should be set from a user-defined value (for example last selected value)
	[self setPeriod:[NSNumber numberWithUnsignedInt:6]];
	
	[self loadActiveFilter];
	
#ifdef FILTER_CONTROLLER_TRACE_METHODS
	printf("OUT [FilterController awakeFromNib]\n");
#endif	
}

- (void)addObservers {
#ifdef FILTER_CONTROLLER_TRACE_METHODS
	printf("IN  [FilterController addObservers]\n");
#endif	

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accountFilterStateModified:) name:NotificationNameAccountFilterStateModified object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(modeFilterStateModified:) name:NotificationNameModeFilterStateModified object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(typeFilterStateModified:) name:NotificationNameTypeFilterStateModified object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startFilteringOperations:) name:NotificationNameStartFilteringOperations object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopFilteringOperations:) name:NotificationNameStopFilteringOperations object:nil];

	//[filtersArrayController addObserver:self forKeyPath:@"content" options:0 context:nil];

#ifdef FILTER_CONTROLLER_TRACE_METHODS
	printf("OUT [FilterController addObservers] END\n");
#endif	
}

- (void)removeObservers {
#ifdef FILTER_CONTROLLER_TRACE_METHODS
	printf("IN  [FilterController removeObservers]\n");
#endif	
	
	//[filtersArrayController removeObserver:self forKeyPath:@"content"];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NotificationNameAccountFilterStateModified object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NotificationNameModeFilterStateModified object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NotificationNameTypeFilterStateModified object:nil];

#ifdef FILTER_CONTROLLER_TRACE_METHODS
	printf("OUT [FilterController removeObservers] END\n");
#endif	
}

- (void)managedObjectContextLoaded {
#ifdef FILTER_CONTROLLER_TRACE_METHODS
	printf("IN  [FilterController managedObjectContextLoaded]\n");
#endif
	
	/* Force fetching filters from managed object context in order to determine if a
	 * default one must be created and added to the opened document.
	 */
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSManagedObjectContext *moc = [(NSPersistentDocument *)[[NSDocumentController sharedDocumentController] currentDocument] managedObjectContext];
	[request setEntity:[NSEntityDescription entityForName:EntityNameFilter inManagedObjectContext:moc]];
	NSArray *filters = [moc executeFetchRequest:request error:NULL];
	printf("filter's count=%d\n", [filters count]);
	
	int filterCount = [filters count];
	if (filterCount == 0) {
		printf("creating first filter\n");
		activeFilter = [NSEntityDescription insertNewObjectForEntityForName:EntityNameFilter inManagedObjectContext:moc];
		[activeFilter setValue:[NSNumber numberWithInt:0] forKey:@"priority"];
		[personsArrayController prepareContent];
		[[activeFilter mutableSetValueForKey:@"persons"] addObjectsFromArray:[personsArrayController content]];
		[filtersArrayController rearrangeObjects];
		printf("filtersArrayController content's count=%d\n", [[filtersArrayController arrangedObjects] count]);
		[self updateFilterObjectPredicate];
	}
	
#ifdef FILTER_CONTROLLER_TRACE_METHODS
	printf("OUT [FilterController managedObjectContextLoaded]\n");
#endif
}	

#pragma mark -
#pragma mark === KVO ===

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(id)context {
#ifdef FILTER_CONTROLLER_TRACE_KVO
	printf("IN  [FilterController observeValueForKeyPath:...]\n");
#endif
	
	if (object == filtersArrayController) {
		// Filters in document have been loaded
		activeFilter = [[filtersArrayController arrangedObjects] lastObject];
		[editionSelectionSourceListController filterDidLoad];
		[self updateFilterObjectPredicate];
	}

#ifdef FILTER_CONTROLLER_TRACE_KVO
	printf("OUT [FilterController observeValueForKeyPath:...]\n");
#endif
}


#pragma mark -
#pragma mark === Notification handlers ===

- (void)accountFilterStateModified:(NSNotification *)aNotification {
#ifdef FILTER_CONTROLLER_TRACE_METHODS
	printf("IN  [FilterController accountFilterStateModified:]\n");
#endif
#ifdef FILTER_CONTROLLER_TRACE_NOTIFICATIONS
	printf("=== FilterController receiving notification:%s\n", [[aNotification name] cStringUsingEncoding:NSUTF8StringEncoding]);
#endif

	[self rearrangeOperations];
	
#ifdef FILTER_CONTROLLER_TRACE_METHODS
	printf("OUT [FilterController accountFilterStateModified:]\n");
#endif	
}

- (void)modeFilterStateModified:(NSNotification *)aNotification {
#ifdef FILTER_CONTROLLER_TRACE_METHODS
	printf("IN  [FilterController modeFilterStateModified:]\n");
#endif
#ifdef FILTER_CONTROLLER_TRACE_NOTIFICATIONS
	printf("=== FilterController receiving notification:%s\n", [[aNotification name] cStringUsingEncoding:NSUTF8StringEncoding]);
#endif
	
	[self rearrangeOperations];

#ifdef FILTER_CONTROLLER_TRACE_METHODS
	printf("OUT [FilterController modeFilterStateModified:]\n");
#endif
}

- (void)typeFilterStateModified:(NSNotification *)aNotification {
#ifdef FILTER_CONTROLLER_TRACE_METHODS
	printf("IN  [FilterController typeFilterStateModified:]\n");
#endif
#ifdef FILTER_CONTROLLER_TRACE_NOTIFICATIONS
	printf("=== FilterController receiving notification:%s\n", [[aNotification name] cStringUsingEncoding:NSUTF8StringEncoding]);
#endif

	[self rearrangeOperations];

#ifdef FILTER_CONTROLLER_TRACE_METHODS
	printf("OUT [FilterController typeFilterStateModified:]\n");
#endif
}

- (void)startFilteringOperations:(NSNotification *)aNotification {
#ifdef FILTER_CONTROLLER_TRACE_METHODS
	printf("IN  [FilterController startFilteringOperations:]\n");
#endif	
#ifdef FILTER_CONTROLLER_TRACE_NOTIFICATIONS
	printf("=== FilterController receiving notification:%s\n", [[aNotification name] cStringUsingEncoding:NSUTF8StringEncoding]);
#endif
	
	filteringOperationsLevel++;
#ifdef FILTER_CONTROLLER_TRACE_EVENTS
	if (filteringOperationsLevel == 0) printf("*** FilterController filteringOperationsLevel=0\n");
#endif
	
	if (filteringOperationsLevel == 0) {
		[self rearrangeOperations];
	}

#ifdef FILTER_CONTROLLER_TRACE_METHODS
	printf("OUT [FilterController startFilteringOperations:]\n");
#endif	
}

- (void)stopFilteringOperations:(NSNotification *)aNotification {
#ifdef FILTER_CONTROLLER_TRACE_METHODS
	printf("IN  [FilterController stopFilteringOperations:]\n");
#endif
#ifdef FILTER_CONTROLLER_TRACE_NOTIFICATIONS
	printf("=== FilterController receiving notification:%s\n", [[aNotification name] cStringUsingEncoding:NSUTF8StringEncoding]);
#endif

	filteringOperationsLevel--;

#ifdef FILTER_CONTROLLER_TRACE_METHODS
	printf("OUT [FilterController stopFilteringOperations:]\n");
#endif
}


/**
 * Called when the filter period changes.
 * Updates the filter predicate to include the a new period predicate corresponding
 * to the update value of the period property.
 *
 * Period's start depends on the choice of the user. Period's end is arbitrarely set
 * to current date plus 1 year.
 *
 * TODO: should update the "period" label in order to indicate the first day of the
 * displayed period.
 * TODO: should start from the selected operation's date instead of today
 */
- (void)updatePeriodPredicate {
	[periodPredicate release];
	
	NSCalendarDate *now = [NSCalendarDate date];
	NSCalendarDate *startDate = nil;
	NSCalendarDate *stopDate = [NSCalendarDate dateWithYear:[now yearOfCommonEra]+1 month:[now monthOfYear] day:[now dayOfMonth] hour:23 minute:59 second:59 timeZone:nil];
	
	switch ([period unsignedIntValue]) {
		case PERIOD_1DAY:
			// 1 day
			startDate = [NSCalendarDate dateWithYear:[now yearOfCommonEra] month:[now monthOfYear] day:[now dayOfMonth] hour:0 minute:0 second:0 timeZone:nil];
			//stopDate = [startDate dateByAddingYears:0 months:0 days:0 hours:23 minutes:59 seconds:59];
			break;
		case PERIOD_1WEEK:
			// 1 week
			startDate = [[NSCalendarDate dateWithYear:[now yearOfCommonEra] month:[now monthOfYear] day:[now dayOfMonth] hour:0 minute:0 second:0 timeZone:nil] dateByAddingYears:0 months:0 days:-7 hours:0 minutes:0 seconds:0];
			//stopDate = [startDate dateByAddingYears:0 months:0 days:6 hours:23 minutes:59 seconds:59];
			break;
		case PERIOD_2WEEKS:
			// 2 weeks
			startDate = [[NSCalendarDate dateWithYear:[now yearOfCommonEra] month:[now monthOfYear] day:[now dayOfMonth] hour:0 minute:0 second:0 timeZone:nil] dateByAddingYears:0 months:0 days:-14 hours:0 minutes:0 seconds:0];
			//stopDate = [startDate dateByAddingYears:0 months:0 days:13 hours:23 minutes:59 seconds:59];
			break;
		case PERIOD_1MONTH:
			// 1 month
			startDate = [[NSCalendarDate dateWithYear:[now yearOfCommonEra] month:[now monthOfYear] day:[now dayOfMonth] hour:0 minute:0 second:0 timeZone:nil] dateByAddingYears:0 months:-1 days:0 hours:0 minutes:0 seconds:0];
			//stopDate = [startDate dateByAddingYears:0 months:1 days:-1 hours:23 minutes:59 seconds:59];
			break;
		case PERIOD_2MONTHS:
			// 2 months
			startDate = [[NSCalendarDate dateWithYear:[now yearOfCommonEra] month:[now monthOfYear] day:[now dayOfMonth] hour:0 minute:0 second:0 timeZone:nil] dateByAddingYears:0 months:-2 days:0 hours:0 minutes:0 seconds:0];
			//stopDate = [startDate dateByAddingYears:0 months:2 days:-1 hours:23 minutes:59 seconds:59];
			break;
		case PERIOD_6MONTHS:
			// 6 months
			startDate = [[NSCalendarDate dateWithYear:[now yearOfCommonEra] month:[now monthOfYear] day:[now dayOfMonth] hour:0 minute:0 second:0 timeZone:nil] dateByAddingYears:0 months:-6 days:0 hours:0 minutes:0 seconds:0];
			//stopDate = [startDate dateByAddingYears:0 months:6 days:-1 hours:23 minutes:59 seconds:59];
			break;
		case PERIOD_1YEAR:
			// 1 year
			startDate = [[NSCalendarDate dateWithYear:[now yearOfCommonEra] month:[now monthOfYear] day:[now dayOfMonth] hour:0 minute:0 second:0 timeZone:nil] dateByAddingYears:-1 months:0 days:0 hours:0 minutes:0 seconds:0];
			//stopDate = [startDate dateByAddingYears:1 months:0 days:-1 hours:23 minutes:59 seconds:59];
			break;
		case PERIOD_2YEARS:
			// 2 years
			startDate = [[NSCalendarDate dateWithYear:[now yearOfCommonEra] month:[now monthOfYear] day:[now dayOfMonth] hour:0 minute:0 second:0 timeZone:nil] dateByAddingYears:-2 months:0 days:0 hours:0 minutes:0 seconds:0];
			//stopDate = [startDate dateByAddingYears:2 months:0 days:-1 hours:23 minutes:59 seconds:59];
			break;
		case PERIOD_ALLTIME:
			// All time
			break;
	}
	
	if (startDate == nil) {
		periodPredicate = [NSPredicate predicateWithValue:YES];
	}
	else {
		//printf("startDate:%s stopDate:%s\n", [[startDate description] CSTRING], [[stopDate description] CSTRING]);
		periodPredicate = [[NSPredicate predicateWithFormat:@"operationDate >= %@ AND operationDate <= %@", startDate, stopDate] retain];
	}
	[self updateFilterPredicate];
}

- (void)setSearchFieldPredicate:(NSPredicate *)aPredicate {
#ifdef FILTER_CONTROLLER_TRACE_METHODS
	printf("IN  [FilterController setSearchFieldPredicate:]\n");
#endif

	if (searchFieldPredicate != nil) {
		[searchFieldPredicate release];
	}
	searchFieldPredicate = [aPredicate retain];
	[self updateFilterPredicate];
	[self rearrangeOperations];
	
#ifdef FILTER_CONTROLLER_TRACE_METHODS
	printf("OUT [FilterController setSearchFieldPredicate:]\n");
#endif
}

- (void)setPeriod:(NSNumber *)number {
#ifdef FILTER_CONTROLLER_TRACE_METHODS
	printf("IN  [FilterController setPeriod:%u]\n", [number unsignedIntValue]);
#endif
 
	// NOW: implement a subclass of NSSlider capable of sending events when reachin another tick,
	// in order to update another control (label), even if not set (mouse released).
	
	if (period != nil) [period release];
	period = [number retain];
 
	NSString *keyString = [NSString stringWithFormat:@"%@%u", FilterPeriodLabelTextKeyBase, [number unsignedIntValue]];
	//printf("keyString:%s label: %s\n", [keyString CSTRING], [NSLocalizedString(keyString, nil) CSTRING]);
	[filterPeriodLabel setStringValue:NSLocalizedString(keyString, nil)];
	
	[self updatePeriodPredicate];
	
#ifdef FILTER_CONTROLLER_TRACE_METHODS
	printf("OUT [FilterController setPeriod:%u]\n", [period unsignedIntValue]);
#endif
}


#pragma mark -
#pragma mark === Filter actions ===

- (void)rearrangeOperations {
	if (filteringOperationsLevel == 0) {
#ifdef FILTER_CONTROLLER_TRACE_EVENTS
		printf("*** FilterController rearranging operations\n");
#endif
		[operationsArrayController rearrangeObjects];
	}
}


#pragma mark -
#pragma mark === Predicate management ===

- (NSPredicate *)constructPredicate {
#ifdef FILTER_CONTROLLER_TRACE_METHODS
	printf("IN  [FilterController constructPredicate]\n");
#endif
		
	NSMutableArray *subpredicates = [NSMutableArray array];
	[subpredicates addObject:stablePredicate];
	[subpredicates addObject:periodPredicate];
	[subpredicates addObject:filterObjectPredicate];
	if (searchFieldPredicate != nil) {
		[subpredicates addObject:searchFieldPredicate];
	}
	
#ifdef FILTER_CONTROLLER_TRACE_METHODS
	printf("OUT [FilterController constructPredicate]\n");
#endif
	return [NSCompoundPredicate andPredicateWithSubpredicates:subpredicates];
}

/**
 * Updates self's filterPredicate property by calling -(void)constructPredicate: on self
 * and retaining the result.
 *
 * NB: filterPredicate property's change is advertised by using willChangeValueForKey: and 
 * didChangeValueForKey:.
 */
- (void)updateFilterPredicate {
#ifdef FILTER_CONTROLLER_TRACE_METHODS
	printf("IN  [FilterController updateFilterPredicate]\n");
#endif
	
	[self willChangeValueForKey:@"filterPredicate"];
	filterPredicate = [[self constructPredicate] retain];
	[self didChangeValueForKey:@"filterPredicate"];

#ifdef FILTER_CONTROLLER_TRACE_METHODS
	printf("OUT [FilterController updateFilterPredicate]\n");
#endif
}

#pragma mark -
#pragma mark === Other predicates ===

/**
 * Returns a predicate for filtering model entities being allowed for display (entities
 * with filterState property equal to 1.
 *
 * Used to feed the AccountsBeingDisplayed array controller in the interface file with
 * displayed accounts only.
 */
- (NSPredicate *)displayedEntityPredicate {
	return [NSPredicate predicateWithFormat:@"filterState == 1"];
}


#pragma mark -
#pragma mark === Test for active filter ===

- (BOOL)activeFilterContainsObject:(NSManagedObject *)anObject {
#ifdef FILTER_CONTROLLER_TRACE_METHODS
	printf("I/O [FilterController activeFilterContainsObject] -> %s\n", [activeFilter containsObject:anObject] ? "YES" : "NO");
#endif
	return [activeFilter containsObject:anObject];
}


#pragma mark -
#pragma mark === Actions on active filter ===

- (void)inverseObjectStateInActiveFilter:(NSManagedObject *)anObject {
#ifdef FILTER_CONTROLLER_TRACE_METHODS
	printf("IN  [FilterController inverseObjectStateInActiveFilter:]\n");
#endif
	
	// Update active filter
	[activeFilter inverseObjectStateInActiveFilter:anObject];
	
	/* Advertise editionSelectionSourceListController which displays some of
	 * the active filter's characteristics of the change.
	 */
	if ([activeFilter containsObject:anObject]) {
		[editionSelectionSourceListController filterInclude:anObject];
	}
	else {
		[editionSelectionSourceListController filterExclude:anObject];
	}
	
	[self updateFilterObjectPredicate];
#ifdef FILTER_CONTROLLER_TRACE_METHODS
	printf("OUT [FilterController inverseObjectStateInActiveFilter:]\n");
#endif
}

- (void)includeFromSameTypeOnly:(NSManagedObject *)anObject {
#ifdef FILTER_CONTROLLER_TRACE_METHODS
	printf("IN  [FilterController excludeOtherObjectsFromActiveFilter:]\n");
#endif
	
	// Update active filter
	[activeFilter includeFromSameTypeOnly:anObject];
	
	/* Advertise editionSelectionSourceListController which displays some of
	 * the active filter's characteristics of the change.
	 */
	for (id object in [personsArrayController content]) {
		if (object != anObject) {
			[editionSelectionSourceListController filterExclude:object];
		}
		else {
			[editionSelectionSourceListController filterInclude:object];
		}
	}
	
	[self updateFilterObjectPredicate];
#ifdef FILTER_CONTROLLER_TRACE_METHODS
	printf("OUT [FilterController excludeOtherObjectsFromActiveFilter:]\n");
#endif
}

- (void)includeAllObjectForEntityName:(NSString *)entityName {
#ifdef FILTER_CONTROLLER_TRACE_METHODS
	printf("IN  [FilterController includeAllObjectForEntityName:]\n");
#endif
	
	for (id object in [personsArrayController content]) {
		// Update active filter
		[activeFilter include:object];
	
		/* Advertise editionSelectionSourceListController which displays some of
		 * the active filter's characteristics of the change.
		 */
		[editionSelectionSourceListController filterInclude:object];
	}
	
	[self updateFilterObjectPredicate];
#ifdef FILTER_CONTROLLER_TRACE_METHODS
	printf("OUT [FilterController includeAllObjectForEntityName:]\n");
#endif
}


#pragma mark -
#pragma mark === PrivateMethods ===

/**
 * Returns the predicate corresponding to the provided FilterManagedObject
 * object.
 */
- (NSPredicate *)predicateForFilter:(FilterManagedObject *)filter {
#ifdef FILTER_CONTROLLER_TRACE_METHODS
	printf("IN  [FilterController predicateForFilter:]\n");
#endif
	
	NSSet *personsInFilter = [filter valueForKey:@"persons"];
	NSMutableArray *subpredicates = [NSMutableArray array];
	for (id person in personsInFilter) {
		[subpredicates addObject:[NSPredicate predicateWithFormat:@"person == %@", person]];
	}

#ifdef FILTER_CONTROLLER_TRACE_METHODS
	printf("OUT [FilterController predicateForFilter:]\n");
#endif	
	return [NSCompoundPredicate orPredicateWithSubpredicates:subpredicates];
}

/**
 * Updates filterObjectPredicate with the value returned by -(NSPredicate *)predicateForFilter:activeFilter
 * on self.
 * It then calls -(void)updateFilterPredicate on self to update the final filter and advertise its change.
 */
- (void)updateFilterObjectPredicate {
#ifdef FILTER_CONTROLLER_TRACE_METHODS
	printf("IN  [FilterController updateFilterObjectPredicate]\n");
#endif
	
	[filterObjectPredicate release];
	filterObjectPredicate = [[self predicateForFilter:activeFilter] retain];
	[self updateFilterPredicate];
	
#ifdef FILTER_CONTROLLER_TRACE_METHODS
	printf("OUT [FilterController updateFilterObjectPredicate]\n");
#endif	
}

/*
 * This methods loads the active filter from the document. It relies on the filtersArrayController, and
 * ensures its content is loaded (by requesting it to fetch the content if empty).
 *
 * There is currently only one filter to be expected in the document, it is thus considered as the active
 * filter by default. Future evolutions are expected to allow multiple filters, fetching the active one
 * will then be required.
 */
- (void)loadActiveFilter {
#ifdef FILTER_CONTROLLER_TRACE_METHODS
	printf("IN  [FilterController loadActiveFilter]\n");
#endif
	
	if ([[filtersArrayController content] count] == 0) {
		// filtersArrayController has no content. It may be empty, but it may not be loaded at this time. Force it to load its data.
		NSError *error = nil;
		[filtersArrayController fetchWithRequest:nil merge:YES error:&error];
		if ([[filtersArrayController content] count] == 0) {
			// filtersArrayController still has no content. We can now assume there is no filter object in the loaded document. We thus create one now.
			printf("creating first filter\n");
			NSManagedObjectContext *moc = [filtersArrayController managedObjectContext];
			activeFilter = [NSEntityDescription insertNewObjectForEntityForName:EntityNameFilter inManagedObjectContext:moc];
			[activeFilter setValue:[NSNumber numberWithInt:0] forKey:@"priority"];
			[personsArrayController prepareContent];
			[[activeFilter mutableSetValueForKey:@"persons"] addObjectsFromArray:[personsArrayController content]];
			[filtersArrayController rearrangeObjects];
			printf("filtersArrayController content's count=%d\n", [[filtersArrayController arrangedObjects] count]);
			[self updateFilterObjectPredicate];
		}
	}
	activeFilter = [[filtersArrayController content] lastObject];
	[editionSelectionSourceListController filterDidLoad];
	[self updateFilterObjectPredicate];
	
#ifdef FILTER_CONTROLLER_TRACE_METHODS
	printf("OUT [FilterController loadActiveFilter]\n");
#endif	
}

@synthesize accountsArrayController;
@synthesize filterPredicate;
@synthesize newOperationAccount;
@synthesize newMode;
@synthesize newOperationPost;
@synthesize newType;
@synthesize operationsArrayController;
@synthesize period;
@synthesize searchFieldPredicate;
@synthesize stablePredicate;
@synthesize typesArrayController;

@end
