//
//  DocumentToolbar.m
//  Ges
//
//  Created by NeoJF on 29/09/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "DocumentToolbar.h"


@implementation DocumentToolbar

- (void)setVisible:(BOOL)shown {
	[super setVisible:shown];
	NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithCapacity:1];
	[userInfo setObject:[NSNumber numberWithBool:shown] forKey:ToolbarDidToggleNotificationShownKey];

	printf("=== DocumentToolbar posting notification:%s\n", [ToolbarDidToggleNotificationName cStringUsingEncoding:NSUTF8StringEncoding]);
	[[NSNotificationCenter defaultCenter] postNotificationName:ToolbarDidToggleNotificationName object:self userInfo:userInfo];
}

@end
