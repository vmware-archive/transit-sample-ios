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

@end

@implementation PCFDataTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.toolbarHidden = NO;
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [self.tableView addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(refreshTable:) forControlEvents:UIControlEventValueChanged];
    
    [self refreshTable:refreshControl];
    
    if (!self.ttcObject) {
        self.ttcObject = [MSSDataObject objectWithClassName:@"TTCObject"];
        [self.ttcObject setObjectID:@"TTCObjectID"];
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
        if (self.ttcObject[@"route"] && value) {
            self.ttcObject[@"stop"] = value;
        
        } else {
            self.ttcObject[@"route"] = value;
        }
    
        if (self.ttcObject[@"route"] && self.ttcObject[@"stop"]) {
            [self initializeSDK];
            [self.ttcObject saveOnSuccess:nil failure:nil];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"keyValueCell" forIndexPath:indexPath];
    UILabel *label = (UILabel *)[cell viewWithTag:1];
//    [label setText:[self transitValueForIndex:indexPath]];
    [label setText:self.transitValues[indexPath.row][@"title"]];
    return cell;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [[segue destinationViewController] setTtcObject:self.ttcObject];
}

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

@end
