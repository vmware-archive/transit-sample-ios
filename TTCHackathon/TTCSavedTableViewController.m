//
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <MSSData/MSSData.h>
#import <MSSData/MSSAFNetworking.h>
#import "TTCPushRegistrationHelper.h"
#import "TTCSavedTableViewController.h"
#import "TTCLoadingOverlayView.h"
#import "TTCSavedCell.h"
#import "TTCAppDelegate.h"
#import "TTCSettings.h"

@interface TTCSavedTableViewController ()

@property MSSDataObject *savedStopsAndRouteObject;
@property TTCLoadingOverlayView *loadingOverlayView;
@property BOOL didReachAuthenticateScreen;
@property (strong, nonatomic) NSMutableSet *savedPushEntries;    // keeps track of only all the enabled stops and routes.
@property (strong, nonatomic) NSMutableArray *stopAndRouteArray; // keeps track of all stops and routes we saved (enabled AND disabled).

@end

@implementation TTCSavedTableViewController

- (id) initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showLoadingScreen)
                                                 name:UIDeviceOrientationDidChangeNotification object:nil];
    
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
    if (self.didReachAuthenticateScreen == NO) [self performSegueWithIdentifier:@"modalSegueToSignIn" sender:self];
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.stopAndRouteArray.count;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"keyValueCell";
    
    TTCSavedCell *cell = (TTCSavedCell*) [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
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
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        TTCStopAndRouteInfo* currentItem = [self.stopAndRouteArray objectAtIndex:indexPath.row];
        if (!currentItem) return;
        
        // delete from set
        [self.savedPushEntries removeObject:currentItem.identifier];
        [TTCPushRegistrationHelper initialize:self.savedPushEntries];
        
        // delete from array
        [self.stopAndRouteArray removeObjectAtIndex:indexPath.row];
        [self pushUpdateToServer];
        
        // need to refresh the table to update the view
        [self.tableView reloadData];
        NSLog(@"Deleted row.");
        self.tableView.alwaysBounceVertical = YES;
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
    if (![self.savedPushEntries containsObject:lastItem.identifier]) {
        [self.savedPushEntries addObject:lastItem.identifier];
        NSLog(@"Adding stop to set: %@", lastItem.identifier);
        [TTCPushRegistrationHelper initialize:self.savedPushEntries];
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
        [self.savedPushEntries addObject:currentItem.identifier];
    } else {
        currentItem.enabled = NO;
        // have to delete from dictionary and request to not push anymore
        [self.savedPushEntries removeObject:currentItem.identifier];
    }
    
    [TTCPushRegistrationHelper initialize:self.savedPushEntries];

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
            [self.savedPushEntries addObject:obj.identifier];
        }
    }
}

#pragma mark - MSSDataObject server functions

/* When we authenticate we have to fetch our routes and stop from the server */
- (void) fetchRoutesAndStops
{
    [self showLoadingScreen];
    
    NSLog(@"Fetching saved routes and stops...");
    
    [self.savedStopsAndRouteObject fetchOnSuccess:^(MSSDataObject *fetchedObject) {
        
        if (fetchedObject) {
            
            NSData* data = [fetchedObject[@"routesAndStops"] dataUsingEncoding:NSUTF8StringEncoding];
            NSArray* jsonArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            if (self.stopAndRouteArray) {
                [self.stopAndRouteArray removeAllObjects];
            }
            
            if (!jsonArray || jsonArray.count <= 0) {
                
                NSLog(@"Note: no routes and stops saved on server.");
                
            } else {
            
                for (int i = 0; i < jsonArray.count; ++i) {
                    
                    NSDictionary *dictionary = [self deserializeStringToObject:[jsonArray objectAtIndex:i]];
                    TTCStopAndRouteInfo *obj = [[TTCStopAndRouteInfo alloc] init];
                    [obj setEnabled:[dictionary[@"enabled"] boolValue]];
                    [obj setRoute:dictionary[@"route"]];
                    [obj setStop:dictionary[@"stop"]];
                    [obj setRouteTag: dictionary[@"routeTag"]];
                    [obj setStopTag: dictionary[@"stopTag"]];
                    [obj setTime: dictionary[@"time"]];
                    [obj setTimeInUtc: dictionary[@"timeInUtc"]];
                    [obj setIdentifier:dictionary[@"identifier"]];
                    [self.stopAndRouteArray addObject:obj]; // add the entry into the dictionary
                    
                    NSLog(@"Loaded item: %@", dictionary);
                }
            }
            
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            [self.loadingOverlayView removeFromSuperview];
            [self populateSavedPushEntries];            
            [self.tableView reloadData];

            // Update the push registration on the server
            [TTCPushRegistrationHelper initialize:self.savedPushEntries];
            
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
                               @"route" :      stopAndRouteElement.route,
                               @"stop" :       stopAndRouteElement.stop,
                               @"time" :       stopAndRouteElement.time,
                               @"routeTag" :   stopAndRouteElement.routeTag,
                               @"stopTag" :    stopAndRouteElement.stopTag,
                               @"identifier" : stopAndRouteElement.identifier,
                               @"timeInUtc" :  stopAndRouteElement.timeInUtc,
                               @"enabled" :    enabled
                               };

        NSLog(@"Saving item: %@", dict);
        NSData *encodedData = [NSJSONSerialization dataWithJSONObject:dict
                                                              options:0
                                                                error:nil];
        NSString *jsonString =[[NSString alloc] initWithData:encodedData encoding:NSUTF8StringEncoding];
        [stopAndRouteListJSON addObject:jsonString];
    }
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:stopAndRouteListJSON options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSLog(@"Saving routesAndStops: %@", jsonString);
    
    self.savedStopsAndRouteObject[@"routesAndStops"] = jsonString;
    [self.savedStopsAndRouteObject saveOnSuccess:nil failure:nil];
}

#pragma mark - View functions 

// TODO - find out why this method is commented out

- (void) showLoadingScreen
{
//    CGFloat frameWidth = self.view.frame.size.width;
//    CGFloat frameHeight = self.view.frame.size.height;
//    
//    if (self.loadingOverlayView != nil) {
//        [self.loadingOverlayView removeFromSuperview];
//        self.loadingOverlayView = [[PCFLoadingOverlayView alloc] initWithFrame:CGRectMake(0, 0, frameWidth, frameHeight)];
//        
//    } else {
//        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
//        
//        if (orientation == UIInterfaceOrientationPortrait) {
//            self.loadingOverlayView = [[PCFLoadingOverlayView alloc] initWithFrame:CGRectMake(0, 0, frameWidth, frameHeight)];
//            
//        } else if (orientation == UIInterfaceOrientationLandscapeLeft | orientation == UIInterfaceOrientationLandscapeRight){ // very wierd case where it doesn't take the correct values for landscape mode.
//            self.loadingOverlayView = [[PCFLoadingOverlayView alloc] initWithFrame:CGRectMake(0, 0, frameHeight, frameWidth)];
//        }
//    }
//    [self.tableView addSubview:self.loadingOverlayView];
}

#pragma mark - Delegate

- (void) authenticationSuccess
{
    NSLog(@"Authentication succeeded.");
    self.savedStopsAndRouteObject = [MSSDataObject objectWithClassName:@"notifications"];
    [self.savedStopsAndRouteObject setObjectID:@"savedStopsAndRouteObjectID"];
    [self fetchRoutesAndStops];
}

@end
