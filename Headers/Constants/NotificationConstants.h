/*
 *  NotificationConstants.h
 *  Ges
 *
 *  Created by NeoJF on 15/06/07.
 *  Copyright 2007 __MyCompanyName__. All rights reserved.
 *
 */

static NSString *NotificationNameAccountFilterStateModified = @"accountFilterStateModifiedNotification";
static NSString *NotificationNameModeFilterStateModified = @"modeFilterStateModifiedNotification";
static NSString *NotificationNamePersonFilterStateModified = @"personFilterStateModifiedNotification";
static NSString *NotificationNamePostFilterStateModified = @"postFilterStateModifiedNotification";
static NSString *NotificationNameTypeFilterStateModified = @"typeFilterStateModifiedNotification";

//static NSString *NotificationUserInfoKeyAccountsIn = @"NotificationUserInfoKeyAccountsIn";
//static NSString *NotificationUserInfoKeyAccountsOut = @"NotificationUserInfoKeyAccountsOut";
static NSString *NotificationUserInfoKeyFilterStateObject = @"NotificationUserInfoKeyFilterStateObject";
static NSString *NotificationUserInfoKeyFilterStateOriginal = @"NotificationUserInfoKeyFilterStateOriginal";
static NSString *NotificationUserInfoKeyFilterStateTarget = @"NotificationUserInfoKeyFilterStateTarget";

/*
 * These notifications are used by classes which intervene on properties which cause
 * the FilterController instance to rearrange operations when modified. They ask
 * the FilterController to start or stop filtering operations. This is used in order
 * to optimize some specific actions (such as excluding a post from the filter, asking to
 * filter only once all types have been excluded).
 */
static NSString *NotificationNameStartFilteringOperations = @"startFilteringOperationsNotification";
static NSString *NotificationNameStopFilteringOperations = @"stopFilteringOperationsNotification";