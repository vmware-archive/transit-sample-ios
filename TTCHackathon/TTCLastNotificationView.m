//
//  TTCHeaderCell.m
//  TTCHackathon
//
//  Created by Rob Szumlakowski on 2014-11-13.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#define ANIMATION_ITERATIONS 13
#define ANIMATION_PERIOD 0.2

#import "TTCLastNotificationView.h"

@interface TTCLastNotificationView ()

@property NSInteger animationIterationsRemaining;

@end

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

- (void) flash
{
    self.animationIterationsRemaining = ANIMATION_ITERATIONS;
    [self fadeIn:self.labelView];
    [self fadeIn:self.notificationView];
}

- (void) fadeIn:(UIView*)view
{
    view.alpha = 0;
    [UIView animateWithDuration:ANIMATION_PERIOD animations:^{
        view.alpha = 1;
    } completion:^(BOOL finished) {
        self.animationIterationsRemaining -= 1;
        if (self.animationIterationsRemaining > 0) {
            [self fadeOut:view];
        }
    }];
}

- (void) fadeOut:(UIView*)view
{
    view.alpha = 1;
    [UIView animateWithDuration:ANIMATION_PERIOD animations:^{
        view.alpha = 0;
    } completion:^(BOOL finished) {
        self.animationIterationsRemaining -= 1;
        if (self.animationIterationsRemaining > 0) {
            [self fadeIn:view];
        }
    }];
}

@end
