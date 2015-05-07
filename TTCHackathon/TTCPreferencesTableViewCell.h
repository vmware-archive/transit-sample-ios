//
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTCStopAndRouteInfo.h"

@interface TTCPreferencesTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *routeLabel;
@property (weak, nonatomic) IBOutlet UILabel *stopLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UISwitch *toggleSwitch;
@property (weak, nonatomic) IBOutlet UILabel *routeNumberLabel;

- (void) populateViews:(TTCStopAndRouteInfo *)currentItem tag:(NSInteger)tag;

@end
