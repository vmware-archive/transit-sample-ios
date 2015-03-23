//
//  Copyright (C) 2014 Pivotal Software, Inc. All rights reserved.
//

#import <PCFPush/PCFPush.h>
#import <MSSData/MSSDataSignIn.h>
#import "TTCAppDelegate.h"
#import "TTCUserDefaults.h"

NSString *const kRemoteNotificationReceived = @"NOTIFICATION_RECEIVED";

@implementation TTCAppDelegate

- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
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
    
    return YES;
}

// This method is called when APNS registration succeeds.
- (void) application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"APNS registration succeeded!");
    
    // APNS registration has succeeded and provided the APNS device token.  Start registration with PCF Mobile Services
    // and pass it the APNS device token.
    //
    // Required: Create a file in your project called "Pivotal.plist" in order to provide parameters for registering with
    // PCF Mobile Services.
    //
    // Optional: You can also provide a set of tags to subscribe to.
    //
    // Optional: You can also provide a device alias.  The use of this device alias is application-specific.  In general,
    // you can pass the device name.
    //
    // Optional: You can pass blocks to get callbacks after registration succeeds or fails.
    //
    [PCFPush registerForPCFPushNotificationsWithDeviceToken:deviceToken tags:nil deviceAlias:UIDevice.currentDevice.name success:^{
        NSLog(@"CF registration succeeded!");
    } failure:^(NSError *error) {
        NSLog(@"CF registration failed: %@", error);
    }];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))handler
{
    NSLog(@"Remote notification received: %@", userInfo);
    
    if (userInfo[@"aps"][@"alert"]) {
        [TTCUserDefaults setLastNotificationText:userInfo[@"aps"][@"alert"]];
    } else {
        [TTCUserDefaults setLastNotificationText:@"NO MESSAGE"];
    }
    
    [TTCUserDefaults setLastNotificationTime:[NSDate date]];
    [[NSNotificationCenter defaultCenter] postNotificationName:kRemoteNotificationReceived object:self userInfo:userInfo];

    if (handler) {
        handler(UIBackgroundFetchResultNewData);
    }
}

- (BOOL) application:(UIApplication *)application
             openURL:(NSURL *)url
   sourceApplication:(NSString *)sourceApplication
          annotation:(id)annotation
{
    return [[MSSDataSignIn sharedInstance] handleURL:url
                                   sourceApplication:sourceApplication
                                          annotation:annotation];
}

@end
