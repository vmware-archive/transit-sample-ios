//
//  TTCInboxItemViewController.m
//  TTCHackathon
//
//  Created by DX122-XL on 2015-05-07.
//  Copyright (c) 2015 Pivotal. All rights reserved.
//

#import "TTCNotificationViewController.h"
#import "TTCNotification.h"

@interface TTCNotificationViewController ()

@end

@implementation TTCNotificationViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self populateView];
}

- (void)populateView {
    self.timestampLabel.text = self.notification.formattedDate;
    self.messageLabel.text = self.notification.message;
}

@end
