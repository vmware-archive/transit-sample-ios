//
//  TTCPushRegistrationHelper.m
//  TTCHackathon
//
//  Created by Rob Szumlakowski on 2014-09-23.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <PCFPush/PCFPush.h>
#import "TTCPushRegistrationHelper.h"
#import "TTCSettings.h"

@implementation TTCPushRegistrationHelper

/* Registering for notifications with the Push Service */
+ (void) updateTags:(NSSet*)pushTags
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    UIApplication *application = [UIApplication sharedApplication];

    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        
        // iOS 8.0 +
        UIUserNotificationType notificationTypes = UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
        
    } else {
        
        // < iOS 8.0
        UIRemoteNotificationType notificationTypes = UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound;
        [application registerForRemoteNotificationTypes:notificationTypes];
    }
   
    [PCFPush subscribeToTags:pushTags success:^{
        NSLog(@"CF tags update succeeded!");
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    } failure:^(NSError *error) {
        NSLog(@"CF tags update failed: %@", error);
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }];
}

+ (void) unregister
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    [PCFPush unregisterFromPCFPushNotificationsWithSuccess:^{
        NSLog(@"Successfully unregistered from push notifications.");
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    } failure:^(NSError *error) {
        NSLog(@"Error upon unregistering from push notifications: %@", error);
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }];
}

@end
