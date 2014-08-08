//
//  PCFTimeAndStopViewController.m
//  TTCHackathon
//
//  Created by DX121-XL on 2014-08-06.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import "PCFTimeAndStopViewController.h"

@interface PCFTimeAndStopViewController ()
@end

@implementation PCFTimeAndStopViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.stopAndRouteInfo = [[PCFStopAndRouteInfo alloc] init];
    
	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    self.navigationController.navigationBarHidden = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)nextButtonPressed:(id)sender {
    NSDateFormatter *formate = [[NSDateFormatter alloc] init];
    [formate setDateFormat:@"HH:mm"];
    NSTimeZone *zone = [NSTimeZone defaultTimeZone];
    [formate setTimeZone:zone];
    NSString* dateStr = [formate stringFromDate:self.timePick.date];
    NSLog(@"Time - %@",dateStr);
    [self performSegueWithIdentifier:@"segueToDataTable" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [[segue destinationViewController] setStopAndRouteInfo:self.stopAndRouteInfo];
}


- (IBAction)unwindToTimeAndStopView:(UIStoryboardSegue *)sender
{
    self.route.text = self.stopAndRouteInfo.routeTitle;
    self.stop.text = self.stopAndRouteInfo.stopID;
    NSLog(@"%@", self.stopAndRouteInfo.routeTitle);
    NSLog(@"%@", self.stopAndRouteInfo.routeTag);
    NSLog(@"%@", self.stopAndRouteInfo.stopID);
    
}
@end
