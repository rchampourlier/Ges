//
//  StatisticsCellData.m
//  Ges
//
//  Created by Romain Champourlier on 08/05/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "StatisticsCellData.h"


/**
 This class contains the data for cells displayed in the statistics table view.
 Current data is:
	- isParentCell:	YES if the cell has children,
	- isTitleCell:	YES if the cell is the title cell, which is the cell in the first column of the table,
	- title:		if title cell, the string title to be displayed,
	- value:		if not title cell, the number value to be displayed.
 */
 
@implementation StatisticsCellData

+ (void)initialize {
	[super initialize];
	//[self exposeBinding:@"includedInStatisticsTotal"];
}

- (id)copyWithZone:(NSZone *)zone {
	//printf("IN  [StatisticsCellData copyWithZone:]\n");
	
	id object;
	if (isTitleCell) {
		object = [[StatisticsCellData allocWithZone:zone] initWithTitle:title isParentCell:isParentCell correspondingManagedObject:[self correspondingObject]];
	}
	else {
		object = [[StatisticsCellData allocWithZone:zone] initWithValue:value isParentCell:isParentCell];
	}
	
	//printf("OUT [StatisticsCellData copyWithZone:]\n");
	return object;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
	//printf("IN  [StatisticsCellData mutableCopyWithZone:]\n");
	return [self copyWithZone:zone];
}


- (id)initWithValue:(NSNumber *)number isParentCell:(BOOL)boolean {
	self = [super init];
	if (self != nil) {
		value = [number retain];
		isParentCell = boolean;
		isTitleCell = NO;
	}
	return self;
}

/**
 Init the receiver with:
	- string:	Title of the cell represented by the receiver. Generally the name of the property
				to be displayed by the cell.
	- boolean:	YES if the cell is going to have children. NO if not.
	- correspondingManagedObject: the managed object displayed by the cell.
 */
- (id)initWithTitle:(NSString *)string isParentCell:(BOOL)boolean correspondingManagedObject:(NSManagedObject *)mo {
	self = [super init];
	if (self != nil) {
		title = [string retain];
		isParentCell = boolean;
		isTitleCell = YES;
		correspondingObjectURL = [[mo objectID] URIRepresentation];
	}
	return self;
}

- (void)dealloc {
	if (isTitleCell) {
		[title release];
	}
	else {
		[value release];
	}
	[super dealloc];
}

- (NSManagedObject *)correspondingObject {
	if (correspondingObjectURL != nil) {
		return [managedObjectContext objectWithID:[[managedObjectContext persistentStoreCoordinator] managedObjectIDForURIRepresentation:correspondingObjectURL]];
	}
	return nil;
}

+ (StatisticsCellData *)parentCellWithValue:(NSNumber *)value {
	return [[StatisticsCellData alloc] initWithValue:value isParentCell:YES];
}

+ (StatisticsCellData *)childCellWithValue:(NSNumber *)value {
	return [[StatisticsCellData alloc] initWithValue:value isParentCell:NO];
}

+ (StatisticsCellData *)parentCellWithTitle:(NSString *)title correspondingManagedObject:(NSManagedObject *)mo {
	return [[StatisticsCellData alloc] initWithTitle:title isParentCell:YES correspondingManagedObject:mo];
}

+ (StatisticsCellData *)childCellWithTitle:(NSString *)title correspondingManagedObject:(NSManagedObject *)mo {
	return [[StatisticsCellData alloc] initWithTitle:title isParentCell:NO correspondingManagedObject:mo];
}

+ (void)setManagedObjectContext:(NSManagedObjectContext *)moc {
	managedObjectContext = moc;
}

@synthesize isParentCell;
@synthesize isTitleCell;
@synthesize title;
@synthesize value;
@synthesize correspondingObjectURL;
@synthesize correspondingObject;

@end
