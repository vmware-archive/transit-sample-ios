//
//  Copyright (C) 2014 Pivotal Software, Inc. All rights reserved.
//

#import <PCFPush/PCFPush.h>
#import <PCFData/PCFData.h>
#import <PCFAuth/PCFAuth.h>
#import "TTCAppDelegate.h"
#import "TTCUserDefaults.h"
#import "TTCPushRegistrationHelper.h"

NSString *const kRemoteNotificationReceived = @"NOTIFICATION_RECEIVED";

@implementation TTCAppDelegate

- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Register with apns when app is launched
    [TTCPushRegistrationHelper registerWithApns];
    
    [PCFData registerTokenProviderBlock:^() {
        return [PCFAuth fetchToken].accessToken;
    }];
    
    [PCFData registerTokenInvalidatorBlock:^() {
        [PCFAuth invalidateToken];
    }];
    
    [PCFAuth registerLoginObserverBlock:^{
        // Re-register with apns when logging in
        [TTCPushRegistrationHelper registerWithApns];
    }];
    
    [PCFAuth registerLogoutObserverBlock:^{
        [TTCPushRegistrationHelper unregister];
    }];
    
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

// This method is called when APNS registration fails.
- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"APNS registration failed: %@", error);
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

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [PCFData performSyncWithCompletionHandler:completionHandler];
}

@end