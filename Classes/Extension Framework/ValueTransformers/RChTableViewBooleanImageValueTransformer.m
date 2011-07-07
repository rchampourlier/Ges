//
//  TableViewBooleanImage.m
//  Ges
//
//  Created by NeoJF on 26/10/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "RChTableViewBooleanImageValueTransformer.h"


@implementation RChTableViewBooleanImageValueTransformer

/**
 * Inits the value transformer.
 *
 * The initialization loads the picture that will be returned as transformed
 * values. These pictures are 'selectedImage' and 'unselectedImage'.
 */
- (id)init {
	self = [super init];
	if (self != nil) {
		selectedImage = [[NSImage alloc] initByReferencingFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Selected_10x10.png"]];
		unselectedImage = [[NSImage alloc] initByReferencingFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Barred_10x10.png"]];
	}
	return self;
}

/**
 * Returns the transformed value.
 *
 * The transformed value is an image which depends on the availability of the
 * mode for the selected account. If available, the image is 'selectedImage'.
 * If unavailable, the image is 'unselectedImage'. If the selection contains
 * none or several accounts, 'nil' is returned.
 */
- (id)transformedValue:(id)value {
	if ([value boolValue] == YES) {
		return selectedImage;
	}
	else {
		return unselectedImage;
	}
}

+ (BOOL)allowsReverseTransformation {
	return NO;
}

+ (Class)transformedValueClass {
	return [NSImage class];
}

@synthesize selectedImage;
@synthesize unselectedImage;
@end
