//
//  TTCNotificationStore.m
//  TTCHackathon
//
//  Created by DX122-XL on 2015-04-28.
//  Copyright (c) 2015 Pivotal. All rights reserved.
//

#import "TTCNotificationStore.h"
#import "TTCAppDelegate.h"

@interface TTCNotificationStore ()

@property (strong, readonly) NSUserDefaults *defaults;

@end

@implementation TTCNotificationStore

NSString* const TTCNotificationsKey = @"TTC:Notifications:Key";

- (instancetype)init
{
    self = [super init];
    _defaults = [NSUserDefaults standardUserDefaults];
    return self;
}

- (void)didReceiveRemoteNotification:(NSDictionary *)notification
{
    [self addNotification:notification];
}

- (void)addNotification:(NSDictionary *)notification
{
    NSMutableDictionary *formattedNotification = [self formatNotificationWithTimestamp:notification];
    
    @synchronized(self) {
        NSString *serialized = [self.defaults objectForKey:TTCNotificationsKey];
        
        NSMutableArray *array;
        
        if (!serialized) {
            array = [NSMutableArray arrayWithObject:formattedNotification];
        } else {
            NSData *data = [serialized dataUsingEncoding:NSUTF8StringEncoding];
            array = [[NSJSONSerialization JSONObjectWithData:data options:0 error:nil] mutableCopy];
            
            [array insertObject:formattedNotification atIndex:0];
        }
        
        NSData *newData = [NSJSONSerialization dataWithJSONObject:array options:0 error:nil];
        NSString *newSerialized = [[NSString alloc] initWithData:newData encoding:NSUTF8StringEncoding];
        
        [self.defaults setObject:newSerialized forKey:TTCNotificationsKey];
    }
}

- (NSMutableDictionary *)formatNotificationWithTimestamp:(NSDictionary *)notification
{
    NSMutableDictionary *formattedNotification = [notification mutableCopy];
    NSMutableDictionary *apsDictionary = [[formattedNotification objectForKey:@"aps"] mutableCopy];
    [apsDictionary setObject:[NSNumber numberWithLong:[[NSDate date] timeIntervalSince1970]] forKey:@"timestamp"];
    [formattedNotification setObject:apsDictionary forKey:@"aps"];
    return formattedNotification;
}

- (NSArray *)notifications
{
    NSString *serialized;
    
    @synchronized(self) {
        serialized = [self.defaults objectForKey:TTCNotificationsKey];
    }
    
    NSData *data = [serialized dataUsingEncoding:NSUTF8StringEncoding];

    if (data) {
        return [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    } else {
        return nil;
    }
}

- (void)clearNotifications {
    [self.defaults removeObjectForKey:TTCNotificationsKey];
}

@end
