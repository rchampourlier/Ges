/**
 * @protocol ModelInstancesUser
 *
 * Classes maintaining/using instances of the model, such as object controllers
 * filled with object from the model should respect this protocol, in order to
 * allow the main controller (the MyDocument instance) to keep local instances
 * of the model up to date.
 */

@protocol ModelInstancesUser

- (void)rearrangeAccountsArrayControllers:(id)sender;
- (void)rearrangePersonsArrayControllers:(id)sender;
- (void)rearrangeModesArrayControllers:(id)sender;
- (void)rearrangePostsArrayControllers:(id)sender;
- (void)rearrangeTypesArrayControllers:(id)sender;


@end