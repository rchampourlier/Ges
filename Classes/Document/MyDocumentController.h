//
//  MyDocumentController.h
//  Ges
//
//  Created by Romain Champourlier on 21/02/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DebugDefines.h"

#ifndef TRACE_ALL
//#define MY_DOCUMENT_CONTROLLER_TRACE_METHODS
#endif

@interface MyDocumentController : NSDocumentController {

}

- (NSURL *)destinationURLWithPath:(NSString *)destinationPath error:(NSError **)outError;

@end
