//
//  EditionSelectionSourceListController.m
//  Ges
//
//  Created by Romain Champourlier on 30/06/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#define ACCOUNT_GROUPS_GROUP_INDEX_PATH 0
#define ACCOUNTS_GROUP_INDEX_PATH 1
#define POSTS_GROUP_INDEX_PATH 2
#define PERSONS_GROUP_INDEX_PATH 3

#import "EditionSelectionSourceListController.h"



@interface EditionSelectionSourceListController(PrivateMethods)
- (NSManagedObject *)representedObjectForItem:(id)item;
- (NSArray *)allObjectsOfCategoryOfRepresentedObjectForItem:(id)item;
@end

@implementation EditionSelectionSourceListController

#pragma mark -
#pragma mark === Life cycle ===

- (id)init {
#ifdef EDITION_SELECTION_SOURCE_LIST_CONTROLLER_TRACE_METHODS
	printf("IN  [EditionSelectionSourceListController init]\n");
#endif
	self = [super init];
	if (self != nil) {
		[self addObservers];
	}
#ifdef EDITION_SELECTION_SOURCE_LIST_CONTROLLER_TRACE_METHODS
	printf("OUT [EditionSelectionSourceListController init]\n");
#endif
	return self;
}

- (void)dealloc {
	[self removeObservers];
	[super dealloc];
}

- (void)addObservers {
#ifdef EDITION_SELECTION_SOURCE_LIST_CONTROLLER_TRACE_METHODS
	printf("IN  [EditionSelectionSourceListController addObservers]\n");
#endif

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accountFilterStateModified:) name:NotificationNameAccountFilterStateModified object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(personFilterStateModified:) name:NotificationNamePersonFilterStateModified object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postFilterStateModified:) name:NotificationNamePostFilterStateModified object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(typeFilterStateModified:) name:NotificationNameTypeFilterStateModified object:nil];
	
#ifdef EDITION_SELECTION_SOURCE_LIST_CONTROLLER_TRACE_METHODS
	printf("OUT [EditionSelectionSourceListController addObservers]\n");
#endif
}

- (void)removeObservers {
#ifdef EDITION_SELECTION_SOURCE_LIST_CONTROLLER_TRACE_METHODS
	printf("IN  [EditionSelectionSourceListController removeObservers]\n");
#endif
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];

#ifdef EDITION_SELECTION_SOURCE_LIST_CONTROLLER_TRACE_METHODS
	printf("OUT [EditionSelectionSourceListController removeObservers]\n");
#endif
}


- (void)dataDidLoad {
	dataDidLoad = YES;
	if (filterDidLoad) {
		[self fillSourceListView];
	}
}

#pragma mark -
#pragma mark === Update methods ===

- (void)accountFilterStateModified:(NSNotification *)aNotification {
#ifdef EDITION_SELECTION_SOURCE_LIST_CONTROLLER_TRACE_METHODS
	printf("IN  [EditionSelectionSourceListController accountFilterStateModified:]\n");
#endif
	
	NSManagedObject *account = [[aNotification userInfo] valueForKey:NotificationUserInfoKeyFilterStateObject];
	int priority = [[[[aNotification userInfo] valueForKey:NotificationUserInfoKeyFilterStateObject] valueForKey:@"priority"] intValue];
	
	NSEnumerator *accountNodes = [[[[[sourceListTreeController arrangedObjects] childNodes] objectAtIndex:ACCOUNTS_GROUP_INDEX_PATH] childNodes] objectEnumerator];
	id accountNode;
	while (accountNode = [accountNodes nextObject]) {
		if ([[[accountNode representedObject] valueForKeyPath:@"contentDictionary.priority"] intValue] == priority) {
			[[accountNode representedObject] setValue:[account valueForKey:@"filterState"] forKeyPath:@"contentDictionary.filterState"];
		}
	}
	
	[sourceListView reloadData];
	
#ifdef EDITION_SELECTION_SOURCE_LIST_CONTROLLER_TRACE_METHODS_END
	printf("OUT [EditionSelectionSourceListController accountFilterStateModified:] END\n");
#endif
}

