@class MyDocument;

@protocol NibWindowController

// Life cycle
- (id)initWithDocument:(MyDocument*)aDocument;

// Managed window
- (void)openWindow;
- (void)closeWindow;

@end
