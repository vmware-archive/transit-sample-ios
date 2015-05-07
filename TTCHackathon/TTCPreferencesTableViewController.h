//
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTCStopAndRouteInfo.h"

@interface TTCPreferencesTableViewController : UITableViewController

- (IBAction) unwindToSavedTableView:(UIStoryboardSegue *)sender;
- (void) addToStopAndRoute:(TTCStopAndRouteInfo *)stopAndRouteObject;

@end
