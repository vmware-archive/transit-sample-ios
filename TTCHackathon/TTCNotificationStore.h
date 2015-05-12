//
//  TTCNotificationStore.h
//  TTCHackathon
//
//  Created by DX122-XL on 2015-04-28.
//  Copyright (c) 2015 Pivotal. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const TTCNotificationsKey;

@interface TTCNotificationStore : NSObject

- (void)didReceiveRemoteNotification:(NSDictionary *)notification;

- (void)notificationsWithBlock:(void(^)(NSArray *messages))block;

- (void)clearNotificationsWithBlock:(void(^)())block;

@end
