//
//  Copyright (C) 2014 Pivotal Software, Inc. All rights reserved.
//

#import <PCFPush/PCFPush.h>
#import <PCFData/PCFData.h>
#import <PCFAuth/PCFAuth.h>
#import "TTCAppDelegate.h"
#import "TTCPush.h"
#import "TTCRootViewController.h"
#import "TTCSideMenuViewController.h"

@interface TTCAppDelegate ()

@property (strong) TTCNotificationStore *notificationStore;

@end

@implementation TTCAppDelegate

- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.notificationStore = [[TTCNotificationStore alloc] init];
    
    [TTCPush registerWithApns];
    
    [PCFAuth registerLoginObserverBlock:^{
        [TTCPush registerWithApns];
    }];
    
    [PCFAuth registerLogoutObserverBlock:^{
        [TTCPush unregister];
        [PCFData clearCachedData];
    }];
    
    [PCFData registerTokenProviderBlock:^() {
        return [PCFAuth fetchToken].accessToken;
    }];
    
    [PCFData registerTokenInvalidatorBlock:^() {
        [PCFAuth invalidateToken];
    }];
    
    NSDictionary *pushNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (pushNotification) {
        [self pushInboxViewController];
    }
    
    return YES;
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"APNS registration succeeded!");

    [TTCPush registerWithDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"APNS registration failed: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))handler {
    NSLog(@"Remote notification received: %@", userInfo);

    [self.notificationStore didReceiveRemoteNotification:userInfo];

    if (handler) {
        handler(UIBackgroundFetchResultNewData);
    }
    
    if (application.applicationState != UIApplicationStateActive) {
        [self pushInboxViewController];
    }
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [PCFData performSyncWithCompletionHandler:completionHandler];
}

- (void)pushInboxViewController {
    TTCRootViewController *vc = (TTCRootViewController *) self.window.rootViewController;
    TTCSideMenuViewController *svc = (TTCSideMenuViewController *) vc.leftMenuViewController;
    [svc routeToIndex:0];
}

@end