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

- (void)didReceiveRemoteNotification:(NSDictionary *)notification {
    [self addNotification:notification];
}

- (void)addNotification:(NSDictionary *)notification {
    NSMutableDictionary *formatted = [self formatNotificationWithTimestamp:notification];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PCFDataResponse *getResponse = [self.remoteObject get];
        PCFKeyValue *keyValue = (PCFKeyValue *) getResponse.object;
        
        NSString *newSerialized = [self serializeDictionary:formatted previous:keyValue.value];
        
        PCFDataResponse *putResponse = [self.remoteObject putWithValue:newSerialized];

        if (!putResponse.error) {
            NSLog(@"Success saving messages");
        } else {
            NSLog(@"Error saving messages: %@", putResponse.error);
        }
    });
}

- (NSMutableDictionary *)formatNotificationWithTimestamp:(NSDictionary *)notification {
    NSMutableDictionary *formattedNotification = [notification mutableCopy];
    NSMutableDictionary *apsDictionary = [[formattedNotification objectForKey:@"aps"] mutableCopy];
    [apsDictionary setObject:[NSNumber numberWithLong:[[NSDate date] timeIntervalSince1970]] forKey:@"timestamp"];
    [formattedNotification setObject:apsDictionary forKey:@"aps"];
    return formattedNotification;
}

- (NSString *)serializeDictionary:(NSMutableDictionary *)notification previous:(NSString *)previous {
    NSArray *array = [self addNotificationToExistingArray:notification previous:previous];
    NSData *newData = [NSJSONSerialization dataWithJSONObject:array options:0 error:nil];
    NSString *newSerialized = [[NSString alloc] initWithData:newData encoding:NSUTF8StringEncoding];
    return newSerialized;
}

- (NSArray *)addNotificationToExistingArray:(NSMutableDictionary *)notification previous:(NSString *)previous {
    if (previous) {
        NSData *data = [previous dataUsingEncoding:NSUTF8StringEncoding];
        NSMutableArray *array = [[NSJSONSerialization JSONObjectWithData:data options:0 error:nil] mutableCopy];
        [array insertObject:notification atIndex:0];
        return array;
    } else {
        return [NSMutableArray arrayWithObject:notification];
    }
}

- (void)notificationsWithBlock:(void(^)(NSArray *messages))block {
    [self.remoteObject getWithCompletionBlock:^(PCFDataResponse *response) {
        if (!response.error) {
            PCFKeyValue *keyValue = (PCFKeyValue *) response.object;
            NSData *data = [keyValue.value dataUsingEncoding:NSUTF8StringEncoding];
            
            if (data && block) {
                block([NSJSONSerialization JSONObjectWithData:data options:0 error:nil]);
            }
        } else {
            NSLog(@"Error retrieving messages: %@", response.error);
            
            if (block) {
                block([NSArray array]);
            }
        }
    }];
}

- (void)clearNotificationsWithBlock:(void(^)())block {
    [self.remoteObject deleteWithCompletionBlock:^(PCFDataResponse *response) {
        if (block) {
            block();
        }
    }];
}

@end
