//
//  PCFSavedTableViewController.m
//  TTCHackathon
//
//  Created by DX121-XL on 2014-08-06.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <MSSData/MSSData.h>
#import <MSSData/MSSAFNetworking.h>
#import <MSSPush/MSSPushClient.h>
#import <MSSPush/MSSParameters.h>
#import <MSSPush/MSSPush.h>

#import "PCFSavedTableViewController.h"
#import "PCFTitleView.h"
#import "PCFSavedCell.h"
#import "TTCClient.h"
#import "TTCAppDelegate.h"
#import "Settings.h"

@interface PCFSavedTableViewController ()

@property MSSDataObject *savedStopsAndRouteObject;
@property PCFLoadingOverlayView *loadingOverlayView;
@property (strong, nonatomic) IBOutlet UINavigationItem *navItem;

@property BOOL didReachAuthenticateScreen;
@end

@implementation PCFSavedTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.didReachAuthenticateScreen = NO;
    self.tableView.alwaysBounceVertical = YES;
    [self.navigationController.navigationBar setBarTintColor:[UIColor redColor]];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController.navigationBar setTranslucent:YES];
    
    // Custom initialization
    self.navigationItem.titleView = [[PCFTitleView alloc] initWithFrame:CGRectMake(0, 0, 150, 30) andTitle:@"Transit++"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showLoadingScreen)
                                                 name:UIDeviceOrientationDidChangeNotification object:nil];
    
    self.stopAndRouteArray = [[NSMutableArray alloc] init];
    self.savedPushEntries = [[NSMutableDictionary alloc] init];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:NO];
    [self.tableView reloadData];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:NO];
    if (self.didReachAuthenticateScreen == NO) [self performSegueWithIdentifier:@"modalSegueToSignIn" sender:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.stopAndRouteArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"keyValueCell";
    PCFSavedCell *cell = (PCFSavedCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    PCFStopAndRouteInfo* currentItem = [self.stopAndRouteArray objectAtIndex:indexPath.row];
    
    if(currentItem){
        [cell populateViews:currentItem tag:indexPath.row];
        [cell.toggleSwitch addTarget:self action:@selector(switchToggled:) forControlEvents: UIControlEventTouchUpInside];
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    PCFStopAndRouteInfo* currentItem = [self.stopAndRouteArray objectAtIndex:indexPath.row];
    if([currentItem isEqual:nil]) return;
    
    // delete from dictionary
    [self.savedPushEntries removeObjectForKey:currentItem.identifier];
    NSArray *keys=[self.savedPushEntries allKeys];
    [self initializeSDK:keys];
    
    // delete from array
    [self.stopAndRouteArray removeObjectAtIndex:indexPath.row];
    [self pushUpdateToServer];
    
    // need to refresh the table to update the view
    [self.tableView reloadData];
    NSLog(@"Deleted row.");
    self.tableView.alwaysBounceVertical = YES;
}

#pragma mark - segue functions

// When we click the done button in the scheduler view we UNWIND back to here.
- (IBAction)unwindToSavedTableView:(UIStoryboardSegue *)sender
{
    // base case - if nothing exists
    if (self.stopAndRouteArray.count == 0) return;
    
    [self pushUpdateToServer];
    
    // check if the end of our array exists in our dictionary
    PCFStopAndRouteInfo *lastItem = self.stopAndRouteArray.lastObject;
    
    // check if the item exists
    if ([lastItem isEqual:nil]){
        return;
    }
    
    // check if the recently added item is new
    if (![[self.savedPushEntries allKeys] containsObject:lastItem.identifier]) {
        [self.savedPushEntries setValue:@"placeholder" forKey:lastItem.identifier];
        NSLog(@"adding to dictionary: %@", lastItem.identifier);
        NSArray *keys=[self.savedPushEntries allKeys];
        [self initializeSDK:keys];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"modalSegueToSignIn"]) {
        PCFSignInViewController *signInVC = segue.destinationViewController;
        signInVC.delegate = self;
        self.didReachAuthenticateScreen = YES;
    }
}

#pragma mark - Action events

- (void)switchToggled:(UISwitch*)mySwitch
{
    PCFStopAndRouteInfo* currentItem = [self.stopAndRouteArray objectAtIndex:mySwitch.tag];
    
    if ([mySwitch isOn]) {
        currentItem.enabled = YES;
        // adding to the dictionary
        [self.savedPushEntries setObject:@"placeholder" forKey:currentItem.identifier];
    } else {
        currentItem.enabled = NO;
        // have to delete from dictionary and request to not push anymore
        [self.savedPushEntries removeObjectForKey:currentItem.identifier];
    }
    NSArray *keys=[self.savedPushEntries allKeys];
    [self initializeSDK:keys];

    NSLog(@"%d", [self.savedPushEntries count]);
    [self pushUpdateToServer];
}

#pragma mark - Array and dictionary functions

- (void)addToStopAndRoute:(PCFStopAndRouteInfo *)stopAndRouteObject // add to our array
{
    for(PCFStopAndRouteInfo* sar in self.stopAndRouteArray){
        if([sar.stop isEqualToString:stopAndRouteObject.stop] && [sar.time isEqualToString:stopAndRouteObject.time]){
            NSLog(@"Reject to add elem");
            return;
        }
    }
    [self.stopAndRouteArray addObject:stopAndRouteObject];
}

- (void)populateSavedPushEntries // add to our dictionary
{
    for (PCFStopAndRouteInfo* obj in self.stopAndRouteArray) {
        if (obj.enabled == YES) { // If it is enabled
            [self.savedPushEntries setValue:@"placeholder" forKey:obj.identifier]; // only the key is necessary
        }
    }
}

#pragma mark - MSSDataObject server functions

/* When we authenticate we have to fetch our routes and stop from the server */
- (void)fetchRoutesAndStops
{
    [self showLoadingScreen];
    NSLog(@"fetching...");
    [self.savedStopsAndRouteObject objectForKey:@"savedStopsAndRouteObjectID"];
    [self.savedStopsAndRouteObject fetchOnSuccess:^(MSSDataObject *object) {
        if(![object isEqual:nil]){
            NSData* data = [object[@"routesAndStops"] dataUsingEncoding:NSUTF8StringEncoding];
            NSArray* JSONArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            if(![self.stopAndRouteArray isEqual:nil]){
                [self.stopAndRouteArray removeAllObjects];
            }
            
            for(int i = 0; i < JSONArray.count; ++i){
                NSDictionary *dictionary = [self deserializeStringToObject:[JSONArray objectAtIndex:i]];
                PCFStopAndRouteInfo *obj = [[PCFStopAndRouteInfo alloc] init];
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
            
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            [self.loadingOverlayView removeFromSuperview];
            [self populateSavedPushEntries];            
            [self.tableView reloadData];
        }
    } failure:^(NSError *error) {
        NSLog(@"FAILURE");
        [self.loadingOverlayView removeFromSuperview];
    }];
}

/* Everytime we change anything in our ARRAY, we have to push it up to the server */
- (void)pushUpdateToServer {
    NSLog(@"Pushing to server here...");
    NSMutableArray *stopAndRouteListJSON = [[NSMutableArray alloc] init];
    for (int i = 0; i < self.stopAndRouteArray.count; i++) {
        PCFStopAndRouteInfo *stopAndRouteElement = [self.stopAndRouteArray objectAtIndex:i];
        NSString *booleanString = (stopAndRouteElement.enabled) ? @"1" : @"0";
        NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObjectsAndKeys:stopAndRouteElement.route, @"route",
                                        stopAndRouteElement.stop, @"stop", stopAndRouteElement.time, @"time",
                                        stopAndRouteElement.routeTag, @"routeTag", stopAndRouteElement.stopTag, @"stopTag",
                                        stopAndRouteElement.identifier, @"identifier", stopAndRouteElement.timeInUtc, @"timeInUtc",
                                        booleanString, @"enabled", nil];
        
        NSLog(@"Saving item: %@", jsonDictionary);
        NSData *encodedData = [NSJSONSerialization dataWithJSONObject:jsonDictionary
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

/* Registering for notifications with cloud foundry */
- (void)initializeSDK:(NSArray*)keys

{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    MSSParameters *parameters = [[MSSParameters alloc] init];
    [parameters setPushAPIURL:kPushBaseServerUrl];
    [parameters setDevelopmentPushVariantUUID:kPushDevelopmentVariantUuid];
    [parameters setDevelopmentPushVariantSecret:kPushDevelopmentVariantSecret];
    [parameters setProductionPushVariantUUID:kPushProductionVariantUuid];
    [parameters setProductionPushVariantSecret:kPushProductionVariantSecret];
    [parameters setPushDeviceAlias:kPushDeviceAlias];
    [parameters setPushTags:[NSSet setWithArray:keys]];
    [MSSPush setRegistrationParameters:parameters];
    [MSSPush setCompletionBlockWithSuccess:^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
    } failure:^(NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }];
    [MSSPush registerForPushNotifications];
}

/* Serialize a string to JSON object */
- (id)deserializeStringToObject:(NSString *)string
{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    if (!result) {
        NSLog(@"%@", error.description);
    }
    
    return result;
}

#pragma mark - View functions 

- (void)showLoadingScreen
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

- (void)authenticationSuccess {
    NSLog(@"delegate callback");
    self.savedStopsAndRouteObject = [MSSDataObject objectWithClassName:@"notifications"];
    [self.savedStopsAndRouteObject setObjectID:@"savedStopsAndRouteObjectID"];
    [self fetchRoutesAndStops];
}
@end
