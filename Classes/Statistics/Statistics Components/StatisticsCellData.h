//
//  StatisticsCellData.h
//  Ges
//
//  Created by Romain Champourlier on 08/05/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// TODO: should complement correspondingManagedObjectPriority with a correspondingManagedObjectType, and maybe a reference to the corresponding managed object itself

static NSManagedObjectContext *managedObjectContext;

@interface StatisticsCellData : NSObject <NSCopying, NSMutableCopying> {
	BOOL								isParentCell;
	BOOL								isTitleCell;
	NSString							*title;
	NSNumber							*value;
	NSURL								*correspondingObjectURL;
	NSManagedObject						*correspondingObject;
}

- (id)initWithValue:(NSNumber *)number isParentCell:(BOOL)boolean;
- (id)initWithTitle:(NSString *)string isParentCell:(BOOL)boolean correspondingManagedObject:(NSManagedObject *)mo;
- (void)dealloc;

+ (StatisticsCellData *)parentCellWithValue:(NSNumber *)value;
+ (StatisticsCellData *)childCellWithValue:(NSNumber *)value;
+ (StatisticsCellData *)parentCellWithTitle:(NSString *)title correspondingManagedObject:(NSManagedObject *)mo;
+ (StatisticsCellData *)childCellWithTitle:(NSString *)title correspondingManagedObject:(NSManagedObject *)mo;
+ (void)setManagedObjectContext:(NSManagedObjectContext *)moc;

@property (assign, getter=isParentCell)					BOOL		isParentCell;
@property (assign, getter=isTitleCell)					BOOL		isTitleCell;
@property (assign, getter=title, setter=setTitle:)		NSString	*title;
@property (copy, getter=value, setter=setValue:)		NSNumber	*value;
@property (assign)										NSURL		*correspondingObjectURL;
@property (readonly, getter=correspondingObject)	NSManagedObject	*correspondingObject;

@end
