//
//  PCFSavedCell.m
//  TTCHackathon
//
//  Created by DX121-XL on 2014-08-14.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import "PCFSavedCell.h"

@implementation PCFSavedCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];


}
-(void)populateViews:(PCFStopAndRouteInfo *)currentItem tag:(NSInteger)tag{
    
    [self.routeLabel setText:currentItem.route];
    
    [self.stopLabel setText:currentItem.stop];
    
    [self.timeLabel setText:currentItem.time];
    
    [self.toggleSwitch setOn:currentItem.enabled animated:YES];
    [self.toggleSwitch setTag:tag];

}

@end
