//
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <MSSData/MSSData.h>
#import <MSSData/MSSAFNetworking.h>
#import "TTCPushRegistrationHelper.h"
#import "TTCNotificationsTableViewController.h"
#import "TTCLoadingOverlayView.h"
#import "TTCNotificationTableViewCell.h"
#import "TTCAppDelegate.h"
#import "TTCSettings.h"
#import "TTCLastNotificationView.h"
#import "TTCUserDefaults.h"

@interface TTCNotificationsTableViewController ()

@property MSSDataObject *savedStopsAndRouteObject;
@property TTCLoadingOverlayView *loadingOverlayView;
@property BOOL didReachAuthenticateScreen;
@property (strong, nonatomic) NSMutableSet *savedPushEntries;    // keeps track of only all the enabled stops and routes.
@property (strong, nonatomic) NSMutableArray *stopAndRouteArray; // keeps track of all stops and routes we saved (enabled AND disabled).
@property TTCLastNotificationView *lastNotificationView;

@end

@implementation TTCNotificationsTableViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    self.didReachAuthenticateScreen = NO;
    self.tableView.alwaysBounceVertical = YES;
    [self.navigationController.navigationBar setBarTintColor:[UIColor redColor]];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController.navigationBar setTranslucent:YES];
    self.navigationItem.title = @"Transit++";
    
    self.stopAndRouteArray = [NSMutableArray array];
    self.savedPushEntries = [NSMutableSet set];
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
    if (self.didReachAuthenticateScreen == NO) {
        [self performSegueWithIdentifier:@"modalSegueToSignIn" sender:self];
    } else {
        [self registerForNotifications];
        [self showLastNotification];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kRemoteNotificationReceived object:nil];
}

#pragma mark - Notification handling

- (void) registerForNotifications {
    void (^block)(NSNotification*) = ^(NSNotification* notification) {
        [self showLastNotification];
        [self.lastNotificationView flash];
    };
    [[NSNotificationCenter defaultCenter] addObserverForName:kRemoteNotificationReceived
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:block];
}

- (void) showLastNotification {
    NSString *lastNotificationText = [TTCUserDefaults getLastNotificationText];
    NSDate *lastNotificationDate = [TTCUserDefaults getLastNotificationTime];
    if (lastNotificationText) {
        
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"TTCLastNotificationView" owner:self options:nil];
        for (id i in objects) {
            if([i isKindOfClass:[TTCLastNotificationView class]]) {
                self.lastNotificationView = (TTCLastNotificationView*) i;
                [self.lastNotificationView showNotification:lastNotificationText date:lastNotificationDate];
                [self.tableView reloadData];
            }
        }
    } else {
        self.lastNotificationView = nil;
        [self.tableView reloadData];
    }
}

#pragma mark - Table view data source

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return self.lastNotificationView != nil ? 1 : 0;
    } else {
        return self.stopAndRouteArray.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 96;
    } else {
        return 127;
    }
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"keyValueCell";
 
    if (indexPath.section == 0) {
        return self.lastNotificationView;
    }
    
    TTCNotificationTableViewCell *cell = (TTCNotificationTableViewCell*) [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    TTCStopAndRouteInfo* currentItem = [self.stopAndRouteArray objectAtIndex:indexPath.row];
    
    if (currentItem) {
        [cell populateViews:currentItem tag:indexPath.row];
        [cell.toggleSwitch addTarget:self action:@selector(switchToggled:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return cell;
}

- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            [TTCUserDefaults setLastNotificationText:nil];
            [TTCUserDefaults setLastNotificationTime:nil];
            [self showLastNotification];
        }
    } else {
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            TTCStopAndRouteInfo* currentItem = [self.stopAndRouteArray objectAtIndex:indexPath.row];
            if (!currentItem) return;
            
            // delete from set
            [self.savedPushEntries removeObject:currentItem.tag];
            [TTCPushRegistrationHelper updateTags:self.savedPushEntries];
            
            // delete from array
            [self.stopAndRouteArray removeObjectAtIndex:indexPath.row];
            [self pushUpdateToServer];
            
            // need to refresh the table to update the view
            [self.tableView reloadData];
            NSLog(@"Deleted row.");
            self.tableView.alwaysBounceVertical = YES;
        }
    }
}

#pragma mark - segue functions

// When we click the done button in the scheduler view we UNWIND back to here.
- (IBAction) unwindToSavedTableView:(UIStoryboardSegue *)sender
{
    // base case - if nothing exists
    if (self.stopAndRouteArray.count == 0) {
        return;
    }
    
    [self pushUpdateToServer];
    
    // check if the end of our array exists in our dictionary
    TTCStopAndRouteInfo *lastItem = self.stopAndRouteArray.lastObject;
    
    // check if the item exists
    if ([lastItem isEqual:nil]) {
        return;
    }
    
    // check if the recently added item is new
    if (![self.savedPushEntries containsObject:lastItem.tag]) {
        [self.savedPushEntries addObject:lastItem.tag];
        NSLog(@"Adding stop to set: %@", lastItem.tag);
        [TTCPushRegistrationHelper updateTags:self.savedPushEntries];
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"modalSegueToSignIn"]) {
        TTCSignInViewController *signInVC = segue.destinationViewController;
        signInVC.delegate = self;
        self.didReachAuthenticateScreen = YES;
    }
}

#pragma mark - Action events

