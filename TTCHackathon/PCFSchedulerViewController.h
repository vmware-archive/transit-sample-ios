//
//  PCFTimeAndStopViewController.h
//  TTCHackathon
//
//  Created by DX121-XL on 2014-08-06.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MSSData/MSSData.h>
#import <MSSData/AFNetworking.h>
#import <MSSPush/MSSPushClient.h>
#import <MSSPush/MSSParameters.h>
#import <MSSPush/MSSPush.h>
#import "PCFStopAndRouteInfo.h"
#import "PCFDataTableViewController.h"
#import "PCFSavedTableViewController.h"

@interface PCFSchedulerViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIDatePicker *timePick;
@property (weak, nonatomic) IBOutlet UILabel *route;
@property (weak, nonatomic) IBOutlet UILabel *stop;
@property (weak, nonatomic) IBOutlet UIView *routeStopContainer;

@property (strong, nonatomic) PCFStopAndRouteInfo *stopAndRouteInfo;

@property MSSDataObject *ttcObject;

- (IBAction)routeStopContainerPressed:(id)sender;
- (IBAction)unwindToTimeAndStopView:(UIStoryboardSegue *)sender;
- (void)didRotateScreen;
@end
