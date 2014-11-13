//
//  TTCHeaderCell.m
//  TTCHackathon
//
//  Created by Rob Szumlakowski on 2014-11-13.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import "TTCLastNotificationView.h"

@implementation TTCLastNotificationView

- (void) showNotification:(NSString*)notification date:(NSDate*)date
{
    static NSDateFormatter *dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateStyle = NSDateFormatterNoStyle;
        dateFormatter.timeStyle = NSDateFormatterShortStyle;
    }
    if (notification) {
        self.notificationView.text = notification;
        self.labelView.text = [@"Last notification received: " stringByAppendingString:[dateFormatter stringFromDate:date]];
    } else {
        self.notificationView.text = nil;
        self.labelView.text = nil;
    }
}

@end
