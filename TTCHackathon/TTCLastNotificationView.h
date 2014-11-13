//
//  TTCHeaderCell.h
//  TTCHackathon
//
//  Created by Rob Szumlakowski on 2014-11-13.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TTCLastNotificationView : UIView

@property (nonatomic) IBOutlet UITextView *labelView;
@property (nonatomic) IBOutlet UITextView *notificationView;

- (void) showNotification:(NSString*)notification date:(NSDate*)date;
- (void) flash;

@end
