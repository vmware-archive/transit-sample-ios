//
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MSSData/MSSData.h>
#import <MSSData/MSSAFNetworking.h>
#import <MSSPush/MSSPushClient.h>
#import <MSSPush/MSSParameters.h>
#import <MSSPush/MSSPush.h>
#import "TTCStopAndRouteInfo.h"
#import "TTCDataTableViewController.h"
#import "TTCSavedTableViewController.h"

@interface TTCSchedulerViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIDatePicker *timePick;
@property (weak, nonatomic) IBOutlet UILabel *route;
@property (weak, nonatomic) IBOutlet UILabel *stop;
@property (weak, nonatomic) IBOutlet UIView *routeStopContainer;

@property (strong, nonatomic) TTCStopAndRouteInfo *stopAndRouteInfo;

@property MSSDataObject *ttcObject;

- (IBAction)routeStopContainerPressed:(id)sender;
- (IBAction)unwindToTimeAndStopView:(UIStoryboardSegue *)sender;
@end
