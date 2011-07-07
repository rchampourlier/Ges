//
//  PropertiesPostsTypesOutlineViewDragAndDropController.m
//  Ges
//
//  Created by NeoJF on 12/11/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PropertiesPostsTypesOutlineViewDragAndDropController.h"


@implementation PropertiesPostsTypesOutlineViewDragAndDropController


/**
 * Called when the instance has been loaded from the nib file.
 * Sets the sort descriptors for the types and posts tree controller.
 */
/*- (void)awakeFromNib {
	NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"priority" ascending:YES];
	NSArray* sortDescriptorsArray = [NSArray arrayWithObject:sortDescriptor];
	[postsTypesTreeController setSortDescriptors:sortDescriptorsArray];	
}*/

/*
 * Methods for the NSOutlineView's datasource protocol are implemented in order
 * the registered datasource to be accepted and thus drag'n'drop functions
 * supported.
 * They do not provide results since the content filling is assumed by the
 * Cocoa bindings.
 */
#pragma mark -
#pragma mark === Datasource ===

- (int)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
	return 0;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
	return NO;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item {
	return nil;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
	return nil;
}


#pragma mark -
#pragma mark === Drag'n'drop management ===

/**
 * Responds to the end of a drag'n'drop operation. 'item' is the parent of the element
 * over which the mouse was released.
 */
- (BOOL)outlineView:(NSOutlineView *)outlineView acceptDrop:(id <NSDraggingInfo>)info item:(id)item childIndex:(int)index {
#ifdef PROPERTIES_POSTS_TYPES_OUTLINE_VIEW_DRAG_AND_DROP_CONTROLLER_TRACE
	printf("IN  [PropertiesPostsTypesOutlineViewDragAndDropController outlineView:acceptDrop:item:childIndex]\n");
#endif
	
	NSManagedObjectContext *managedObjectContext = [documentPropertiesController managedObjectContext];
	//NSString *draggingPasteboardType = [[[info draggingPasteboard] types] objectAtIndex:0];
	NSPasteboard *pboard = [info draggingPasteboard];
	NSString *draggingPasteboardType = [pboard availableTypeFromArray:[NSArray arrayWithObjects:postsOutlineViewRowType, typesOutlineViewRowType, nil]];
	
	int destPriority;
	NSManagedObject *destinationObject = [NSTreeController objectForOutlineItem:item];
	if (destinationObject != nil) {
		destPriority = [[destinationObject valueForKey:@"priority"] intValue];
	}
	else {
		destPriority = index;
	}
	
	if ([draggingPasteboardType isEqualToString:postsOutlineViewRowType]) {
		// A post has been dragged
		
		NSData *rowData = [pboard dataForType:postsOutlineViewRowType];
	    int draggedPostPriority = [[NSKeyedUnarchiver unarchiveObjectWithData:rowData] intValue];
		
		// Fetching the dragged post
		NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
		[request setEntity:[NSEntityDescription entityForName:EntityNamePost inManagedObjectContext:managedObjectContext]];
		[request setSortDescriptors:[postsTypesTreeController sortDescriptors]];
		[request setPredicate:[NSPredicate predicateWithFormat:@"priority == %d", draggedPostPriority]];
		NSManagedObject *draggedPost = [[managedObjectContext executeFetchRequest:request error:NULL] objectAtIndex:0];
		//printf("draggedPost: %s\n", [[draggedPost valueForKey:@"name"] cString]);
		
		int sourcePriority = [[draggedPost valueForKey:@"priority"] intValue];
				
		if (destPriority > sourcePriority) {
			destPriority--;
		}
		[draggedPost setValue:[NSNumber numberWithInt:destPriority] forKey:@"priority"];
		[postsTypesTreeController rearrangeObjects];
	}
	
	else {
		// A type has been dragged
		
		NSData *rowData = [pboard dataForType:typesOutlineViewRowType];
		NSArray *draggedTypeIdentifiersArray = [NSKeyedUnarchiver unarchiveObjectWithData:rowData];
		int draggedTypePostPriorityInt = [[draggedTypeIdentifiersArray objectAtIndex:0] intValue];
		NSNumber *draggedTypePostPriority = [draggedTypeIdentifiersArray objectAtIndex:0];
		int draggedTypePriority = [[draggedTypeIdentifiersArray objectAtIndex:1] intValue];
		int destPriority = index;
		
		// Fetching the dragged type's post
		NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
		[request setEntity:[NSEntityDescription entityForName:EntityNamePost inManagedObjectContext:managedObjectContext]];
		[request setPredicate:[NSPredicate predicateWithFormat:@"priority == %@", draggedTypePostPriority]];
		[request setSortDescriptors:[postsTypesTreeController sortDescriptors]];
		NSArray* posts = [managedObjectContext executeFetchRequest:request error:NULL];
		NSManagedObject *draggedTypePost = [posts objectAtIndex:0];
		
		// Fetching the dragged type
		[request setEntity:[NSEntityDescription entityForName:EntityNameType inManagedObjectContext:managedObjectContext]];
		[request setPredicate:[NSPredicate predicateWithFormat:@"post == %@ AND priority == %@", draggedTypePost, [NSNumber numberWithInt:draggedTypePriority]]];
		NSManagedObject *draggedType = [[[documentPropertiesController managedObjectContext] executeFetchRequest:request error:NULL] objectAtIndex:0];
		
		// Getting destination post
		NSManagedObject *destPost = [NSTreeController objectForOutlineItem:item];
		
		int sourcePriority = [[draggedType valueForKey:@"priority"] intValue];

		if (![destPost isEqualTo:draggedTypePost]) {
			// Type dragged to another post
			[draggedType setValue:destPost forKey:@"post"];
		}
		else if (destPriority > sourcePriority) {
				destPriority--;
		}
		[draggedType setValue:[NSNumber numberWithInt:destPriority] forKey:@"priority"];
		
		[[postsTypesTreeController nodeAtIndexPath:[NSIndexPath indexPathWithIndex:[[destPost valueForKey:@"priority"] intValue]]] sortWithSortDescriptors:[SortDescriptorsController prioritySortDescriptors] recursively:YES];
	}

	[managedObjectContext processPendingChanges];
	// TODO: try to use the same mechanism as for accounts and modes: use MyDocument instance
	// to update all array/tree controllers, and no more doing it when closing the document
	// properties window.
	
#ifdef PROPERTIES_POSTS_TYPES_OUTLINE_VIEW_DRAG_AND_DROP_CONTROLLER_TRACE
	printf("[PropertiesPostsTypesOutlineViewDragAndDropController outlineView:acceptDrop:item:childIndex] END\n");
#endif
	
	return YES;
}

