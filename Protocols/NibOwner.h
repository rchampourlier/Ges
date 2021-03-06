/**
 * This protocol is intended for classes being set owner of nib files,
 * and which, for this reason, maintains array controllers of the different
 * kinds of entities managed by the application.
 *
 * The methods declared in this protocol enables to retrieve all array controllers
 * managed by the nib owner.
 *
 * These methods may be used when another nib owner made changes on entities which
 * requires all array controllers to be rearranged.
 */

@protocol NibOwner

- (NSArray*)accountsArrayControllers;
- (NSArray*)modesArrayControllers;
- (NSArray*)operationsArrayControllers;
- (NSArray *)postsArrayControllers;
- (NSArray*)typesArrayControllers;

@end