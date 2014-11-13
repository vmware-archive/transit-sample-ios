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

- (void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    if (userInfo[@"aps"][@"alert"]) {
        NSLog(@"Remote notification received: %@", userInfo[@"aps"][@"alert"]);
        
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {

            [TTCUserDefaults setLastNotificationText:userInfo[@"aps"][@"alert"]];
            [TTCUserDefaults setLastNotificationTime:[NSDate date]];

            [[NSNotificationCenter defaultCenter] postNotificationName:kRemoteNotificationReceived object:self userInfo:userInfo];
        }
        
    } else {
        NSLog(@"Remote notification received!");
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
