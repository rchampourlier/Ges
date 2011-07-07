/**
 * @protocol FilterObserver
 *
 * Classes conforming to FilterObserver declares methods that are to be called
 * by the FilterController when the filter is modified.
 */

@protocol FilterObserver

- (void)filterDidLoad;
- (void)filterInclude:(NSManagedObject *)object;
- (void)filterExclude:(NSManagedObject *)object;

@end