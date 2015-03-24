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

    NSLog(@"Subscribing to tags: %@", pushTags);
    
    [PCFPush subscribeToTags:pushTags success:^{
        NSLog(@"CF tags update succeeded!");
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    } failure:^(NSError *error) {
        NSLog(@"CF tags update failed: %@", error);
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }];
}

+ (void) registerWithApns
{
    UIApplication *application = [UIApplication sharedApplication];
    
    // Register for push notifications with the Apple Push Notification Service (APNS).
    //
    // On iOS 8.0+ you need to provide your user notification settings by calling
    // [UIApplication.sharedDelegate registerUserNotificationSettings:] and then
    // [UIApplication.sharedDelegate registerForRemoteNotifications];
    //
    // On < iOS 8.0 you need to provide your remote notification settings by calling
    // [UIApplication.sharedDelegate registerForRemoteNotificationTypes:].  There are no
    // user notification settings on < iOS 8.0.
    //
    // If this line gives you a compiler error then you need to make sure you have updated
    // your Xcode to at least Xcode 6.0:
    //
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
