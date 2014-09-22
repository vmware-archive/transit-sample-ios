//
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTCStopAndRouteInfo.h"
#import "TTCSignInViewController.h"

@interface TTCSavedTableViewController : UITableViewController <TTCSignInViewDelegate>

@property (strong, nonatomic) NSMutableArray *stopAndRouteArray;    // keeps track of all stops and routes we saved (enabled AND disabled).
@property(strong, nonatomic) NSMutableDictionary *savedPushEntries; // keeps track of only all the enabled stops and routes.

- (IBAction) unwindToSavedTableView:(UIStoryboardSegue *)sender;
- (void) addToStopAndRoute:(TTCStopAndRouteInfo *)stopAndRouteObject;

@end
