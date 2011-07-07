//
//  DocumentToolbar.h
//  Ges
//
//  Created by NeoJF on 29/09/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

static NSString* ToolbarDidToggleNotificationName = @"ToolbarDidToggleNotification";
static NSString* ToolbarDidToggleNotificationShownKey = @"ToolbarDidToggleShown";

@interface DocumentToolbar : NSToolbar {
}

@end
