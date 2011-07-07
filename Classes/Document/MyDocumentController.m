//
//  MyDocumentController.m
//  Ges
//
//  Created by Romain Champourlier on 21/02/08.
//  Copyright 2008 SoftRoch. All rights reserved.
//

#import "MyDocumentController.h"

/**
 * To implement the migration process using the CoreData mapping model mechanism, add an instance of this
 * class to the MainMenu interface file.
 */

@implementation MyDocumentController

- (id)openDocumentWithContentsOfURL:(NSURL *)absoluteURL display:(BOOL)displayDocument error:(NSError **)outError {

#ifdef MY_DOCUMENT_CONTROLLER_TRACE_METHODS
	printf("IN  [MyDocumentController openDocumentWithContentsOfURL:%s display:%s error:]\n", [[absoluteURL absoluteString] CSTRING], displayDocument ? "YES" : "NO");
#endif
	
	NSURL *destinationURL = absoluteURL;
	NSString *sourceType = [self typeForContentsOfURL:absoluteURL error:outError];	
	
	//if (![sourceType isEqualToString:CURRENT_VERSION_TYPE]) {
	/*
	 Find what store types are required for the source and destination.
	 
	 This jumps through some hoops to avoid hard-coding the source and destination types and makes this code more re-use friendly.  Unfortunately there is no API for NSDocumentController to determine what persistent store type is associated with a given document type, so we create a temporary document instance and ask it. (We could grub through the main bundle's infoDictionary to get the NSPersistentStoreTypeKey value for the relevant document types etc., but that's a fair amount of work, whereas this is simple and straightforward.)
	 
	 **If you happen to use a different document class for the two document types, you'll have to create instances of the source and destination types and ask each individually for their persistentStoreTypeForFileType.**
	 
	 Alternatively, just set the strings directly, but remember to update them if store types change.
	 
			 */
	/*id documentExemplar = [self makeUntitledDocumentOfType:CURRENT_VERSION_TYPE error:outError];
	if (documentExemplar == nil)
	{
		return nil;
	}
	NSString *sourceStoreType = [documentExemplar persistentStoreTypeForFileType:sourceType];
	NSString *destinationStoreType = [documentExemplar persistentStoreTypeForFileType:CURRENT_VERSION_TYPE];
	*/
	NSString *sourceStoreType = NSSQLiteStoreType;
	NSString *destinationStoreType = NSSQLiteStoreType;
	
	/* To perform the migration, we need a migration manager.
	   To create the migration manager, we need the source and destination models.  The destination model is the document's -managedObjectModel.  We still need to find the correct source model -- for that we need the metadata for the store we're opening.
	 */
	
	NSDictionary *sourceMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:sourceStoreType URL:absoluteURL error:outError];
	
	if (sourceMetadata == nil) {
		NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSMigrationManagerSourceStoreError userInfo:nil];
		*outError = error;

		sourceStoreType = NSXMLStoreType;
		destinationStoreType = NSXMLStoreType;
		sourceMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:sourceStoreType URL:absoluteURL error:outError];

		if (sourceMetadata == nil) {
#ifdef MY_DOCUMENT_CONTROLLER_TRACE_METHODS
			printf("OUT [MyDocumentController openDocumentWithContentsOfURL:display:error:] <sourceMetadata=nil>\n");
#endif
			return nil;
		}
	} // returns
	
	/*printf("sourceMetadata: ");
	for (id key in [sourceMetadata allKeys]) {
		printf("%s, ", [key CSTRING]);
	}
	printf("\n");*/
		
	NSManagedObjectModel *sourceModel = [NSManagedObjectModel mergedModelFromBundles:nil forStoreMetadata:sourceMetadata];
	if (sourceModel == nil) {
		NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSMigrationMissingSourceModelError userInfo:nil];
		*outError = error;
		
#ifdef MY_DOCUMENT_CONTROLLER_TRACE_METHODS
		printf("OUT [MyDocumentController openDocumentWithContentsOfURL:%s display:%s error:]\n");
#endif
		return nil;
	} // returns
	/*printf("sourceModel's versionIdentifiers: ");
	for (id versionIdentifier in [[sourceModel versionIdentifiers] allObjects]) {
		printf("%s, ", [versionIdentifier CSTRING]);
	}
	printf("\n");*/
	
	/*
	 * To perform the migration, we also need a mapping model. 
	 * We have the source and destination model; NSMapping model provides a convenience method to find the correct
	 * mapping model from a given array of bundles.
	 */
	NSManagedObjectModel *destinationModel = [NSManagedObjectModel mergedModelFromBundles:nil];
	/*printf("destinationModel's versionIdentifiers: ");
	for (id versionIdentifier in [[destinationModel versionIdentifiers] allObjects]) {
		printf("%s, ", [versionIdentifier CSTRING]);
	}
	printf("\n");*/
	
	if ([[[sourceModel versionIdentifiers] anyObject] isEqualToString:[[destinationModel versionIdentifiers] anyObject]]) {
		/* Source and destination models have the same versionIdentifier, we can thus estimate
		 * input file is in the current model version. There is thus no need to migrate it.
		 */
		
#ifdef MY_DOCUMENT_CONTROLLER_TRACE_METHODS
		printf("OUT [MyDocumentController openDocumentWithContentsOfURL:display:error:] <no migration needed>\n");
#endif
		return [super openDocumentWithContentsOfURL:destinationURL display:displayDocument error:outError];
	} // returns document without migration (document already in current version)
	
	NSArray *bundles = [NSArray arrayWithObject:[NSBundle mainBundle]];
	NSMappingModel *mappingModel = [NSMappingModel mappingModelFromBundles:bundles forSourceModel:sourceModel destinationModel:destinationModel];
	if (mappingModel == nil) {
		NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSMigrationMissingMappingModelError userInfo:nil];
		*outError = error;
		
