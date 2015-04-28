//
//  TTCNotification.m
//  TTCHackathon
//
//  Created by DX122-XL on 2015-04-28.
//  Copyright (c) 2015 Pivotal. All rights reserved.
//

#import "TTCNotification.h"


@implementation TTCNotification

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _message = [dictionary valueForKeyPath:@"aps.alert"];
        _date = [NSDate dateWithTimeIntervalSince1970:[[dictionary valueForKeyPath:@"aps.timestamp"] doubleValue]];
    }
    return self;
}

- (NSString *)formattedDate {
    return [self.dateFormatter stringFromDate:self.date];
}

- (NSDateFormatter *)dateFormatter {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.locale = [NSLocale currentLocale];
        formatter.dateStyle = NSDateFormatterMediumStyle;
        formatter.timeStyle = NSDateFormatterMediumStyle;
        formatter.timeZone = [NSTimeZone defaultTimeZone];
    });
    return formatter;
}

@end
