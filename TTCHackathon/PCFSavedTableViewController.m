//
//  PCFSavedTableViewController.m
//  TTCHackathon
//
//  Created by DX121-XL on 2014-08-06.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import "PCFSavedTableViewController.h"
#import "TTCClient.h"

#import <MSSData/MSSData.h>
#import <MSSData/AFNetworking.h>
#import <MSSPush/MSSPushClient.h>
#import <MSSPush/MSSParameters.h>
#import <MSSPush/MSSPush.h>

@interface PCFSavedTableViewController ()

@property MSSDataObject *savedStopsAndRouteObject;

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
    [self fetchRoutesAndStops];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    PCFStopAndRouteInfo* currentItem = [self.stopAndRouteArray objectAtIndex:indexPath.row];
    
    if(![currentItem isEqual:nil]){
        
        UILabel *routeLabel = (UILabel *)[cell viewWithTag:100];
        [routeLabel setText:currentItem.route];
        
        UILabel *stopLabel = (UILabel *)[cell viewWithTag:101];
        [stopLabel setText:currentItem.stop];
        
        UILabel *timeLabel = (UILabel *)[cell viewWithTag:102];
        [timeLabel setText:currentItem.time];
        
        UISwitch *enabledSwitch = (UISwitch *)[cell viewWithTag:104];
        enabledSwitch.tag = indexPath.row;
        [enabledSwitch setOn: currentItem.enabled];
        [enabledSwitch addTarget:self action:@selector(switchToggled:) forControlEvents: UIControlEventTouchUpInside];
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
    // Perform the real delete action here. Note: you may need to check editing style
    //   if you do not perform delete only.
    [self.stopAndRouteArray removeObjectAtIndex:indexPath.row];
    [self pushUpdateToServer];
    [self.tableView reloadData];
    NSLog(@"Deleted row.");
}

#pragma mark - Navigation
/*
// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)unwindToSavedTableView:(UIStoryboardSegue *)sender
{
    [self pushUpdateToServer];
}

- (void)switchToggled:(UISwitch*)mySwitch
{
    PCFStopAndRouteInfo* currentItem = [self.stopAndRouteArray objectAtIndex:mySwitch.tag];
    
    if ([mySwitch isOn]) {
        currentItem.enabled = YES;
    } else {
        currentItem.enabled = NO;
    }
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
                [obj setTag: dictionary[@"tag"]];
                [obj setTime: dictionary[@"time"]];
                [self.stopAndRouteArray addObject:obj];
            }
            
            [self.tableView reloadData];
        }
    } failure:^(NSError *error) {
        NSLog(@"FAILURE");
    }];
}

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
    NSLog(@"Pushing to server here...");
    NSMutableArray *stopAndRouteListJSON = [[NSMutableArray alloc] init];
    for (int i = 0; i < self.stopAndRouteArray.count; i++) {
        PCFStopAndRouteInfo *stopAndRouteElement = [self.stopAndRouteArray objectAtIndex:i];
        NSString *booleanString = (stopAndRouteElement.enabled) ? @"1" : @"0";
        NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObjectsAndKeys:stopAndRouteElement.route, @"route",
                                        stopAndRouteElement.stop, @"stop", stopAndRouteElement.time, @"time",
                                        stopAndRouteElement.tag, @"tag", booleanString, @"enabled", nil];
        
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
@end