- (NSDragOperation)outlineView:(NSOutlineView *)outlineView validateDrop:(id <NSDraggingInfo>)info proposedItem:(id)item proposedChildIndex:(int)index {
	
	NSPasteboard *draggingPasteboard = [info draggingPasteboard];
	/*NSArray *draggingPasteboardTypes = [draggingPasteboard types];
	NSString *draggedType = [draggingPasteboardTypes objectAtIndex:0];*/
	NSManagedObject* destinationObject = [NSTreeController objectForOutlineItem:item];
	
	NSString *draggedType = [draggingPasteboard availableTypeFromArray:[NSArray arrayWithObjects:typesOutlineViewRowType, postsOutlineViewRowType, nil]];
	
	//printf("draggedType=%s destinationObject=%s\n", [draggedType CSTRING], [[destinationObject valueForKey:@"name"] CSTRING]);
		
	if ([[[destinationObject entity] name] isEqualToString:EntityNameType] || index == -1 ||
		([draggedType isEqualToString:typesOutlineViewRowType] && item == nil) ||
		([draggedType isEqualToString:postsOutlineViewRowType] && [[[destinationObject entity] name] isEqualToString:EntityNamePost])) {
		
		/*
		 * Prevents:
		 *  - types from having children,
		 *	- types from being dropt to posts' level,
		 *	- posts from having post children.
		 */
		return NSDragOperationNone;
	}
	
	return NSDragOperationEvery;
}

/**
 * Called when a drag'n'drop operation is initiated. If the operation is allowed, 'YES' is
 * returned and the data for it is passed to the given pasteboard.
 */
- (BOOL)outlineView:(NSOutlineView *)outlineView writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pboard {
#ifdef PROPERTIES_POSTS_TYPES_OUTLINE_VIEW_DRAG_AND_DROP_CONTROLLER_TRACE
	printf("[PropertiesPostsTypesOutlineViewDragAndDropController outlineView:writeItems:toPasteboard:]\n");
#endif
	
	NSManagedObject* object = [[NSTreeController objectsForOutlineItems:items] objectAtIndex:0];
	printf("--- object=%s\n", [[object valueForKey:@"name"] CSTRING]);
	
	if ([[[object entity] name] isEqualToString:EntityNameType]) {
		printf("--- dragging a type\n");
		NSArray *dataArray = [NSArray arrayWithObjects:[object valueForKeyPath:@"post.priority"], [object valueForKey:@"priority"], nil];
		NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dataArray];
		[pboard declareTypes:[NSArray arrayWithObject:typesOutlineViewRowType] owner:self];
		[pboard setData:data forType:typesOutlineViewRowType];
	}
	else {
		printf("--- dragging a post\n");
		NSData *data = [NSKeyedArchiver archivedDataWithRootObject:[object valueForKey:@"priority"]];
		[pboard declareTypes:[NSArray arrayWithObject:postsOutlineViewRowType] owner:self];
		[pboard setData:data forType:postsOutlineViewRowType];
	}
	
	return YES;
}

