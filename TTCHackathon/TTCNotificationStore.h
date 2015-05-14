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

- (void)addNotification:(NSDictionary *)notification;

- (void)fetchNotificationsWithBlock:(void(^)(NSArray *notifications, NSError *error))block;

- (void)updateNotifications:(NSArray *)notifications withBlock:(void(^)(NSArray *notifications, NSError *error))block;

- (void)clearNotificationsWithBlock:(void(^)(NSError *error))block;

@end
