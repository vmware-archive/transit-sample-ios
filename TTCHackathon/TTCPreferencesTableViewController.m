//
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <PCFData/PCFData.h>
#import <PCFAuth/PCFAuth.h>
#import "TTCPush.h"
#import "TTCPreferencesTableViewController.h"
#import "TTCLoadingOverlayView.h"
#import "TTCPreferencesTableViewCell.h"
#import "TTCAppDelegate.h"
#import "TTCSettings.h"
#import "TTCLastNotificationView.h"
#import "TTCNotification.h"

#import "RESideMenu.h"

@interface TTCPreferencesTableViewController ()

@property PCFKeyValueObject *savedStopsAndRouteObject;
@property TTCLoadingOverlayView *loadingOverlayView;

@property (strong, nonatomic) NSMutableArray *stopAndRouteArray;
@property UIRefreshControl *refreshControl;

@property (strong) TTCNotificationStore *notificationStore;

@end

@implementation TTCPreferencesTableViewController

static NSString* const PCFCollection = @"notifications";
static NSString* const PCFKey = @"my-notifications";

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.notificationStore = [[TTCNotificationStore alloc] init];
    self.savedStopsAndRouteObject = [PCFKeyValueObject objectWithCollection:PCFCollection key:PCFKey];
    self.stopAndRouteArray = [NSMutableArray array];

    self.tableView.alwaysBounceVertical = YES;
    [self.navigationController.navigationBar setBarTintColor:[UIColor redColor]];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController.navigationBar setTranslucent:YES];

    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
}

- (void) refreshTable
{
    [self fetchRoutesAndStops];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:NO];
    
    [self.tableView reloadData];
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:NO];

    [self fetchRoutesAndStops];
}

#pragma mark - Table view data source

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.stopAndRouteArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 127;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"keyValueCell";
    
    TTCPreferencesTableViewCell *cell = (TTCPreferencesTableViewCell*) [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    TTCStopAndRouteInfo* currentItem = [self.stopAndRouteArray objectAtIndex:indexPath.row];
    
    NSLog(@"item : %@", [currentItem formattedDictionary]);
    
    if (currentItem) {
        [cell populateViews:currentItem tag:indexPath.row];
        [cell.toggleSwitch addTarget:self action:@selector(switchToggled:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return cell;
}

- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return true;
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        TTCStopAndRouteInfo* currentItem = [self.stopAndRouteArray objectAtIndex:indexPath.row];
        if (!currentItem) return;
        
        // delete from array
        [self.stopAndRouteArray removeObjectAtIndex:indexPath.row];
        
        // delete from set
        [TTCPush updateTags:[self enabledTags]];
        
        [self persistDataToRemoteStore];
        
        // need to refresh the table to update the view
        [self.tableView reloadData];

        self.tableView.alwaysBounceVertical = YES;
    }
}

#pragma mark - segue functions

// When we click the done button in the scheduler view we UNWIND back to here.
- (IBAction) unwindToSavedTableView:(UIStoryboardSegue *)sender
{
    [self persistDataToRemoteStore];
    [TTCPush updateTags:[self enabledTags]];
}

#pragma mark - Action events

- (void) switchToggled:(UISwitch*)mySwitch
{
    TTCStopAndRouteInfo* currentItem = [self.stopAndRouteArray objectAtIndex:mySwitch.tag];
    currentItem.enabled = [mySwitch isOn];
    
    [TTCPush updateTags:[self enabledTags]];

    [self persistDataToRemoteStore];
}

- (IBAction)showMenu:(id)sender {
    [self presentLeftMenuViewController:self];
}

#pragma mark - Array and dictionary functions

- (void) addToStopAndRoute:(TTCStopAndRouteInfo *)stopAndRouteObject // add to our array
{
    for (TTCStopAndRouteInfo* stopAndRouteInfo in self.stopAndRouteArray) {
        if([stopAndRouteInfo.stop isEqualToString:stopAndRouteObject.stop] && [stopAndRouteInfo.time isEqualToString:stopAndRouteObject.time]) {
            NSLog(@"Not adding new stop since it's already in the list.");
            return;
        }
    }
    [self.stopAndRouteArray addObject:stopAndRouteObject];
}

#pragma mark - PCFData server functions

/* When we authenticate we have to fetch our routes and stop from the server */
- (void) fetchRoutesAndStops
{    
    NSLog(@"Fetching saved routes and stops...");
    
    [self.savedStopsAndRouteObject getWithCompletionBlock:^(PCFDataResponse *response) {
        
        if (response.error == nil) {
            PCFKeyValue *keyValue = (PCFKeyValue *)response.object;
            
            NSData* data = [keyValue.value dataUsingEncoding:NSUTF8StringEncoding];
            NSArray* jsonArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            if (self.stopAndRouteArray) {
                [self.stopAndRouteArray removeAllObjects];
            }
            
            if (!jsonArray || jsonArray.count <= 0) {
                NSLog(@"Note: no routes and stops saved on server.");
            } else {
            
                for (int i = 0; i < jsonArray.count; ++i) {
                    NSDictionary *dictionary = [jsonArray objectAtIndex:i];
                    TTCStopAndRouteInfo *obj = [[TTCStopAndRouteInfo alloc] initWithDictionary:dictionary];

                    [self.stopAndRouteArray addObject:obj];
                    
                    NSLog(@"Loaded item: %@", dictionary);
                }
            }
            
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            [self.loadingOverlayView removeFromSuperview];
            [self.tableView reloadData];

            // Update the push registration on the server
            [TTCPush updateTags:[self enabledTags]];
            
            if (self.refreshControl && [self.refreshControl isRefreshing]) {
                [self.refreshControl endRefreshing];
            }
            
        } else {
            NSLog(@"Error: could not fetch saved route and stops: %@", response.error);
            [self.loadingOverlayView removeFromSuperview];

            if (self.refreshControl && [self.refreshControl isRefreshing]) {
                [self.refreshControl endRefreshing];
            }
        }
        
    }] ;
}

/* Everytime we change anything in our ARRAY, we have to push it up to the server */
- (void) persistDataToRemoteStore
{
    NSLog(@"Pushing saved stops to server here...");
    NSMutableArray *stopAndRouteListArray = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < self.stopAndRouteArray.count; i++) {
        TTCStopAndRouteInfo *stopAndRouteElement = [self.stopAndRouteArray objectAtIndex:i];
        [stopAndRouteListArray addObject:[stopAndRouteElement formattedDictionary]];
    }
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:stopAndRouteListArray options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSLog(@"Saving routesAndStops: %@", jsonString);
    
    [self.savedStopsAndRouteObject putWithValue:jsonString completionBlock:^(PCFDataResponse *response) {
        if (response.error == nil) {
            NSLog(@"saving to datasync successful");
        } else {
            NSLog(@"saving to datasync failed: %@", response.error);
            NSString *errorMessage = [NSString stringWithFormat:@"Failed to update routes. Try refreshing your data. \n\n[%@]", response.error];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
        }
    }];
}

- (NSSet *) enabledTags {
    NSMutableSet *mutableSet = [NSMutableSet set];
    
    for (TTCStopAndRouteInfo *stopAndRouteInfo in self.stopAndRouteArray) {
        if (stopAndRouteInfo.enabled) {
            [mutableSet addObject:stopAndRouteInfo.tag];
        }
    }
    
    return mutableSet;
}

@end
