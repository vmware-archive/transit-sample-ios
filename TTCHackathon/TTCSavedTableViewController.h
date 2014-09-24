//
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTCStopAndRouteInfo.h"
#import "TTCSignInViewController.h"

@interface TTCSavedTableViewController : UITableViewController <TTCSignInViewDelegate>

- (IBAction) logout;
- (IBAction) unwindToSavedTableView:(UIStoryboardSegue *)sender;
- (void) addToStopAndRoute:(TTCStopAndRouteInfo *)stopAndRouteObject;

@end
