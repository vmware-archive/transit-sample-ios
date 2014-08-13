//
//  PCFSavedTableViewController.h
//  TTCHackathon
//
//  Created by DX121-XL on 2014-08-06.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PCFStopAndRouteInfo.h"
#import "PCFLoadingOverlayView.h"

@interface PCFSavedTableViewController : UITableViewController

@property (strong, nonatomic) NSMutableArray *stopAndRouteArray;
- (IBAction)unwindToSavedTableView:(UIStoryboardSegue *)sender;
- (void)addToStopAndRoute:(PCFStopAndRouteInfo *)stopAndRouteObject;
@end
