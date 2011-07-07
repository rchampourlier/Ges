//
//  SortDescriptorsController.h
//  Ges
//
//  Created by NeoJF on 23/10/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SortDescriptorsController : NSObject {
	NSArray *prioritySortDescriptors;
	NSArray *operationsSortDescriptors;
}

// Life cycle
- (id)init;

// Managing sort descriptors
+ (NSArray *)prioritySortDescriptors;
+ (NSArray *)operationsSortDescriptors;

@property (assign,getter=operationsSortDescriptors,setter=setOperationsSortDescriptors:) NSArray* operationsSortDescriptors;
@property (assign,getter=prioritySortDescriptors, setter=setPrioritySortDescriptors:) NSArray *prioritySortDescriptors;

@end
