//
//  MyDocument_Import.m
//  Ges
//
//  Created by Romain Champourlier on 28/09/08.
//  Copyright 2008 Galilée Conseil & Technologies. All rights reserved.
//

#import "MyDocument_Import.h"


@implementation MyDocument(Import)

#define FIELDS_NUMBER 10

- (void)importCSVFile {
	FILE *f = fopen("/Users/roch/Scratch/totalFin.txt", "r");
	if (f != NULL) {
		
		NSManagedObjectContext* moc = [self managedObjectContext];
		
		// TODO: should migrate the Person entity to PrioritizedManagedObject
		NSManagedObject *person = [NSEntityDescription insertNewObjectForEntityForName:EntityNamePerson inManagedObjectContext:moc];
		[person setValue:@"Person" forKey:@"name"];
		[person setValue:[NSNumber numberWithInt:0] forKey:@"priority"];
				
		while (!feof(f)) {
			printf("get a line!\n");
			//char *s = (char *)malloc(sizeof(char) * 1024);
			char *s = (char *)calloc(1024, sizeof(char));
			fgets(s, 1024, f);
			
			char **ap, *argv[FIELDS_NUMBER];
			for (ap = argv; (*ap = strsep(&s, ";")) != NULL;)
				if (**ap != '\0')
					if (++ap >= &argv[FIELDS_NUMBER])
						break;
			
			free(s);
			
			int opDay, opMonth, opYear, valDay, valMonth, valYear;
			sscanf(argv[1], "%d/%d/%d", &opDay, &opMonth, &opYear);
			sscanf(argv[0], "%d/%d/%d", &valDay, &valMonth, &valYear);
			NSCalendarDate *operationDate = [NSCalendarDate dateWithString:[NSString stringWithFormat:@"%d-%02d-%02d 12:00:00 +0100", opYear, opMonth, opDay]];
			NSCalendarDate *valueDate = [NSCalendarDate dateWithString:[NSString stringWithFormat:@"%d-%02d-%02d 12:00:00 +0100", valYear, valMonth, valDay]];
			
			int pointedStateInt;
			if (argv[2][0] == 'V') pointedStateInt = POINTED_STATE_ENABLED;
			else if (argv[2][0] == 'R') pointedStateInt = POINTED_STATE_DISABLED;
			else pointedStateInt = POINTED_STATE_UNSET;
			
			NSNumber *pointedState = [NSNumber numberWithInt:pointedStateInt];
			NSString *description = [NSString stringWithCString:argv[3] encoding:NSUTF8StringEncoding];
			printf("description: %s->%s\n", argv[3], [description CSTRING]);
			NSNumber *value = [NSNumber numberWithFloat:atof(argv[4])];
			NSString *postName = [NSString stringWithCString:argv[5] encoding:NSUTF8StringEncoding];
			NSString *typeName = [NSString stringWithCString:argv[6] encoding:NSUTF8StringEncoding];
			NSString *accountName = [NSString stringWithCString:argv[7] encoding:NSUTF8StringEncoding];
			NSString *modeName = [NSString stringWithCString:argv[8] encoding:NSUTF8StringEncoding];
			
			NSString *reference;
			if (argv[9] != NULL) {
				reference = [NSString stringWithCString:argv[9] encoding:NSUTF8StringEncoding];
			}
			else {
				reference = nil;
			}
			
			AccountManagedObject *account = [self getAccountForName:accountName];
			ModeManagedObject *mode = [self getModeForName:modeName];
			TypeManagedObject *type = [self getTypeForName:typeName postName:postName];
			PostManagedObject *post = [type valueForKey:@"post"];
			
			// Creating operation
			printf("--- Creating operation: %s\n", [description CSTRING]);
			
			//NSCalendarDate* today = [NSCalendarDate date];
			//NSCalendarDate* todayMidday = [NSCalendarDate dateWithYear:[today yearOfCommonEra] month:[today monthOfYear] day:[today dayOfMonth] hour:12 minute:0 second:0 timeZone:nil];
			NSManagedObject* newOperation = [NSEntityDescription insertNewObjectForEntityForName:EntityNameOperation inManagedObjectContext:moc];
			[newOperation setValue:NSLocalizedString(@"operationDefaultDescription", nil) forKey:@"operationDescription"];
			[newOperation setValue:operationDate forKey:@"operationDate"];
			[newOperation setValue:valueDate forKey:@"valueDate"];
			[newOperation setValue:account forKey:@"account"];
			[newOperation setValue:mode forKey:@"mode"];
			[newOperation setValue:post forKey:@"post"];
			[newOperation setValue:type forKey:@"type"];
			[newOperation setValue:person forKey:@"person"];
			[newOperation setValue:value forKey:@"value"];
			[newOperation setValue:description forKey:@"operationDescription"];
			if (reference != nil) [newOperation setValue:reference forKey:@"reference"];
			[newOperation setValue:pointedState forKey:@"pointedState"];
			
			[operationsArrayController rearrangeObjects];
		}
	}
	
	[editionSelectionSourceListController fillSourceListView];
}

