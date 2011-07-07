//
//  MarkedStateImageTransformer.m
//  Ges
//
//  Created by NeoJF on 28/09/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "MarkedStateImageTransformer.h"


@implementation MarkedStateImageTransformer

- (id)transformedValue:(id)value {
	switch([value intValue]) {
		case MARKED_STATE_DISABLED :
			return nil;
		case MARKED_STATE_ENABLED :
			return [NSImage imageNamed:@"Warning_10x10.png"];
	}
	return nil;
}

+ (BOOL)allowsReverseTransformation {
	return NO;
}

+ (Class)transformedValueClass {
	return [NSImage class];
}

@end
