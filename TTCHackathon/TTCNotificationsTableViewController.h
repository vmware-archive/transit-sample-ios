//
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTCStopAndRouteInfo.h"

@interface TTCNotificationsTableViewController : UITableViewController

- (IBAction) logout;
- (IBAction) unwindToSavedTableView:(UIStoryboardSegue *)sender;
- (void) addToStopAndRoute:(TTCStopAndRouteInfo *)stopAndRouteObject;

@end
