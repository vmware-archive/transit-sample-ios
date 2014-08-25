//
//  Copyright (C) 2014 Pivotal Software, Inc. All rights reserved.
//

#import "PCFDataTableViewController.h"
#import "TTCClient.h"
#import "PCFTitleView.h"
#import <MSSData/MSSData.h>
#import <MSSData/AFNetworking.h>
#import <MSSPush/MSSPushClient.h>
#import <MSSPush/MSSParameters.h>
#import <MSSPush/MSSPush.h>

static NSString *const kRoutePath = @"http://nextbus.one.pepsi.cf-app.com/ttc/routes";
static NSString *const kStopsPath = @"http://nextbus.one.pepsi.cf-app.com/ttc/routes/%@";

@interface PCFDataTableViewController ()

@property NSArray *transitValues;
@property MSSDataObject *ttcObject;
@property PCFLoadingOverlayView *loadingOverlayView;

@end

@implementation PCFDataTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.alwaysBounceVertical = NO;
    
    self.navigationItem.titleView = [[PCFTitleView alloc] initWithFrame:CGRectMake(0, 0, 150, 30) andTitle:@"Transit++"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotateForOverlay) name:UIDeviceOrientationDidChangeNotification object:nil];
    [self didRotateForOverlay];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [self.tableView addSubview:refreshControl];
    
    [refreshControl addTarget:self action:@selector(refreshTable:) forControlEvents:UIControlEventValueChanged];
    
    [self refreshTable:refreshControl];
    
    if (!self.ttcObject) {
        self.ttcObject = [MSSDataObject objectWithClassName:@"TTCObject"];
        [self.ttcObject setObjectID:@"TTCObjectID"];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.isMovingFromParentViewController && self.ttcObject[@"route"]) {
        [self.ttcObject removeObjectForKey:@"route"];
    }
} 

- (void)refreshTable:(UIRefreshControl *)sender
{
    NSString *path = (self.ttcObject[@"route"] ? [NSString stringWithFormat:kStopsPath, self.ttcObject[@"route"]]  : kRoutePath);
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:path]]
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            if (sender) {
                                                                                                [sender endRefreshing];
                                                                                            }
                                                                                            
                                                                                            if ([JSON isKindOfClass:[NSDictionary class]]) {
                                                                                                JSON = JSON[@"stops"];
                                                                                            }
                                                                                            
                                                                                            self.transitValues = JSON;
                                                                                            
                                                                                            [self.tableView reloadData];
                                                                                            
                                                                                            // UI changes after the JSON string returns.
                                                                                            [[NSNotificationCenter defaultCenter] removeObserver:self];
                                                                                            [self.loadingOverlayView removeFromSuperview];
                                                                                            self.tableView.alwaysBounceVertical = YES;
                                                                                        }
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                            if (sender) {
                                                                                                [sender endRefreshing];
                                                                                            }
                                                                                        }];
    [[TTCClient sharedClient] enqueueHTTPRequestOperation:operation];
    
}

#pragma mark - Table view data source

- (NSString *)transitValueForIndex:(NSIndexPath *)indexPath
{
    return  self.ttcObject[@"route"] ? self.transitValues[indexPath.row][@"stopId"] : self.transitValues[indexPath.row][@"tag"];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *value = [self transitValueForIndex:indexPath];
    
    if (value) {
        if (self.ttcObject[@"route"]) {
            
            // stop and route object setting
            self.ttcObject[@"stop"] = value;
            [self.stopAndRouteInfo setStop:self.transitValues[indexPath.row][@"title"]];
            [self.stopAndRouteInfo setStopTag:value];
            NSLog(@"stop: %@", self.transitValues[indexPath.row][@"title"]);
            NSLog(@"stopTag: %@", value);
           
        } else {
            self.ttcObject[@"route"] = value;
            // stop and route object setting
            [self.stopAndRouteInfo setRoute:self.transitValues[indexPath.row][@"title"]];
            [self.stopAndRouteInfo setRouteTag:value];
            NSLog(@"route: %@", self.transitValues[indexPath.row][@"title"]);
            NSLog(@"routeTag: %@", value);
        }
        
        if (self.ttcObject[@"route"] && self.ttcObject[@"stop"]) {
            [self performSegueWithIdentifier:@"unwindToTimeAndStopView" sender:self];
        }        
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.transitValues.count;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.row > 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = self.transitValues[indexPath.row][@"title"];
    return cell;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [[segue destinationViewController] setTtcObject:self.ttcObject];
    [[segue destinationViewController] setStopAndRouteInfo:self.stopAndRouteInfo];
}


#pragma mark - Notifications

- (void)didRotateForOverlay
{
    CGFloat frameWidth = self.view.frame.size.width;
    CGFloat frameHeight = self.view.frame.size.height;
    
    if (self.loadingOverlayView != nil) {
        [self.loadingOverlayView removeFromSuperview];
        self.loadingOverlayView = [[PCFLoadingOverlayView alloc] initWithFrame:CGRectMake(0, 0, frameWidth, frameHeight)];
    } else {
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        
        if (orientation == UIInterfaceOrientationPortrait) {
            self.loadingOverlayView = [[PCFLoadingOverlayView alloc] initWithFrame:CGRectMake(0, 0, frameWidth, frameHeight)];
        } else if (orientation == UIInterfaceOrientationLandscapeLeft | orientation == UIInterfaceOrientationLandscapeRight){ // very wierd case where it doesn't take the correct values for landscape mode.
            self.loadingOverlayView = [[PCFLoadingOverlayView alloc] initWithFrame:CGRectMake(0, 0, frameHeight, frameWidth)];
        }
    }
    [self.tableView addSubview:self.loadingOverlayView];
}
@end
