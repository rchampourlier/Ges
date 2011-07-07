#import "NibOwner.h"

@class MyDocument;

@protocol NibViewController

// Life cycle
- (id)initWithDocument:(MyDocument*)aDocument;

// Accessors
- (NSView*)view;

@end