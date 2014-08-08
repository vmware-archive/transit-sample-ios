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


@interface PCFTimeAndStopViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIDatePicker *timePick;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UILabel *route;
@property (weak, nonatomic) IBOutlet UILabel *stop;

@property (strong, nonatomic) PCFStopAndRouteInfo *stopAndRouteInfo;

@property MSSDataObject *ttcObject;

- (IBAction)nextButtonPressed:(id)sender;
- (IBAction)unwindToTimeAndStopView:(UIStoryboardSegue *)sender;
@end
