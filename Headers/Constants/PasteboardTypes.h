/*
 *  PastboardTypes.h
 *  Ges
 *
 *  Created by Romain Champourlier on 24/10/09.
 *  Copyright 2009 SoftRoch. All rights reserved.
 *
 */

/**
 Contains all row type constant strings used to identified pasteboard's data type
 when performing drag'n'drop operations.
 */
static NSString *PasteboardRowTypePost = @"PasteboardRowTypePost";
static NSString *PasteboardRowTypeType = @"PasteboardRowTypeType";
static NSString *PasteboardRowTypeTypesSet = @"PasteboardRowTypeTypesSet";

// TODO: change to types representing pasteboard's data type, instead of source. Should allow to perform drag'n'drop operations from one view to another.
static NSString* entitiesTableViewRowType = @"entitiesTableViewRowType";
static NSString* typesOutlineViewRowType = @"typesOutlineViewRowType";
static NSString* postsOutlineViewRowType = @"postsOutlineViewRowType";
