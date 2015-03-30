//
//  Copyright (C) 2014 Pivotal Software, Inc. All rights reserved.
//

#import <PCFData/PCFData.h>
#import <PCFAuth/PCFAuth.h>
#import <AFNetworking/AFNetworking.h>
#import "TTCRouteViewController.h"
#import "TTCSettings.h"
#import "TTCLoadingOverlayView.h"
#import "TTCRouteTableViewCell.h"
#import "TTCRouteUtil.h"

static NSString *const kRoute = @"route";

@interface TTCRouteViewController ()

@property NSArray *transitValues;
@property TTCLoadingOverlayView *loadingOverlayView;

@end

@implementation TTCRouteViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.alwaysBounceVertical = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotateForOverlay) name:UIDeviceOrientationDidChangeNotification object:nil];
    [self didRotateForOverlay];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [self.tableView addSubview:refreshControl];
    
    [refreshControl addTarget:self action:@selector(refreshTable:) forControlEvents:UIControlEventValueChanged];
    
    [self refreshTable:refreshControl];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    self.navigationController.navigationBarHidden = NO;
}

- (void) refreshTable:(UIRefreshControl *)sender
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:kRoutePath parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        if (sender) {
            [sender endRefreshing];
        }
        
        self.transitValues = responseObject;
        
        [self.tableView reloadData];
        
        // UI changes after the JSON string returns.
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self.loadingOverlayView removeFromSuperview];
        self.tableView.alwaysBounceVertical = YES;
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
        if (sender) {
            [sender endRefreshing];
        }

    }];
    
}

#pragma mark - Table view data source

- (NSString*) transitValueForIndex:(NSIndexPath *)indexPath
{
    return self.transitValues[indexPath.row][@"tag"];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *value = [self transitValueForIndex:indexPath];
    
    if (value) {
        [self.stopAndRouteInfo setRoute:self.transitValues[indexPath.row][@"title"]];
        [self.stopAndRouteInfo setRouteTag:value];
        NSLog(@"route: %@", self.transitValues[indexPath.row][@"title"]);
        NSLog(@"routeTag: %@", value);
    }
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.transitValues.count;
}

- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.row > 0;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TTCRouteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];

    TTCRouteTitleModel* routeTitleModel = [TTCRouteUtil routeTitleModelFromRouteTitle:self.transitValues[indexPath.row][@"title"]];
    
    cell.circleView.text = routeTitleModel.routeNumber;
    if (indexPath.row % 2 == 0) {
        cell.circleView.backgroundColor = [UIColor redColor];
    } else {
        cell.circleView.backgroundColor = [UIColor colorWithRed:0 green:152/255.0 blue:240/255.0 alpha:1];
    }
    cell.routeNameLabel.text = routeTitleModel.routeName;
    
    return cell;
}

#pragma mark - Navigation

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [[segue destinationViewController] setStopAndRouteInfo:self.stopAndRouteInfo];
}


#pragma mark - Notifications

- (void) didRotateForOverlay
{
    CGFloat frameWidth = self.view.frame.size.width;
    CGFloat frameHeight = self.view.frame.size.height;
    
    if (self.loadingOverlayView != nil) {
        [self.loadingOverlayView removeFromSuperview];
        self.loadingOverlayView = [[TTCLoadingOverlayView alloc] initWithFrame:CGRectMake(0, 0, frameWidth, frameHeight)];
    } else {
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        
        if (orientation == UIInterfaceOrientationPortrait) {
            self.loadingOverlayView = [[TTCLoadingOverlayView alloc] initWithFrame:CGRectMake(0, 0, frameWidth, frameHeight)];
        } else if (orientation == UIInterfaceOrientationLandscapeLeft | orientation == UIInterfaceOrientationLandscapeRight){ // very wierd case where it doesn't take the correct values for landscape mode.
            self.loadingOverlayView = [[TTCLoadingOverlayView alloc] initWithFrame:CGRectMake(0, 0, frameHeight, frameWidth)];
        }
    }
    [self.tableView addSubview:self.loadingOverlayView];
}

@end