@synthesize postsTypesOutlineView;
@synthesize documentPropertiesController;
@synthesize postsTypesTreeController;
@end

/**
 * pboard: the dragging pasteboard
 * sortDescriptors: an array containing sort descriptors of the posts' array controller
 */
void retrieveDraggedPost(NSManagedObjectContext *moc, NSPasteboard *pboard, NSArray *sortDescriptors) {
	NSData *rowData = [pboard dataForType:postsOutlineViewRowType];
	int draggedPostPriority = [[NSKeyedUnarchiver unarchiveObjectWithData:rowData] intValue];
	
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	[request setEntity:[NSEntityDescription entityForName:EntityNamePost inManagedObjectContext:moc]];
	[request setSortDescriptors:sortDescriptors];
}

void retrieveDraggedType() {
}

void moveType(NSManagedObjectContext *moc, int destTypePriority, NSManagedObject *sourceType, NSManagedObject *destPost) {
	int sourceTypePriority = [[sourceType valueForKey:@"priority"] intValue];
	NSManagedObject *sourcePost = [sourceType valueForKey:@"post"];
	int sourcePostPriority = [[sourcePost valueForKey:@"priority"] intValue];
	
	if ([destPost isEqualTo:sourcePost]) {
		// Moved within same post

		NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
		[request setEntity:[NSEntityDescription entityForName:EntityNameType inManagedObjectContext:moc]];

		if (destTypePriority > sourceTypePriority + 1) {
			// Type is going down
			
			[request setPredicate:[NSPredicate predicateWithFormat:@"post == %@ AND priority > %d AND priority < %d", sourcePost, sourceTypePriority, destTypePriority]];
			NSArray *types = [moc executeFetchRequest:request error:NULL];
			
			int i;
			for (i = 0; i < [types count]; i++) {
				printf("%s %d -> %d\n", [[[types objectAtIndex:i] valueForKey:@"name"] cString], [[[types objectAtIndex:i] valueForKey:@"priority"] intValue], sourceTypePriority + i);
				[[types objectAtIndex:i] setValue:[NSNumber numberWithInt:(sourceTypePriority + i)] forKey:@"priority"];
			}			
			[sourceType setValue:[NSNumber numberWithInt:(destTypePriority - 1)] forKey:@"priority"];
			printf("%s %d -> %d\n", [[sourceType valueForKey:@"name"] cString], sourceTypePriority, destTypePriority - 1);
		}
		
		else if (destTypePriority < sourceTypePriority) {
			// Type is going up
			
			[request setPredicate:[NSPredicate predicateWithFormat:@"post == %@ AND priority <= %d AND priority >= %d", sourcePost, sourceTypePriority, destTypePriority]];
			NSArray *types = [moc executeFetchRequest:request error:NULL];
			[sourceType setValue:[NSNumber numberWithInt:destTypePriority] forKey:@"priority"];
			printf("%s %d -> %d\n", [[sourceType valueForKey:@"name"] cString], sourceTypePriority, destTypePriority);
			
			int i;
			for (i = [types count] - 2; i >= 0 ; i--) {
				printf("%s %d -> %d\n", [[[types objectAtIndex:i] valueForKey:@"name"] cString], [[[types objectAtIndex:i] valueForKey:@"priority"] intValue], sourceTypePriority - i);
				[[types objectAtIndex:i] setValue:[NSNumber numberWithInt:(sourceTypePriority - i)] forKey:@"priority"];
			}				
		}
	}
	else {
		// Moved to another post
		
		NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
		[request setPredicate:[NSPredicate predicateWithFormat:@"priority >= %d AND priority < %d", sourceTypePriority, destTypePriority]];
		NSArray *types = [moc executeFetchRequest:request error:NULL];
		[sourceType setValue:[NSNumber numberWithInt:(destTypePriority - 1)] forKey:@"priority"];
		
		int i;
		for (i = 1; i < [types count]; i++) {
			[[types objectAtIndex:i] setValue:[NSNumber numberWithInt:(sourceTypePriority + i - 1)] forKey:@"priority"];
		}	
	}	
}
	
