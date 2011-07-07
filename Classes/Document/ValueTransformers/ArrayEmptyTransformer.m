//
//  ArrayEmptyTransformer.m
//  Ges
//
//  Created by NeoJF on 22/12/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "ArrayEmptyTransformer.h"


@implementation ArrayEmptyTransformer

- (id)transformedValue:(id)value {
	if ([value count] == 0) {
		return [NSNumber numberWithBool:YES];
	}
	else {
		return [NSNumber numberWithBool:NO];
	}
}

+ (BOOL)allowsReverseTransformation {
	return NO;
}

+ (Class)transformedValueClass {
	return [NSNumber class];
}

@end
