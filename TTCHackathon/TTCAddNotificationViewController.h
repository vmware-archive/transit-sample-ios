//
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PCFData/PCFData.h>
#import "TTCStopAndRouteInfo.h"
#import "TTCRouteViewController.h"
#import "TTCNotificationsTableViewController.h"

@interface TTCAddNotificationViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIDatePicker *timePick;
@property (weak, nonatomic) IBOutlet UILabel *route;
@property (weak, nonatomic) IBOutlet UILabel *stop;
@property (weak, nonatomic) IBOutlet UIView *routeStopContainer;

@property (strong, nonatomic) TTCStopAndRouteInfo *stopAndRouteInfo;

- (IBAction)routeStopContainerPressed:(id)sender;
- (IBAction)unwindToTimeAndStopView:(UIStoryboardSegue *)sender;
@end
