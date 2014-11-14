//
//  Copyright (C) 2014 Pivotal Software, Inc. All rights reserved.
//

#import <MSSData/MSSDataSignIn.h>
#import "TTCAppDelegate.h"
#import "TTCUserDefaults.h"

NSString *const kRemoteNotificationReceived = @"NOTIFICATION_RECEIVED";

@implementation TTCAppDelegate

- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    return YES;
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