/*- (void)personFilterStateModified:(NSNotification *)aNotification {
#ifdef EDITION_SELECTION_SOURCE_LIST_CONTROLLER_TRACE_METHODS
	printf("IN  [EditionSelectionSourceListController personFilterStateModified:]\n");
#endif
	
	NSManagedObject *person = [[aNotification userInfo] valueForKey:NotificationUserInfoKeyFilterStateObject];
	int priority = [[[[aNotification userInfo] valueForKey:NotificationUserInfoKeyFilterStateObject] valueForKey:@"priority"] intValue];
	
	NSArray *personNodes = [[[[sourceListTreeController arrangedObjects] childNodes] objectAtIndex:0] childNodes];
	for (id personNode in personNodes) {
		if ([[[personNode representedObject] valueForKeyPath:@"contentDictionary.priority"] intValue] == priority) {
			[[personNode representedObject] setValue:[person valueForKey:@"filterState"] forKeyPath:@"contentDictionary.filterState"];
		}
	}
	
	[sourceListView reloadData];
	
#ifdef EDITION_SELECTION_SOURCE_LIST_CONTROLLER_TRACE_METHODS_END
	printf("OUT [EditionSelectionSourceListController personFilterStateModified:] END\n");
#endif
}*/

- (void)postFilterStateModified:(NSNotification *)aNotification {
#ifdef EDITION_SELECTION_SOURCE_LIST_CONTROLLER_TRACE_METHODS
	printf("IN  [EditionSelectionSourceListController postFilterStateModified:]\n");
#endif
	
	NSManagedObject *post = [[aNotification userInfo] valueForKey:NotificationUserInfoKeyFilterStateObject];
	int priority = [[[[aNotification userInfo] valueForKey:NotificationUserInfoKeyFilterStateObject] valueForKey:@"priority"] intValue];
	
	NSString *itemName = [post valueForKey:@"name"];
	NSNumber *filterState = [post valueForKey:@"filterState"];
	if ([filterState intValue] == -1) {
		int activeTypesCount = [[post valueForKey:@"activeTypesCount"] intValue];
		int totalTypesCount = [[post valueForKey:@"types"] count];
		itemName = [NSString stringWithFormat:@"%@ (%d/%d)", itemName, activeTypesCount, totalTypesCount];
	}
	
	NSEnumerator *postNodes = [[[[[sourceListTreeController arrangedObjects] childNodes] objectAtIndex:POSTS_GROUP_INDEX_PATH] childNodes] objectEnumerator];
	id postNode;
	while (postNode = [postNodes nextObject]) {
		id postObject = [postNode representedObject];
		if ([[postObject valueForKeyPath:@"contentDictionary.priority"] intValue] == priority) {
			[postObject setValue:itemName forKeyPath:@"contentDictionary.name"];
			[postObject setValue:filterState forKeyPath:@"contentDictionary.filterState"];
		}
	}
	
	[sourceListView reloadData];

#ifdef EDITION_SELECTION_SOURCE_LIST_CONTROLLER_TRACE_METHODS_END
	printf("OUT [EditionSelectionSourceListController postFilterStateModified:]\n");
#endif
}

