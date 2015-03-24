//
//  TTCStopViewController.h
//  TTCHackathon
//
//  Created by DX181-XL on 2015-03-24.
//  Copyright (c) 2015 Pivotal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTCStopAndRouteInfo.h"

@interface TTCStopViewController : UITableViewController

@property (strong, nonatomic) TTCStopAndRouteInfo *stopAndRouteInfo;

@end
