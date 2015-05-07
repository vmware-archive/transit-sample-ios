//
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import "TTCPreferencesTableViewCell.h"
#import "TTCRouteUtil.h"
#import "TTCRouteTitleModel.h"

@implementation TTCPreferencesTableViewCell

- (void) populateViews:(TTCStopAndRouteInfo *)currentItem tag:(NSInteger)tag
{
    TTCRouteTitleModel *routeTitleModel = [TTCRouteUtil routeTitleModelFromRouteTitle:currentItem.route];
    
    [self.routeLabel setText:routeTitleModel.routeName];
    [self.routeNumberLabel setText:routeTitleModel.routeNumber];
    
    if (tag % 2 == 0) {
        self.routeNumberLabel.backgroundColor = [UIColor redColor];
    } else {
        self.routeNumberLabel.backgroundColor = [UIColor colorWithRed:0 green:152/255.0 blue:240/255.0 alpha:1];
    }
    
    [self.stopLabel setText:currentItem.stop];
    
    [self.timeLabel setText:currentItem.time];
    
    [self.toggleSwitch setOn:currentItem.enabled animated:YES];
    [self.toggleSwitch setTag:tag];
}

@end