- (void)exportCSVFile {
	FILE *f = fopen("/Users/Shared/ges-export.csv", "w");
	if (f != NULL) {
    fprintf(f, "account;operation-date;value-date;amount;description;mode;post;type;person;reference;\n");
		for (id operation in [operationsArrayController arrangedObjects]) {
      fprintf(f, "%s;%s;%s;%.2f;%s;%s;%s;%s;%s;%s;\n",
             [[[operation valueForKey:@"account"] valueForKey:@"name"] cStringUsingEncoding:NSUTF8StringEncoding],
             [[((NSCalendarDate *)[operation valueForKey:@"operationDate"]) descriptionWithCalendarFormat:@"%d/%m/%Y" timeZone:nil locale:nil] cStringUsingEncoding:NSUTF8StringEncoding],
             [[((NSCalendarDate *)[operation valueForKey:@"valueDate"]) descriptionWithCalendarFormat:@"%d/%m/%Y" timeZone:nil locale:nil]  cStringUsingEncoding:NSUTF8StringEncoding],
             [[operation valueForKey:@"value"] floatValue],
             [[operation valueForKey:@"operationDescription"] cStringUsingEncoding:NSUTF8StringEncoding],
             [[[operation valueForKey:@"mode"] valueForKey:@"name"] cStringUsingEncoding:NSUTF8StringEncoding],
             [[[operation valueForKey:@"post"] valueForKey:@"name"] cStringUsingEncoding:NSUTF8StringEncoding],
             [[[operation valueForKey:@"type"] valueForKey:@"name"] cStringUsingEncoding:NSUTF8StringEncoding],
             [[[operation valueForKey:@"person"] valueForKey:@"name"] cStringUsingEncoding:NSUTF8StringEncoding],
             [[operation valueForKey:@"reference"] cStringUsingEncoding:NSUTF8StringEncoding]);
    }
    fclose(f);
	}
	
	[editionSelectionSourceListController fillSourceListView];
}

- (AccountManagedObject *)getAccountForName:(NSString *)aName {
	printf("IN  [MyDocument(Import) getAccountForName:%s]\n", [aName CSTRING]);
	
	NSManagedObjectContext *moc = [self managedObjectContext];
	NSFetchRequest *req = [[NSFetchRequest alloc] init];
	[req setEntity:[NSEntityDescription entityForName:EntityNameAccount inManagedObjectContext:moc]];
	[req setPredicate:[NSPredicate predicateWithFormat:@"name == %@", aName]];
	
	NSArray *results = [moc executeFetchRequest:req error:NULL];
	
	AccountManagedObject *newAccount;
	if ([results count] == 1) {
		printf("--- existing account found\n");
		newAccount = [results objectAtIndex:0];
	}
	else {
		// Inserting the new account in managed object context
		newAccount = [NSEntityDescription insertNewObjectForEntityForName:EntityNameAccount inManagedObjectContext:moc];
		NSMutableSet* availableModesSet = [newAccount mutableSetValueForKey:@"availableModes"];
		
		// Setting initial values
		[newAccount setValue:aName forKey:@"name"];
		int priority = [[accountsArrayController arrangedObjects] count];
		[newAccount setValue:[NSNumber numberWithInt:priority] forKey:@"priority"];
		[availableModesSet addObjectsFromArray:[modesArrayController content]];
		
		printf("--- new account created\n");
	}
	
	printf("OUT [MyDocument(Import) getAccountForName:%s]\n", [aName CSTRING]);
	
	return newAccount;
}

