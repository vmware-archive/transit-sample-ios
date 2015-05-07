//
//  TTCInboxTableViewCell.h
//  TTCHackathon
//
//  Created by DX122-XL on 2015-05-07.
//  Copyright (c) 2015 Pivotal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTCNotificationsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *timestampLabel;

@end
