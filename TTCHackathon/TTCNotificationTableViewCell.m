//
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import "TTCNotificationTableViewCell.h"

@implementation TTCNotificationTableViewCell

// TODO - remove these two methods - they don't do anything.

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    return [super initWithStyle:style reuseIdentifier:reuseIdentifier];
}

- (void) setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:NO animated:animated];
}

- (void) populateViews:(TTCStopAndRouteInfo *)currentItem tag:(NSInteger)tag
{
    [self.routeLabel setText:currentItem.route];
    
    [self.stopLabel setText:currentItem.stop];
    
    [self.timeLabel setText:currentItem.time];
    
    [self.toggleSwitch setOn:currentItem.enabled animated:YES];
    [self.toggleSwitch setTag:tag];
}

@end