- (void) switchToggled:(UISwitch*)mySwitch
{
    TTCStopAndRouteInfo* currentItem = [self.stopAndRouteArray objectAtIndex:mySwitch.tag];
    
    if ([mySwitch isOn]) {
        currentItem.enabled = YES;
        // adding to the dictionary
        [self.savedPushEntries addObject:currentItem.tag];
    } else {
        currentItem.enabled = NO;
        // have to delete from dictionary and request to not push anymore
        [self.savedPushEntries removeObject:currentItem.tag];
    }
    
    [TTCPushRegistrationHelper updateTags:self.savedPushEntries];

    NSLog(@"Number of enabled stops: %lu", (unsigned long) [self.savedPushEntries count]);
    [self pushUpdateToServer];
}

- (IBAction) logout
{
    self.stopAndRouteArray = [NSMutableArray array];
    self.savedPushEntries = [NSMutableSet set];
    [[MSSDataSignIn sharedInstance] disconnect];
    [TTCPushRegistrationHelper unregister];
    self.didReachAuthenticateScreen = NO;
    [self performSegueWithIdentifier:@"modalSegueToSignIn" sender:self];
}

#pragma mark - Array and dictionary functions

- (void) addToStopAndRoute:(TTCStopAndRouteInfo *)stopAndRouteObject // add to our array
{
    for (TTCStopAndRouteInfo* sar in self.stopAndRouteArray) {
        if([sar.stop isEqualToString:stopAndRouteObject.stop] && [sar.time isEqualToString:stopAndRouteObject.time]) {
            NSLog(@"Not adding new stop since it's already in the list.");
            return;
        }
    }
    [self.stopAndRouteArray addObject:stopAndRouteObject];
}

- (void) populateSavedPushEntries // add to our dictionary if it is enabled
{
    for (TTCStopAndRouteInfo* obj in self.stopAndRouteArray) {
        if (obj.enabled == YES) {
            [self.savedPushEntries addObject:obj.tag];
        }
    }
}

#pragma mark - MSSDataObject server functions

/* When we authenticate we have to fetch our routes and stop from the server */
- (void) fetchRoutesAndStops
{    
    NSLog(@"Fetching saved routes and stops...");
    
    [self.savedStopsAndRouteObject fetchOnSuccess:^(MSSDataObject *fetchedObject) {
        
        if (fetchedObject) {
            
            NSData* data = [fetchedObject[@"items"] dataUsingEncoding:NSUTF8StringEncoding];
            NSArray* jsonArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            if (self.stopAndRouteArray) {
                [self.stopAndRouteArray removeAllObjects];
            }
            
            if (!jsonArray || jsonArray.count <= 0) {
                
                NSLog(@"Note: no routes and stops saved on server.");
                
            } else {
            
                for (int i = 0; i < jsonArray.count; ++i) {
                    
                    NSDictionary *dictionary = [jsonArray objectAtIndex:i];
                    TTCStopAndRouteInfo *obj = [[TTCStopAndRouteInfo alloc] init];
                    [obj setEnabled:[dictionary[@"enabled"] boolValue]];
                    [obj setRoute:dictionary[@"route"]];
                    [obj setStop:dictionary[@"stop"]];
                    [obj setTag: dictionary[@"tag"]];
                    [obj setTime: dictionary[@"time"]];
                    [self.stopAndRouteArray addObject:obj]; // add the entry into the dictionary
                    
                    NSLog(@"Loaded item: %@", dictionary);
                }
            }
            
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            [self.loadingOverlayView removeFromSuperview];
            [self populateSavedPushEntries];            
            [self.tableView reloadData];

            // Update the push registration on the server
            [TTCPushRegistrationHelper updateTags:self.savedPushEntries];
            
        } else {
            NSLog(@"Note: fetched object was nil.");
        }
        
    } failure:^(NSError *error) {
        
        NSLog(@"Error: could not fetch saved route and stops: %@", error);
        [self.loadingOverlayView removeFromSuperview];
    }];
}

/* Serialize a string to JSON object */
- (id) deserializeStringToObject:(NSString *)string
{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    if (!result) {
        NSLog(@"%@", error.description);
    }
    
    return result;
}

/* Everytime we change anything in our ARRAY, we have to push it up to the server */
- (void) pushUpdateToServer
{
    NSLog(@"Pushing saved stops to server here...");
    NSMutableArray *stopAndRouteListJSON = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < self.stopAndRouteArray.count; i++) {
        
        TTCStopAndRouteInfo *stopAndRouteElement = [self.stopAndRouteArray objectAtIndex:i];
        NSString *enabled = (stopAndRouteElement.enabled) ? @"1" : @"0";
        
        NSDictionary *dict = @{
                               @"enabled" :    enabled,
                               @"route" :      stopAndRouteElement.route,
                               @"stop" :       stopAndRouteElement.stop,
                               @"tag" :        stopAndRouteElement.tag,
                               @"time" :       stopAndRouteElement.time
                               };

        NSLog(@"Saving item: %@", dict);
        [stopAndRouteListJSON addObject:dict];
    }
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:stopAndRouteListJSON options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSLog(@"Saving routesAndStops: %@", jsonString);
    
    self.savedStopsAndRouteObject[@"items"] = jsonString;
    [self.savedStopsAndRouteObject saveOnSuccess:^(MSSDataObject *object) {
        NSLog(@"saving to datasync successful: %@", [object allKeys]);
    } failure:^(NSError *error) {
        NSLog(@"saving to datasync failed: %@", error);
    }];
}

#pragma mark - Delegate

- (void) authenticationSuccess
{
    NSLog(@"Authentication succeeded.");
    self.savedStopsAndRouteObject = [MSSDataObject objectWithClassName:@"notifications"];
    [self.savedStopsAndRouteObject setObjectID:@"my-notifications"];
    [self fetchRoutesAndStops];
}

@end