- (void)typeFilterStateModified:(NSNotification *)aNotification {
#ifdef EDITION_SELECTION_SOURCE_LIST_CONTROLLER_TRACE_METHODS
	printf("IN  [EditionSelectionSourceListController typeFilterStateModified:(type=%s)]\n", [[[[aNotification userInfo] valueForKey:NotificationUserInfoKeyFilterStateObject] valueForKey:@"name"] cString]);
#endif
	
	NSManagedObject *type = [[aNotification userInfo] valueForKey:NotificationUserInfoKeyFilterStateObject];
	int priority = [[[[aNotification userInfo] valueForKey:NotificationUserInfoKeyFilterStateObject] valueForKey:@"priority"] intValue];
	int postPriority = [[[[aNotification userInfo] valueForKey:NotificationUserInfoKeyFilterStateObject] valueForKeyPath:@"post.priority"] intValue];
	//printf("arrangedObjects: %s\n", [[[[sourceListTreeController arrangedObjects] representedObject] valueForKey:@"name"] cString]);
	
	//printf("indexPath: %d.%d.%d\n", 1, postPriority + 1, priority);
	unsigned int indexes[] = {POSTS_GROUP_INDEX_PATH, postPriority + 1, priority};
	NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:indexes length:3];
	
	/*[sourceListTreeController removeObjectAtArrangedObjectIndexPath:indexPath];
	[sourceListTreeController insertObject:[NSMutableDictionary dictionaryWithObject:[NSDictionary dictionaryWithObjectsAndKeys:[type valueForKey:@"name"], @"name", @"post", @"category", [type valueForKey:@"priority"], @"priority", [type valueForKey:@"filterState"], @"filterState", nil] forKey:@"contentDictionary"] atArrangedObjectIndexPath:indexPath];	*/
	
	NSEnumerator *postNodes = [[[[[sourceListTreeController arrangedObjects] childNodes] objectAtIndex:POSTS_GROUP_INDEX_PATH] childNodes] objectEnumerator];
	id postNode;
	while (postNode = [postNodes nextObject]) {
		
		if ([[[postNode representedObject] valueForKeyPath:@"contentDictionary.priority"] intValue] == postPriority) {
			
			NSEnumerator *typeNodes = [[postNode childNodes] objectEnumerator];
			id typeNode;
			while (typeNode = [typeNodes nextObject]) {
				
				if ([[[typeNode representedObject] valueForKeyPath:@"contentDictionary.priority"] intValue] == priority) {
					[[typeNode representedObject] setValue:[type valueForKey:@"filterState"] forKeyPath:@"contentDictionary.filterState"];
				}
			}
		}
	}	
	
	[sourceListView reloadData];

#ifdef EDITION_SELECTION_SOURCE_LIST_CONTROLLER_TRACE_METHODS_END
	printf("OUT [EditionSelectionSourceListController typeFilterStateModified:]\n");
#endif
}


#pragma mark -
#pragma mark === FilterObserver protocol ===

- (void)filterDidLoad {
	filterDidLoad = YES;
	if (dataDidLoad) {
		[self fillSourceListView];
	}
}

- (void)filterInclude:(NSManagedObject *)object {
	printf("IN  [EditionSelectionSourceListController filterInclude:]\n");
	if ([[[object entity] name] isEqualToString:EntityNamePerson]) {
		PersonManagedObject *person = (PersonManagedObject *)object;
		NSUInteger indexes[2] = {PERSONS_GROUP_INDEX_PATH, [[person valueForKey:@"priority"] intValue]+1};
		[[sourceListTreeController objectAtArrangedIndexPath:[NSIndexPath indexPathWithIndexes:indexes length:2]] setValue:[NSNumber numberWithBool:YES] forKeyPath:@"contentDictionary.filterState"];
		[sourceListView reloadData];
	}
	printf("OUT [EditionSelectionSourceListController filterInclude:]\n");
}

- (void)filterExclude:(NSManagedObject *)object {
	printf("IN  [EditionSelectionSourceListController filterExclude:]\n");
	if ([[[object entity] name] isEqualToString:EntityNamePerson]) {
		PersonManagedObject *person = (PersonManagedObject *)object;
		NSUInteger indexes[2] = {PERSONS_GROUP_INDEX_PATH, [[person valueForKey:@"priority"] intValue]+1};
		[[sourceListTreeController objectAtArrangedIndexPath:[NSIndexPath indexPathWithIndexes:indexes length:2]] setValue:[NSNumber numberWithBool:NO] forKeyPath:@"contentDictionary.filterState"];
		[sourceListView reloadData];
	}
	printf("OUT [EditionSelectionSourceListController filterExclude:]\n");
}


#pragma mark -
#pragma mark === Content control ===

