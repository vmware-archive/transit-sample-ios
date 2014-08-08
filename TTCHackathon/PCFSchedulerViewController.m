//
//  PCFTimeAndStopViewController.m
//  TTCHackathon
//
//  Created by DX121-XL on 2014-08-06.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import "PCFSchedulerViewController.h"

@interface PCFSchedulerViewController ()
@property (weak, nonatomic) IBOutlet UIButton *scheduleButton;
@property (strong, nonatomic) IBOutlet UIView *scheduleView;
@property (weak, nonatomic) IBOutlet UIDatePicker *scheduleDatePicker;
@end

@implementation PCFSchedulerViewController

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
    self.scheduleButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    // you probably want to center it
    self.scheduleButton.titleLabel.textAlignment = NSTextAlignmentCenter; // if you want to
	// Do any additional setup after loading the view.

    NSLayoutConstraint *con1 = [NSLayoutConstraint constraintWithItem:self.scheduleDatePicker attribute:NSLayoutAttributeHeight relatedBy:0 toItem:self.scheduleView attribute:NSLayoutAttributeHeight multiplier:0.25f constant:0];
    [self.scheduleView addConstraints:@[con1]];
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

- (IBAction)routeStopContainerPressed:(id)sender {
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
    NSString* str = [NSString stringWithFormat:@"%@\n%@", self.stopAndRouteInfo.routeTitle, self.stopAndRouteInfo.stopID];
    NSLog(@"%@", str);
    [self.scheduleButton setTitle:str forState:UIControlStateNormal];
    
    //[self.scheduleButton setTitle: @"Line1\nLine2" forState: UIControlStateNormal];
    NSLog(@"%@", self.stopAndRouteInfo.routeTitle);
    NSLog(@"%@", self.stopAndRouteInfo.routeTag);
    NSLog(@"%@", self.stopAndRouteInfo.stopID);
    
}

@end
