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
@property (weak, nonatomic) IBOutlet UIView *innerScheduleView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotateScreen) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    self.stopAndRouteInfo = [[PCFStopAndRouteInfo alloc] init];
    self.scheduleButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.scheduleButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    // need to add a vertical constraint that uses ratios. Could not do it in the interface builder.
    NSLayoutConstraint *verticalConstraintFromTop = [NSLayoutConstraint constraintWithItem:self.scheduleDatePicker
                                                                                 attribute:NSLayoutAttributeTop
                                                                                 relatedBy:0.001f
                                                                                    toItem:self.innerScheduleView
                                                                                 attribute:NSLayoutAttributeTop
                                                                                multiplier:.01f
                                                                                  constant:0];
    [self.scheduleView addConstraints:@[verticalConstraintFromTop]];
    [self modifyScrollViewDependingOnRotation];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    self.navigationController.navigationBarHidden = NO;
    
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self.scrollView setContentSize:CGSizeMake(320, 600)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - click events
- (IBAction)doneButtonPressed:(id)sender {
    [self formatTime];
    [self performSegueWithIdentifier:@"unwindToSavedTableView" sender:self];
}


- (IBAction)routeStopContainerPressed:(id)sender {
    
    [self performSegueWithIdentifier:@"segueToDataTable" sender:self];
}

#pragma mark - segue functions
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[PCFDataTableViewController class]]) {
        [[segue destinationViewController] setStopAndRouteInfo:self.stopAndRouteInfo];
        
    } else if ([segue.destinationViewController isKindOfClass:[PCFSavedTableViewController class]]) {
        if(self.stopAndRouteInfo.route != nil  && self.stopAndRouteInfo.stop != nil){
            self.stopAndRouteInfo.enabled = YES;
            [self.stopAndRouteInfo createIdentifier];
            [[segue destinationViewController] addToStopAndRoute:self.stopAndRouteInfo];
        }
    }
}


- (IBAction)unwindToTimeAndStopView:(UIStoryboardSegue *)sender
{
    self.route.text = self.stopAndRouteInfo.route;
    self.stop.text = self.stopAndRouteInfo.stop;
    NSString* str = [NSString stringWithFormat:@"%@\n\n%@", self.stopAndRouteInfo.route, self.stopAndRouteInfo.stop];
    [self.scheduleButton setTitle:str forState:UIControlStateNormal];    
}

#pragma mark - Other functions
/* Disable scrollview if in portrait mode. Renable it when in landscape mode */
- (void)modifyScrollViewDependingOnRotation
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        [self.scrollView setScrollEnabled:NO];
    } else {
        [self.scrollView setScrollEnabled:YES];
    }
    
}

/* Format the time based on AM/PM and 24h for our stops and routes */
- (void)formatTime
{
    NSDateFormatter *formate = [[NSDateFormatter alloc] init];
    
    //time in 12 hour for displaying on saved table
    [formate setDateFormat:@"hh:mm a"];
    NSTimeZone *zone = [NSTimeZone defaultTimeZone];
    [formate setTimeZone:zone];
    [self.stopAndRouteInfo setTime:[formate stringFromDate:self.timePick.date]];
    
    //time format in 24 hour for identifier
    [formate setDateFormat:@"HHmm"];
    [self.stopAndRouteInfo setTimeIn24h: [formate stringFromDate:self.timePick.date]];
    
    NSLog(@"Time in 24 hr: %@", self.stopAndRouteInfo.timeIn24h);
    NSLog(@"Time in 12 hr: %@",self.stopAndRouteInfo.time);

}
@end
