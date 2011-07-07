//
//  PointedStateImageTransformer.h
//  Ges
//
//  Created by NeoJF on 27/07/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ModelConstants.h"


@interface PointedStateImageTransformer : NSValueTransformer {
	NSImage* unsetImage;
	NSImage* disabledImage;
	NSImage* enabledImage;
}

@property (retain) NSImage* unsetImage;
@property (retain) NSImage* enabledImage;
@property (retain) NSImage* disabledImage;
@end
