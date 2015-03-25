//
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import "TTCNotificationTableViewCell.h"

@implementation TTCNotificationTableViewCell

- (void) populateViews:(TTCStopAndRouteInfo *)currentItem tag:(NSInteger)tag
{
    [self.routeLabel setText:currentItem.route];
    
    [self.stopLabel setText:currentItem.stop];
    
    [self.timeLabel setText:currentItem.time];
    
    [self.toggleSwitch setOn:currentItem.enabled animated:YES];
    [self.toggleSwitch setTag:tag];
}

@end