#ifdef MY_DOCUMENT_CONTROLLER_TRACE_METHODS
		printf("OUT [MyDocumentController openDocumentWithContentsOfURL:display:error:] <no mapping model>\n");
#endif
		return nil;
	}
	
	/*
	 Create the path and URL for the new file using the new file extension
	 */
	
	//NSString *currentVersionExtension = [[self fileExtensionsFromType:CURRENT_VERSION_TYPE] objectAtIndex:0];

	NSString *currentVersionExtension = @"ges";

	NSString *destinationPath = [absoluteURL path];
	destinationPath = [destinationPath stringByDeletingPathExtension];
	destinationPath = [NSString stringWithFormat:@"%@ - 2", destinationPath];
	destinationPath = [destinationPath stringByAppendingPathExtension:currentVersionExtension];
	
	destinationURL = [self destinationURLWithPath:destinationPath error:outError];
	if (destinationURL == nil) {
		
#ifdef MY_DOCUMENT_CONTROLLER_TRACE_METHODS
		printf("OUT [MyDocumentController openDocumentWithContentsOfURL:display:error:] <destinationURL=nil>\n");
#endif
		return nil;
	}
	
	/*
	 Create the migration manager and perform the migration
	 */
	NSMigrationManager *migrationManager = [[NSMigrationManager alloc] initWithSourceModel:sourceModel destinationModel:destinationModel];
	
	BOOL ok = NO;
	ok = [migrationManager migrateStoreFromURL:absoluteURL type:sourceStoreType options:nil withMappingModel:mappingModel toDestinationURL:destinationURL destinationType:destinationStoreType destinationOptions:nil error:outError];
	
	if (!ok) {
#ifdef MY_DOCUMENT_CONTROLLER_TRACE_METHODS
		printf("OUT [MyDocumentController openDocumentWithContentsOfURL:display:error:] <migration error>\n");
#endif
		return nil;
	}
	
#ifdef MY_DOCUMENT_CONTROLLER_TRACE_METHODS
	printf("OUT [MyDocumentController openDocumentWithContentsOfURL:display:error:] <seems ok>\n");
#endif
	return [super openDocumentWithContentsOfURL:destinationURL display:displayDocument error:outError];
}

- (NSURL *)destinationURLWithPath:(NSString *)destinationPath error:(NSError **)outError {
	
#ifdef MY_DOCUMENT_CONTROLLER_TRACE_METHODS
	printf("IN  [MyDocumentController destinationURLWithPath:%s error:]\n", [destinationPath CSTRING]);
#endif
	
	NSURL *destinationURL = nil;
	BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:destinationPath];
	
	if (exists) {
		NSAlert *alert = [[NSAlert alloc] init];
		
		NSString *messageText = NSLocalizedString(@"Overwrite existing file?", @"Message: Performing migration, Overwrite existing file");
		[alert setMessageText:messageText];
		
		NSString *informativeText = NSLocalizedString(@"The file you opened was made using a previous version of this application. There is a file made with the current version of this application that already exists with the same name.  If you continue, you will overwrite that file.", @"Informative: Performing migration, the destination file already exists");
		[alert setInformativeText:informativeText];
		
		NSString *buttonTitle = NSLocalizedString(@"Continue", @"Continue");
		[alert addButtonWithTitle:buttonTitle];
		buttonTitle = NSLocalizedString(@"Cancel", @"Cancel");
		[alert addButtonWithTitle:buttonTitle];
		
		NSInteger button = [alert runModal];
		
		if (button == NSAlertSecondButtonReturn) {
			NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSUserCancelledError userInfo:nil];
			*outError = error;

#ifdef MY_DOCUMENT_CONTROLLER_TRACE_METHODS
			printf("OUT [MyDocumentController destinationURLWithPath:%s error:]\n", [destinationPath CSTRING]);
#endif
			return nil;
		}
		
		/*
		 Remove the existing file.
		 If you don't do this, the data from the opened file may simply be appended.
		 */
		BOOL ok = [[NSFileManager defaultManager] removeItemAtPath:destinationPath error:outError];
		if (!ok)
		{
			/*
			 The error here is a little misleading: It will say that you don't have permission to open the existing file, not that you couln't remove the destination. Improving this is left as an exercise for the reader.
			 */
#ifdef MY_DOCUMENT_CONTROLLER_TRACE_METHODS
			printf("OUT [MyDocumentController destinationURLWithPath:%s error:]\n", [destinationPath CSTRING]);
#endif
			return nil;
		}
	}
	
	destinationURL = [NSURL fileURLWithPath:destinationPath isDirectory:NO];

#ifdef MY_DOCUMENT_CONTROLLER_TRACE_METHODS
	printf("OUT [MyDocumentController destinationURLWithPath:%s error:]\n", [destinationPath CSTRING]);
#endif
	return destinationURL;
}


@end
