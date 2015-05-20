//
//  TTCNotificationStore.m
//  TTCHackathon
//
//  Created by DX122-XL on 2015-04-28.
//  Copyright (c) 2015 Pivotal. All rights reserved.
//

#import "TTCNotificationStore.h"
#import "TTCAppDelegate.h"
#import <PCFData/PCFData.h>

@interface TTCNotificationStore ()

@property (strong, readonly) PCFKeyValueObject *remoteObject;

@end

@implementation TTCNotificationStore

NSString* const TTCNotificationsKey = @"TTC:Notifications:Key";

- (instancetype)init {
    self = [super init];
    _remoteObject = [PCFKeyValueObject objectWithCollection:@"notifications" key:@"messages"];
    return self;
}

- (void)addNotification:(NSDictionary *)notification {
    
    NSMutableDictionary *formatted = [self formatNotificationWithReadStateAndTimestamp:notification];
    
    PCFDataResponse *getResponse = [self.remoteObject get];
    
    if (getResponse.error) {
        NSLog(@"Error saving messages: %@", getResponse.error);
        return;
    }
    
    PCFKeyValue *keyValue = (PCFKeyValue *) getResponse.object;
    
    NSString *newSerialized = [self serializeNotification:formatted previous:keyValue.value];
    
    PCFDataResponse *putResponse = [self.remoteObject putWithValue:newSerialized];
    
    if (putResponse.error) {
        NSLog(@"Error saving messages: %@", putResponse.error);
        return;
    }
    
    NSLog(@"Successfully saved messages");
}

- (void)fetchNotificationsWithBlock:(void(^)(NSArray *notifications, NSError *error))block {
    [self.remoteObject getWithCompletionBlock:^(PCFDataResponse *response) {
        if (block) {
            if (!response.error) {
                PCFKeyValue *keyValue = (PCFKeyValue *) response.object;
                NSArray *notifications = [self deserializeNotifications:keyValue.value];
                block(notifications, nil);
            } else {
                block([NSArray array], response.error);
            }
        }
    }];
}

- (void)updateNotifications:(NSArray *)notifications withBlock:(void(^)(NSArray *notifications, NSError *error))block {
    
    NSString *serialized = [self serializeNotifications:notifications];
    
    [self.remoteObject putWithValue:serialized completionBlock:^(PCFDataResponse *response) {
        if (block) {
            if (!response.error) {
                block(notifications, nil);
            } else {
                block([NSArray array], response.error);
            }
        }
    }];
}

- (void)clearNotificationsWithBlock:(void(^)(NSError *error))block {
    [self.remoteObject putWithValue:@"" completionBlock:^(PCFDataResponse *response) {
        if (block) {
            block(response.error);
        }
    }];
}


- (NSMutableDictionary *)formatNotificationWithReadStateAndTimestamp:(NSDictionary *)notification {
    NSMutableDictionary *formattedNotification = [notification mutableCopy];
    [formattedNotification setObject:[NSNumber numberWithLong:[[NSDate date] timeIntervalSince1970]] forKey:@"timestamp"];
    [formattedNotification setObject:[NSNumber numberWithBool:false] forKey:@"read"];
    return formattedNotification;
}

- (NSString *)serializeNotification:(NSMutableDictionary *)notification previous:(NSString *)previous {
    NSArray *array = [self insertNotificationIntoExistingArray:notification previous:previous];
    NSArray *unique = [[NSOrderedSet orderedSetWithArray:array] array];
    return [self serializeNotifications:unique];
}

- (NSArray *)insertNotificationIntoExistingArray:(NSMutableDictionary *)notification previous:(NSString *)previous {
    if (previous.length > 0) {
        NSMutableArray *array = [[self deserializeNotifications:previous] mutableCopy];
        [array insertObject:notification atIndex:0];
        return array;
    } else {
        return [NSArray arrayWithObject:notification];
    }
}

- (NSArray *)deserializeNotifications:(NSString *)notifications {
    NSData *data = [notifications dataUsingEncoding:NSUTF8StringEncoding];
    return data ? [NSJSONSerialization JSONObjectWithData:data options:0 error:nil] : nil;
}

- (NSString *)serializeNotifications:(NSArray *)notifications {
    NSData *data = [NSJSONSerialization dataWithJSONObject:notifications options:0 error:nil];
    return data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;
}


@end