/**
 * In the source list tree controller, we insert only NSMutableDictionary instances
 * since the controller needs them to be mutable in order to be able to insert
 * the children as a "children" property.
 */
- (void)fillSourceListView {
#ifdef EDITION_SELECTION_SOURCE_LIST_CONTROLLER_TRACE_METHODS
	printf("IN  [EditionSelectionSourceListController fillSourceListView]\n");
#endif
	
	[sourceListTreeController setContent:nil];
	
	unsigned int indexes[] = {0, 0};
	indexes[0] = ACCOUNT_GROUPS_GROUP_INDEX_PATH;
	
	// EDIT NOW CURRENT
	// Groups section
	[sourceListTreeController insertObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
											[NSNumber numberWithBool:YES], @"isSourceGroup",
											[NSDictionary dictionaryWithObject:@"ACCOUNT GROUPS" forKey:@"name"], @"contentDictionary", nil]
				 atArrangedObjectIndexPath:[NSIndexPath indexPathWithIndex:indexes[0]]];
	NSArray *accountGroups = [accountGroupsArrayController arrangedObjects];
	if ([accountGroups count] != 0) {
		for (id group in accountGroups) {
			[sourceListTreeController insertObject:[NSMutableDictionary dictionaryWithObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[group valueForKey:@"name"], @"name", @"account", @"category", [group valueForKey:@"priority"], @"priority", [NSNumber numberWithBool:YES], @"filterState", nil] forKey:@"contentDictionary"] atArrangedObjectIndexPath:[NSIndexPath indexPathWithIndexes:indexes length:2]];
			indexes[1] += 1;
		}
	}
	
	// Accounts section
	indexes[0] = ACCOUNTS_GROUP_INDEX_PATH;
	indexes[1] = 0;
	[sourceListTreeController insertObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
											[NSNumber numberWithBool:YES], @"isSourceGroup",
											[NSDictionary dictionaryWithObject:@"ACCOUNTS" forKey:@"name"], @"contentDictionary", nil]
				 atArrangedObjectIndexPath:[NSIndexPath indexPathWithIndex:indexes[0]]];
	
	[sourceListTreeController insertObject:[NSMutableDictionary dictionaryWithObject:[NSDictionary dictionaryWithObjectsAndKeys:@"All accounts", @"name", @"account", @"category", [NSNumber numberWithInt:-1], @"priority", nil] forKey:@"contentDictionary"] atArrangedObjectIndexPath:[NSIndexPath indexPathWithIndexes:indexes length:2]];
	
	NSArray *accounts = [accountsArrayController arrangedObjects];
	for (NSManagedObject *account in accounts) {
		*(indexes+1) += 1;
		[sourceListTreeController insertObject:[NSMutableDictionary dictionaryWithObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[account valueForKey:@"name"], @"name", @"account", @"category", [account valueForKey:@"priority"], @"priority", [account valueForKey:@"filterState"], @"filterState", nil] forKey:@"contentDictionary"] atArrangedObjectIndexPath:[NSIndexPath indexPathWithIndexes:indexes length:2]];
	}
	
	// Posts section
	indexes[0] = POSTS_GROUP_INDEX_PATH;
	indexes[1] = 0;
	[sourceListTreeController insertObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
											[NSNumber numberWithBool:YES], @"isSourceGroup",
											[NSDictionary dictionaryWithObject:@"POSTS" forKey:@"name"],
											 @"contentDictionary", nil]
				 atArrangedObjectIndexPath:[NSIndexPath indexPathWithIndex:indexes[0]]];
	
	[sourceListTreeController insertObject:[NSMutableDictionary dictionaryWithObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"All posts", @"name", @"account", @"category", [NSNumber numberWithInt:-1], @"priority", nil] forKey:@"contentDictionary"] atArrangedObjectIndexPath:[NSIndexPath indexPathWithIndexes:indexes length:2]];
	
	NSArray *posts = [postsArrayController arrangedObjects];
	for (NSManagedObject *post in posts) {
		indexes[1] += 1;
		[sourceListTreeController insertObject:[NSMutableDictionary dictionaryWithObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[post valueForKey:@"name"], @"name", @"post", @"category", [post valueForKey:@"priority"], @"priority", [post valueForKey:@"filterState"], @"filterState", nil] forKey:@"contentDictionary"] atArrangedObjectIndexPath:[NSIndexPath indexPathWithIndexes:indexes length:2]];

		NSArray *typesArray = [[[post valueForKey:@"types"] allObjects] sortedArrayUsingDescriptors:[SortDescriptorsController prioritySortDescriptors]];
		NSEnumerator *types = [typesArray objectEnumerator];
		NSManagedObject *type;
		unsigned int indexesTypes[] = {indexes[0], indexes[1], 0};
		while (type = [types nextObject]) {
			[sourceListTreeController insertObject:[NSMutableDictionary dictionaryWithObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[type valueForKey:@"name"], @"name", @"type", @"category", [type valueForKey:@"priority"], @"priority", [type valueForKey:@"filterState"], @"filterState", [post valueForKey:@"priority"], @"postPriority", nil] forKey:@"contentDictionary"] atArrangedObjectIndexPath:[NSIndexPath indexPathWithIndexes:indexesTypes length:3]];
			indexesTypes[2] += 1;
		}
	}
	
	// Persons section
	indexes[0] = PERSONS_GROUP_INDEX_PATH;
	indexes[1] = 0;
	[sourceListTreeController insertObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
											[NSNumber numberWithBool:YES], @"isSourceGroup",
											[NSDictionary dictionaryWithObject:@"PERSONS" forKey:@"name"],
											@"contentDictionary", nil]
				 atArrangedObjectIndexPath:[NSIndexPath indexPathWithIndex:indexes[0]]];
	
	[sourceListTreeController insertObject:[NSMutableDictionary dictionaryWithObject:[NSDictionary dictionaryWithObjectsAndKeys:@"All persons", @"name", @"person", @"category", [NSNumber numberWithInt:-1], @"priority", nil] forKey:@"contentDictionary"] atArrangedObjectIndexPath:[NSIndexPath indexPathWithIndexes:indexes length:2]];
	
	NSArray *persons = [personsArrayController arrangedObjects];
	for (NSManagedObject *person in persons) {
		*(indexes+1) += 1;
		[sourceListTreeController insertObject:[NSMutableDictionary dictionaryWithObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[person valueForKey:@"name"], @"name", @"person", @"category", [person valueForKey:@"priority"], @"priority", [NSNumber numberWithBool:[filterController activeFilterContainsObject:person]], @"filterState", nil] forKey:@"contentDictionary"] atArrangedObjectIndexPath:[NSIndexPath indexPathWithIndexes:indexes length:2]];
	}
	
	[self expandAccountsSourceItem];
