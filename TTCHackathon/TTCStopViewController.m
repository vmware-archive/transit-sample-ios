//
//  TTCStopViewController.m
//  TTCHackathon
//
//  Created by DX181-XL on 2015-03-24.
//  Copyright (c) 2015 Pivotal. All rights reserved.
//

#import <PCFData/PCFData.h>
#import <PCFAuth/PCFAuth.h>
#import <AFNetworking/AFNetworking.h>
#import "TTCStopViewController.h"
#import "TTCSettings.h"
#import "TTCLoadingOverlayView.h"
#import "TTCStopTableViewCell.h"

@interface TTCStopViewController ()

@property NSArray *transitValues;
@property TTCLoadingOverlayView *loadingOverlayView;

@end

@implementation TTCStopViewController

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
    NSString *path = [NSString stringWithFormat:kStopsPath, self.stopAndRouteInfo.routeTag];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        if (sender) {
            [sender endRefreshing];
        }
        
        self.transitValues = responseObject[@"stops"];
        
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
        [self.stopAndRouteInfo setStop:self.transitValues[indexPath.row][@"title"]];
        [self.stopAndRouteInfo setStopTag:value];
        NSLog(@"stop: %@", self.transitValues[indexPath.row][@"title"]);
        NSLog(@"stopTag: %@", value);
        
        [self performSegueWithIdentifier:@"unwindToTimeAndStopView" sender:self];
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
    TTCStopTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.stopLabel.text = self.transitValues[indexPath.row][@"title"];
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
