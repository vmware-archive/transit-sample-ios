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
#import "PCFSignInViewController.h"

@interface PCFSavedTableViewController : UITableViewController <signInViewDelegate>

@property (strong, nonatomic) NSMutableArray *stopAndRouteArray;    // keeps track of all stops and routes we saved (enabled AND disabled).
@property(strong, nonatomic) NSMutableDictionary *savedPushEntries; // keeps track of only all the enabled stops and routes.

- (IBAction)unwindToSavedTableView:(UIStoryboardSegue *)sender;
- (void)addToStopAndRoute:(PCFStopAndRouteInfo *)stopAndRouteObject;
- (void)postAuthenticationLoad;
@end