#ifdef EDITION_SELECTION_SOURCE_LIST_CONTROLLER_TRACE_METHODS_END
	printf("OUT [EditionSelectionSourceListController fillSourceListView]\n");
#endif
}

- (void)expandAccountsSourceItem {
	[sourceListView expandItem:[sourceListView itemAtRow:0]];
}


#pragma mark -
#pragma mark === Respond to user clicks ===

- (void)mouseClickedImageAreaOfItem:(id)item {
#ifdef EDITION_SELECTION_SOURCE_LIST_CONTROLLER_TRACE_METHODS
	printf("IN  [EditionSelectionSourceListController mouseClickedImageAreaOfItem:]\n");
#endif
	
	NSManagedObject *object = [self representedObjectForItem:item];
	
	if ([[item indexPath] length] > 1 && [[item indexPath] indexAtPosition:0] == PERSONS_GROUP_INDEX_PATH) {
		// Clicked item is not one of the category selection row. A person item has been clicked.
		[filterController inverseObjectStateInActiveFilter:object];
	}
	else {
		int filterState = [[object valueForKey:@"filterState"] intValue];
		if (filterState == NSOffState) {
			/* TODO: this should not be done here, but by the FilterController.
			 * This would allow to have a specific function to prevent recalculation
			 * by the filter controller when not needed (especially for the other mouseClicked...
			 * method.
			 */
			[object setValue:[NSNumber numberWithInt:NSOnState] forKey:@"filterState"];
		}
		else if (filterState == NSOnState) {
			[object setValue:[NSNumber numberWithInt:NSOffState] forKey:@"filterState"];
		}
		else if (filterState == NSMixedState) {
			[object setValue:[NSNumber numberWithInt:NSOnState] forKey:@"filterState"];
		}
	}
	
#ifdef EDITION_SELECTION_SOURCE_LIST_CONTROLLER_TRACE_METHODS_END
	printf("OUT [EditionSelectionSourceListController mouseClickedImageAreaOfItem:]\n");
#endif
}

