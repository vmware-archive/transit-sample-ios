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

@import PCFAppAnalytics;

@interface TTCAppDelegate ()

@property (strong) TTCNotificationStore *notificationStore;

@end

@implementation TTCAppDelegate

- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    PCFAppAnalytics *analytics = [PCFAppAnalytics initWithLaunchOptions:launchOptions];
    analytics.acceptSelfSignedCertificates = YES;

    self.notificationStore = [[TTCNotificationStore alloc] init];
    
    [TTCPush registerWithApns];
    
    [PCFAuth registerLoginObserverBlock:^{
        [TTCPush registerWithApns];
    }];
    
    [PCFAuth registerLogoutObserverBlock:^{
        [TTCPush unregister];
        [PCFData clearCachedData];
    }];
    
    [PCFData registerTokenProviderBlock:^{
        return [PCFAuth fetchToken].accessToken;
    }];
    
    [PCFData registerTokenInvalidatorBlock:^{
        [PCFAuth invalidateToken];
    }];
    
    NSDictionary *pushNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (pushNotification) {
        [self pushInboxViewController];
    }
    
    #if SHOW_TOUCHES
        // For demo purposes, show the touches even when not mirroring to an external display.
        QTouchposeApplication *touchposeApplication = (QTouchposeApplication *)application;
        touchposeApplication.alwaysShowTouches = YES;
    #endif
    
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

    [[PCFAppAnalytics shared] eventWithName:@"notificationReceived"];

    [self.notificationStore addNotification:userInfo];
    
    [self displayLocalNotificationForNotification:userInfo];
    
    if (application.applicationState != UIApplicationStateActive) {
        [self pushInboxViewController];
    }
    
    if (handler) {
        handler(UIBackgroundFetchResultNewData);
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

- (void)displayLocalNotificationForNotification:(NSDictionary *)userInfo {
    BOOL contentAvailable = [[userInfo valueForKeyPath:@"aps.content-available"] boolValue];
    if (contentAvailable) {
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.alertBody = [userInfo valueForKeyPath:@"aps.alert"];
        localNotification.timeZone = [NSTimeZone defaultTimeZone];
        localNotification.fireDate = [NSDate date];
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }
}

@end