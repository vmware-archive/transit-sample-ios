//
//  Copyright (C) 2014 Pivotal Software, Inc. All rights reserved.
//

#import "PCFDataTableViewController.h"
#import "TTCClient.h"

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
//@property UIActivityIndicatorView *activityIndicatorView;
//@property UIView *loadingOverlayView;
@property PCFLoadingOverlayView *loadingOverlayView;

@end

@implementation PCFDataTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.alwaysBounceVertical = NO;
    
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
           
        } else {
            self.ttcObject[@"route"] = value;
            
            // stop and route object setting
            [self.stopAndRouteInfo setRoute:self.transitValues[indexPath.row][@"title"]];
            [self.stopAndRouteInfo setTag:value];
        }
        
        if (self.ttcObject[@"route"] && self.ttcObject[@"stop"]) {
            [self initializeSDK];
            [self.ttcObject saveOnSuccess:nil failure:nil];
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


#pragma mark - API backend
- (void)initializeSDK
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    MSSParameters *parameters;
    parameters = [MSSParameters defaultParameters];
    [parameters setTags:@[[NSString stringWithFormat:@"14_%@_%@", self.ttcObject[@"route"], self.ttcObject[@"stop"]]]];
    
    [MSSPush setRegistrationParameters:parameters];
    [MSSPush setCompletionBlockWithSuccess:^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
    } failure:^(NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }];
    [MSSPush registerForPushNotifications];
}

#pragma mark - Notifications

- (void)didRotateForOverlay
{
    if (self.loadingOverlayView != nil) {
        [self.loadingOverlayView removeFromSuperview];
        self.loadingOverlayView = [[PCFLoadingOverlayView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    } else {
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        
        if (orientation == UIInterfaceOrientationPortrait) {
            self.loadingOverlayView = [[PCFLoadingOverlayView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
            NSLog(@"isPortrait - Saved");
        } else if (orientation == UIInterfaceOrientationLandscapeLeft | orientation == UIInterfaceOrientationLandscapeRight){ // very wierd case where it doesn't take the correct values for landscape mode.
            self.loadingOverlayView = [[PCFLoadingOverlayView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.height, self.view.frame.size.width)];
            NSLog(@"isLandscape - Saved");
        }
    }
    [self.tableView addSubview:self.loadingOverlayView];
}

@end