- (void)mouseClickedTitleAreaOfItem:(id)item {
#ifdef EDITION_SELECTION_SOURCE_LIST_CONTROLLER_TRACE_METHODS
	printf("IN  [EditionSelectionSourceListController mouseClickedTitleAreaOfItem:]\n");
#endif

	NSIndexPath *itemIndexPath = [item indexPath];
	if ([itemIndexPath length] > 1 && [itemIndexPath indexAtPosition:0] == PERSONS_GROUP_INDEX_PATH) {
		if ([itemIndexPath indexAtPosition:1] > 0) {
			// A person item has been clicked.
			NSManagedObject *object = [self representedObjectForItem:item];
			[filterController includeFromSameTypeOnly:object];
		}
		else {
			// The "All persons" item has been clicked.
			[filterController includeAllObjectForEntityName:EntityNamePerson];
		}
	}
	else {
		
		NSManagedObject *objectIn;
		NSArray *allObjects;
		
		if ([[item indexPath] length] > 1) {
			// Clicked item is not one of the category selection row
			if ([[item indexPath] indexAtPosition:1] == 0) {
				// Category's "All..." row
				if ([[item indexPath] indexAtPosition:0] == ACCOUNTS_GROUP_INDEX_PATH) {
					// "All accounts" row
					allObjects = [accountsArrayController arrangedObjects];
				}
				else if ([[item indexPath] indexAtPosition:0] == POSTS_GROUP_INDEX_PATH) {
					// "All posts" row
					allObjects = [postsArrayController arrangedObjects];
				}
				objectIn = nil;
			}
			else {
				objectIn = [self representedObjectForItem:item];
				allObjects = [self allObjectsOfCategoryOfRepresentedObjectForItem:item];
			}
			
			if (objectIn != nil) {
				int filterState = [[objectIn valueForKey:@"filterState"] intValue];
				[objectIn setValue:[NSNumber numberWithInt:1] forKey:@"filterState"];
			}
			
	#ifdef EDITION_SELECTION_SOURCE_LIST_CONTROLLER_TRACE_NOTIFICATIONS
			printf("=== EditionSelectionSourceListController posting notification:%s\n", [NotificationNameStopFilteringOperations cStringUsingEncoding:NSUTF8StringEncoding]);
	#endif
			[[NSNotificationCenter defaultCenter] postNotificationName:NotificationNameStopFilteringOperations object:self];

			for (id objectOut in allObjects) {
				if (objectIn == nil || objectOut != objectIn) {
					if (objectIn != nil) {
						// objectIn is set implies all other objects are out.
						[objectOut setValue:[NSNumber numberWithInt:NSOffState] forKey:@"filterState"];
					}
					else {
						// No object set: all object are in.
						[objectOut setValue:[NSNumber numberWithInt:NSOnState] forKey:@"filterState"];
					}
				}
			}

	#ifdef EDITION_SELECTION_SOURCE_LIST_CONTROLLER_TRACE_NOTIFICATIONS
			printf("=== EditionSelectionSourceListController posting notification:%s\n", [NotificationNameStartFilteringOperations cStringUsingEncoding:NSUTF8StringEncoding]);
	#endif
			[[NSNotificationCenter defaultCenter] postNotificationName:NotificationNameStartFilteringOperations object:self];
		}
	}
	
#ifdef EDITION_SELECTION_SOURCE_LIST_CONTROLLER_TRACE_METHODS_END
	printf("OUT [EditionSelectionSourceListController mouseClickedTitleAreaOfItem:]\n");
#endif
}


