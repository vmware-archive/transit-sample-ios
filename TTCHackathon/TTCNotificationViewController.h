//
//  TTCInboxItemViewController.h
//  TTCHackathon
//
//  Created by DX122-XL on 2015-05-07.
//  Copyright (c) 2015 Pivotal. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TTCNotification;

@interface TTCNotificationViewController : UIViewController

@property (strong, nonatomic) TTCNotification *notification;

@property (weak, nonatomic) IBOutlet UILabel *timestampLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@end
