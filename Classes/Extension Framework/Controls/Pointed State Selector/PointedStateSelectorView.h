//
//  PointedStateSelectorView.h
//  Ges
//
//  Created by NeoJF on 28/07/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ModelConstants.h"

typedef enum {UNSET = POINTED_STATE_UNSET, DISABLED = POINTED_STATE_DISABLED, ENABLED = POINTED_STATE_ENABLED} State;

@interface PointedStateSelectorView : NSControl {
	NSImage* unsetImage;
	NSImage* enabledImage;
	NSImage* disabledImage;
	NSImage* unsetDisabledImage;
	NSImage* enabledDisabledImage;
	NSImage* disabledDisabledImage;
	
	NSTrackingRectTag	unsetTrackingRectTag;
	NSTrackingRectTag	enabledTrackingRectTag;
	NSTrackingRectTag	disabledTrackingRectTag;
	
	NSBezierPath* selectionBezierPath;
	
	State selectedState;
	State rolloverState;
	
	BOOL enabled;
	BOOL allowingMultipleSelection;
	
	id bindingController;
	NSString *bindingKeyPath;
}

// Object's life
- (void)awakeFromNib;

// Handling events
- (void)mouseEntered:(NSEvent *)theEvent;
- (void)mouseDown:(NSEvent *)event;
- (BOOL)acceptsFirstResponder;
- (void)resetCursorRects;

// KVC
- (State)getSelectedState;
- (void)setSelectedState:(State)state;
- (BOOL)isEnabled;
- (void)setEnabled:(BOOL)enable;

// Binding
- (void)bind:(NSString *)bindingName toObject:(id)observableController withKeyPath:(NSString *)keyPath options:(NSDictionary *)options;
- (void)unbind:(NSString *)bindingName;
- (void)setBindingController:(id)controller;
- (void)setBindingKeyPath:(NSString *)keyPath;
- (Class)valueClassForBinding:(NSString *)binding;

// Parametrizing the view
- (void)setAllowingMultipleSelection:(BOOL)allowMultipleSelection;
- (BOOL)isAllowingMultipleSelection;
- (void)setTrackingRectangles;

// Class methods
+ (void)initialize;
+ (NSArray *)exposedBindings;

@property (retain) NSImage* unsetImage;
@property (retain) NSImage* disabledImage;
@property (retain) NSImage* unsetDisabledImage;
@property (retain) NSImage* enabledImage;
@property (retain) NSImage* disabledDisabledImage;
@property NSTrackingRectTag	disabledTrackingRectTag;
@property (retain) NSBezierPath* selectionBezierPath;
@property NSTrackingRectTag	enabledTrackingRectTag;
@property NSTrackingRectTag	unsetTrackingRectTag;
@property (retain) NSImage* enabledDisabledImage;
@end

NSBezierPath* constructSelectionBezierPath();