#pragma mark -
#pragma mark === PrivateMethods ===

- (NSManagedObject *)representedObjectForItem:(id)item {
#ifdef EDITION_SELECTION_SOURCE_LIST_CONTROLLER_TRACE_METHODS
	printf("IN  [EditionSelectionSourceListController representedObjectForItem:]\n");
#endif
	
	NSIndexPath *itemIndexPath = [item indexPath];
	int itemLevel = [itemIndexPath length] - 1;
	
	NSManagedObject *returnObject;
	if (itemLevel == 2) {
		// Item is a type
		int itemPostIndex = [itemIndexPath indexAtPosition:1] - 1;
		int itemIndex = [itemIndexPath indexAtPosition:2];
		NSManagedObject *post = [[postsArrayController arrangedObjects] objectAtIndex:itemPostIndex];
		NSManagedObject *type = [[[[post valueForKey:@"types"] allObjects] sortedArrayUsingDescriptors:[SortDescriptorsController prioritySortDescriptors]] objectAtIndex:itemIndex];
		returnObject = type;
	}
	else {
		int itemIndex = [itemIndexPath indexAtPosition:1] - 1;
		if ([itemIndexPath indexAtPosition:0] == ACCOUNTS_GROUP_INDEX_PATH) {
			// Item is an account
			NSManagedObject *account = [[accountsArrayController arrangedObjects] objectAtIndex:itemIndex];
			returnObject = account;
		}
		else if ([itemIndexPath indexAtPosition:0] == POSTS_GROUP_INDEX_PATH) {
			// Item is a post
			NSManagedObject *post = [[postsArrayController arrangedObjects] objectAtIndex:itemIndex];
			returnObject = post;
		}
		else if ([itemIndexPath indexAtPosition:0] == PERSONS_GROUP_INDEX_PATH) {
			// Item is a person
			NSManagedObject *person = [[personsArrayController arrangedObjects] objectAtIndex:itemIndex];
			returnObject = person;
		}
	}
	
#ifdef EDITION_SELECTION_SOURCE_LIST_CONTROLLER_TRACE_METHODS
	printf("OUT [EditionSelectionSourceListController representedObjectForItem:]\n");
#endif
	return returnObject;
}

/*
 * Returns an array containing the all managed objects of the same category as the
 * managed object represented by item.
 */
- (NSArray *)allObjectsOfCategoryOfRepresentedObjectForItem:(id)item {
	NSIndexPath *itemIndexPath = [item indexPath];
	int itemLevel = [itemIndexPath length] - 1;
	
	NSArray *returnArray;
	if (itemLevel == 2) {
		// Item is a type
		// TODO: Desactive tous les postes, mais pas les autres types du même poste. Désactive tous les postes dont celui du type.
		returnArray = [typesArrayController arrangedObjects];
	}
	else {
		int itemIndex = [itemIndexPath indexAtPosition:1] - 1;
		if ([itemIndexPath indexAtPosition:0] == ACCOUNTS_GROUP_INDEX_PATH) {
			// Item is an account
			returnArray = [accountsArrayController arrangedObjects];
		}
		else if ([itemIndexPath indexAtPosition:0] == POSTS_GROUP_INDEX_PATH) {
			// Item is a post
			returnArray = [postsArrayController arrangedObjects];
		}
		else if ([itemIndexPath indexAtPosition:0] == PERSONS_GROUP_INDEX_PATH) {
			// Item is a person
			returnArray = [personsArrayController arrangedObjects];
		}
	}
	return returnArray;	
}

// TODO: construire les objects à màj à OFF ou ON, et non pas tous les objets du même type. pour la sélection d'un
// seule type, construire tous les autres types du même poste et tous les autres postes
@end
