//
//  MyDocument_Import.h
//  Ges
//
//  Created by Romain Champourlier on 28/09/08.
//  Copyright 2008 Galilée Conseil & Technologies. All rights reserved.
//

#import "MyDocument.h"
#import "ModeManagedObject.h"
#import "TypeManagedObject.h"

@interface MyDocument(Import)

- (void)importCSVFile;
- (void)exportCSVFile;
- (AccountManagedObject *)getAccountForName:(NSString *)aName;
- (ModeManagedObject *)getModeForName:(NSString *)aName;
- (TypeManagedObject *)getTypeForName:(NSString *)typeName postName:(NSString *)postName;

@end
