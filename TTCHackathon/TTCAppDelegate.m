//
//  Copyright (C) 2014 Pivotal Software, Inc. All rights reserved.
//

#import <PCFPush/PCFPush.h>
#import <PCFData/PCFData.h>
#import <PCFAuth/PCFAuth.h>
#import "TTCAppDelegate.h"
#import "TTCPushRegistrationHelper.h"

@interface TTCAppDelegate ()

@property (strong) TTCNotificationStore *notificationStore;

@end

@implementation TTCAppDelegate

- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.notificationStore = [[TTCNotificationStore alloc] init];
    
    // Register with apns when app is launched
    [TTCPushRegistrationHelper registerWithApns];
    
    // Re-register with apns when logged in
    [PCFAuth registerLoginObserverBlock:^{
        [TTCPushRegistrationHelper registerWithApns];
    }];
    
    [PCFAuth registerLogoutObserverBlock:^{
        [TTCPushRegistrationHelper unregister];
    }];
    
    [PCFData registerTokenProviderBlock:^() {
        return [PCFAuth fetchToken].accessToken;
    }];
    
    [PCFData registerTokenInvalidatorBlock:^() {
        [PCFAuth invalidateToken];
    }];
    
    return YES;
}

// This method is called when APNS registration succeeds.
- (void) application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"APNS registration succeeded!");

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

    [self.notificationStore didReceiveRemoteNotification:userInfo];

    if (handler) {
        handler(UIBackgroundFetchResultNewData);
    }
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [PCFData performSyncWithCompletionHandler:completionHandler];
}

@end