- (ModeManagedObject *)getModeForName:(NSString *)aName {
	printf("IN  [MyDocument(Import) getModeForName:%s]\n", [aName CSTRING]);

	NSManagedObjectContext *moc = [self managedObjectContext];
	NSFetchRequest *req = [[NSFetchRequest alloc] init];
	[req setEntity:[NSEntityDescription entityForName:EntityNameMode inManagedObjectContext:moc]];
	[req setPredicate:[NSPredicate predicateWithFormat:@"name == %@", aName]];
	
	NSArray *results = [moc executeFetchRequest:req error:NULL];
	
	ModeManagedObject *newMode;
	if ([results count] == 1) {
		printf("--- existing mode found\n");
		newMode = [results objectAtIndex:0];
	}
	else {
		// Inserting the new mode in managed object context
		newMode = [NSEntityDescription insertNewObjectForEntityForName:EntityNameMode inManagedObjectContext:moc];
		
		// Setting initial values
		[newMode setValue:aName forKey:@"name"];
		int priority = [[modesArrayController arrangedObjects] count];
		[newMode setValue:[NSNumber numberWithInt:priority] forKey:@"priority"];
		[newMode setValue:[NSNumber numberWithBool:YES] forKey:@"allowsValueDate"];
		
		// The created mode is added to the 'availableModes' relationship of each account.
		NSArray* accountsArray = [accountsArrayController content];
		for (id loopItem in accountsArray) {
			NSMutableSet* availableModesSet = [loopItem mutableSetValueForKey:@"availableModes"];
			[availableModesSet addObject:newMode];
		}
		
		// The created mode is added to the 'availableModes' relationship of each account.
		accountsArray = [accountsArrayController content];
		for (id loopItem in accountsArray) {
			NSMutableSet* availableModesSet = [loopItem mutableSetValueForKey:@"availableModes"];
			[availableModesSet addObject:newMode];
		}		
		
		[moc processPendingChanges];
		
		printf("--- new mode created\n");
	}

	printf("OUT [MyDocument(Import) getModeForName:%s]\n", [aName CSTRING]);

	return newMode;
}

- (TypeManagedObject *)getTypeForName:(NSString *)typeName postName:(NSString *)postName{
	printf("IN  [MyDocument(Import) getTypeForName:%s postName:%s]\n", [typeName CSTRING], [postName CSTRING]);
	
	NSManagedObjectContext *moc = [self managedObjectContext];
	NSFetchRequest *req = [[NSFetchRequest alloc] init];
	[req setEntity:[NSEntityDescription entityForName:EntityNameType inManagedObjectContext:moc]];
	[req setPredicate:[NSPredicate predicateWithFormat:@"name == %@ and post.name == %@", typeName, postName]];
	
	TypeManagedObject *type;
	NSArray *results = [moc executeFetchRequest:req error:NULL];
	if ([results count] == 1) {
		type = [results objectAtIndex:0];
		printf("--- existing type found (post=%s, containing %d types)\n", [[type valueForKeyPath:@"post.name"] CSTRING], [[type valueForKeyPath:@"post.types"] count]);
	}
	
	else {
		// Fetching the parent post if existing
		[req setEntity:[NSEntityDescription entityForName:EntityNamePost inManagedObjectContext:moc]];
		[req setPredicate:[NSPredicate predicateWithFormat:@"name == %@", postName]];
		
		PostManagedObject *post;
		results = [moc executeFetchRequest:req error:NULL];
		if ([results count] == 1) {
			post = [results objectAtIndex:0];
			printf("--- existing post found (containing %d types)\n", [[post valueForKey:@"types"] count]);
		}
		else {
			// Creating a new post and inserting it in the managed object context
			post = [NSEntityDescription insertNewObjectForEntityForName:EntityNamePost inManagedObjectContext:moc];
		
			// Setting initial values
			[post setValue:postName forKey:@"name"];
			[post setValue:[NSNumber numberWithInt:0] forKey:@"priority"];
			printf("--- creating a new post\n");
		}
		
		// Creating the new type and inserting it in the managed object context
		type = [NSEntityDescription insertNewObjectForEntityForName:EntityNameType inManagedObjectContext:moc];
		
		// Setting initial values
		[type setValue:typeName forKey:@"name"];
		[type setValue:[NSNumber numberWithInt:0] forKey:@"priority"];
		[type setValue:post forKey:@"post"];
		
		printf("--- creating new type: \"%s\" to post \"%s\". post's types are now %d\n", [[type valueForKey:@"name"] CSTRING], [[post valueForKey:@"name"] CSTRING], [[post valueForKey:@"types"] count]);
		
		[moc processPendingChanges];
	}

	printf("OUT [MyDocument(Import) getTypeForName:%s postName:%s]\n", [typeName CSTRING], [postName CSTRING]);

	return type;
}

@end
