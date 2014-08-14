//
//  PCFSavedCell.h
//  TTCHackathon
//
//  Created by DX121-XL on 2014-08-14.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PCFStopAndRouteInfo.h"

@interface PCFSavedCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *routeLabel;
@property (weak, nonatomic) IBOutlet UILabel *stopLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UISwitch *toggleSwitch;

-(void)populateViews:(PCFStopAndRouteInfo *)currentItem tag:(NSInteger)tag;
@end
