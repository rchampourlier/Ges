//
//  AvailableForAccountTransformer.h
//  Ges
//
//  Created by NeoJF on 18/10/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MyDocument.h"
#import "DocumentPropertiesController.h"

@interface AvailableForAccountTransformer : NSObject {

	// Images
	NSImage* selectedImage;
	NSImage* unselectedImage;
}

@property (retain) NSImage* unselectedImage;
@property (retain) NSImage* selectedImage;
@end
