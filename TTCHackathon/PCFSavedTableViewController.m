//
//  PCFSavedTableViewController.m
//  TTCHackathon
//
//  Created by DX121-XL on 2014-08-06.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import "PCFSavedTableViewController.h"
#import "TTCClient.h"
#import "PCFSavedCell.h"
#import <MSSData/MSSData.h>
#import <MSSData/AFNetworking.h>
#import <MSSPush/MSSPushClient.h>
#import <MSSPush/MSSParameters.h>
#import <MSSPush/MSSPush.h>

@interface PCFSavedTableViewController ()

@property MSSDataObject *savedStopsAndRouteObject;
@property PCFLoadingOverlayView *loadingOverlayView;
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
    self.savedStopsAndRouteObject = [MSSDataObject objectWithClassName:@"notifications"];
    [self.savedStopsAndRouteObject setObjectID:@"savedStopsAndRouteObjectID"];
    self.stopAndRouteArray = [[NSMutableArray alloc] init];
    self.savedPushEntries = [[NSMutableDictionary alloc] init];
    [self fetchRoutesAndStops];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [self.navigationController.navigationBar setBarTintColor:[UIColor redColor]];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController.navigationBar setTranslucent:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:NO];
    [self.tableView reloadData];
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
    // Return YES - we will be able to delete all rows
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // delete from dictionary first
    PCFStopAndRouteInfo* currentItem = [self.stopAndRouteArray objectAtIndex:indexPath.row];
    [self.savedPushEntries removeObjectForKey:currentItem.identifier];
    NSLog(@"%d", [self.savedPushEntries count]);
    
    // delete from array
    [self.stopAndRouteArray removeObjectAtIndex:indexPath.row];
    [self pushUpdateToServer];
    
    [self.tableView reloadData];
    NSLog(@"Deleted row.");
}

#pragma mark - Navigation
// When we click the done button in the scheduler view.
- (IBAction)unwindToSavedTableView:(UIStoryboardSegue *)sender
{
    [self pushUpdateToServer];
    
    // check if the end of our array exists in our dictionary
    PCFStopAndRouteInfo *lastItem = self.stopAndRouteArray.lastObject;
    
    // check if the recently added item is new
    if (![[self.savedPushEntries allKeys] containsObject:lastItem.identifier]) {
        [self.savedPushEntries setValue:@"placeholder" forKey:lastItem.identifier];
        NSLog(@"adding to dictionary: %@", lastItem.identifier);
        //[self initializeSDK:lastItem.identifier];
    }
}

- (void)switchToggled:(UISwitch*)mySwitch
{
    PCFStopAndRouteInfo* currentItem = [self.stopAndRouteArray objectAtIndex:mySwitch.tag];
    
    if ([mySwitch isOn]) {
        currentItem.enabled = YES;
        // have to add to dictionary and request push
        [self.savedPushEntries setObject:@"placeholder" forKey:currentItem.identifier];
        // [self initializeSDK:currentItem.identifier];
    } else {
        currentItem.enabled = NO;
        // have to delete from dictionary and request to not push anymore
        [self.savedPushEntries removeObjectForKey:currentItem.identifier];
        // request to remove notifications here.
    }
    

    NSLog(@"%d", [self.savedPushEntries count]);
    [self pushUpdateToServer];
}

#pragma mark - adding to the array
- (void)addToStopAndRoute:(PCFStopAndRouteInfo *)stopAndRouteObject
{
    for(PCFStopAndRouteInfo* elem in self.stopAndRouteArray){
        if([elem.stop isEqualToString:stopAndRouteObject.stop] && [elem.time isEqualToString:stopAndRouteObject.time]){
            NSLog(@"Reject to add elem");
            return;
        }
    }
    [self.stopAndRouteArray addObject:stopAndRouteObject];
}

#pragma mark - MSSDataObject functions
- (void)fetchRoutesAndStops
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showLoadingScreen)
                                                 name:UIDeviceOrientationDidChangeNotification object:nil];
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
                [obj setTimeIn24h: dictionary[@"timeIn24h"]];
                [obj setIdentifier:dictionary[@"identifier"]];
                [self.stopAndRouteArray addObject:obj];
            }
            
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            [self.loadingOverlayView removeFromSuperview];
            [self populateSavedPushEntries];
            self.tableView.alwaysBounceVertical = YES;
            [self.tableView reloadData];
        }
    } failure:^(NSError *error) {
        NSLog(@"FAILURE");
    }];
}

#pragma mark - dictionary functions
- (void)populateSavedPushEntries
{
    for (PCFStopAndRouteInfo* obj in self.stopAndRouteArray) {
        if (obj.enabled == YES) { // If it is enabled
           [self.savedPushEntries setValue:@"placeholder" forKey:obj.identifier];
        }
    }
}

#pragma mark - JSON serialization functions
/* Helper function */
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

/* Everytime we change anything in our array, we have to push it up to the server */
- (void)pushUpdateToServer {
    self.tableView.alwaysBounceVertical = NO;
    NSLog(@"Pushing to server here...");
    NSMutableArray *stopAndRouteListJSON = [[NSMutableArray alloc] init];
    for (int i = 0; i < self.stopAndRouteArray.count; i++) {
        PCFStopAndRouteInfo *stopAndRouteElement = [self.stopAndRouteArray objectAtIndex:i];
        NSString *booleanString = (stopAndRouteElement.enabled) ? @"1" : @"0";
        NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObjectsAndKeys:stopAndRouteElement.route, @"route",
                                        stopAndRouteElement.stop, @"stop", stopAndRouteElement.time, @"time",
                                        stopAndRouteElement.routeTag, @"routeTag", stopAndRouteElement.stopTag, @"stopTag",
                                        stopAndRouteElement.identifier, @"identifier", stopAndRouteElement.timeIn24h, @"timeIn24h",
                                        booleanString, @"enabled", nil];
        
        NSData *encodedData = [NSJSONSerialization dataWithJSONObject:jsonDictionary
                                                              options:NSJSONWritingPrettyPrinted error:nil];
        NSString *jsonString =[[NSString alloc] initWithData:encodedData encoding:NSUTF8StringEncoding];
        [stopAndRouteListJSON addObject:jsonString];
    }
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:stopAndRouteListJSON options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    self.savedStopsAndRouteObject[@"routesAndStops"] = jsonString;
    [self.savedStopsAndRouteObject saveOnSuccess:nil failure:nil];
}

#pragma mark - UI changes
- (void)showLoadingScreen
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

#pragma mark - API backend
- (void)initializeSDK:(NSString*)identifier
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    MSSParameters *parameters;
    parameters.developmentPushVariantUUID = @"15a001cd-f200-40a1-b052-763fbeee12a3";
    parameters.developmentPushReleaseSecret = @"84def001-645b-4dfa-af5f-e2659dd27b0f";
    [parameters setTags:@[identifier]];
    [MSSPush setRegistrationParameters:parameters];
    [MSSPush setCompletionBlockWithSuccess:^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
    } failure:^(NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }];
    [MSSPush registerForPushNotifications];
}
@end
