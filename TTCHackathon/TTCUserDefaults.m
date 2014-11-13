//
//  TTCUserDefaults.m
//  TTCHackathon
//
//  Created by Rob Szumlakowski on 2014-11-13.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

NSString *const kLastNotificationText = @"LAST_NOTIFICATION_TEXT";
NSString *const kLastNotificationTime = @"LAST_NOTIFICATION_TIME";

#import "TTCUserDefaults.h"

@implementation TTCUserDefaults

+ (NSString*) getLastNotificationText
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:kLastNotificationText];
}

+ (void) setLastNotificationText:(NSString*)text
{
    [[NSUserDefaults standardUserDefaults] setObject:text forKey:kLastNotificationText];
}

+ (NSDate*) getLastNotificationTime
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kLastNotificationTime];
}

+ (void) setLastNotificationTime:(NSDate*)date
{
    [[NSUserDefaults standardUserDefaults] setObject:date forKey:kLastNotificationTime];
}

@end
