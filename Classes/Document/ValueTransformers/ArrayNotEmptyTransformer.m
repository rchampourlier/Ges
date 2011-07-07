//
//  EmptySelectionTransformer.m
//  Ges
//
//  Created by NeoJF on 11/09/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "ArrayNotEmptyTransformer.h"


@implementation ArrayNotEmptyTransformer

- (id)transformedValue:(id)value {
	if ([value count] == 0) {
		return [NSNumber numberWithBool:NO];
	}
	else {
		return [NSNumber numberWithBool:YES];
	}
}

+ (BOOL)allowsReverseTransformation {
	return NO;
}

+ (Class)transformedValueClass {
	return [NSNumber class];
}

@end
