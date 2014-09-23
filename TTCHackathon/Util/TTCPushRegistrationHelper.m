//
//  TTCPushRegistrationHelper.m
//  TTCHackathon
//
//  Created by Rob Szumlakowski on 2014-09-23.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <MSSPush/MSSPushClient.h>
#import <MSSPush/MSSParameters.h>
#import <MSSPush/MSSPush.h>
#import "TTCPushRegistrationHelper.h"
#import "TTCSettings.h"

@implementation TTCPushRegistrationHelper

/* Registering for notifications with the Push Service */
+ (void) initializePushSDK:(NSArray*)pushTags
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    MSSParameters *parameters = [[MSSParameters alloc] init];
    [parameters setPushAPIURL:kPushBaseServerUrl];
    [parameters setDevelopmentPushVariantUUID:kPushDevelopmentVariantUuid];
    [parameters setDevelopmentPushVariantSecret:kPushDevelopmentVariantSecret];
    [parameters setProductionPushVariantUUID:kPushProductionVariantUuid];
    [parameters setProductionPushVariantSecret:kPushProductionVariantSecret];
    [parameters setPushDeviceAlias:kPushDeviceAlias];
    [parameters setPushTags:[NSSet setWithArray:pushTags]];
    [MSSPush setRegistrationParameters:parameters];
    
    [MSSPush setCompletionBlockWithSuccess:^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
    } failure:^(NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }];
    
    UIApplication *application = [UIApplication sharedApplication];
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        
        // iOS 8.0+
        UIUserNotificationType notificationTypes = UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
        [application registerUserNotificationSettings:settings];
        
    } else {
        
        // < iOS 8.0
        UIRemoteNotificationType notificationType = UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound;
        [MSSPush setRemoteNotificationTypes:notificationType];
    }
    
    [MSSPush registerForPushNotifications];
}

@end
