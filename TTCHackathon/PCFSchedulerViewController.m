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
    
    NSLayoutConstraint *con1 = [NSLayoutConstraint constraintWithItem:self.scheduleDatePicker attribute:NSLayoutAttributeTop relatedBy:0.001f toItem:self.innerScheduleView attribute:NSLayoutAttributeTop multiplier:.01f constant:0];
    [self.scheduleView addConstraints:@[con1]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotateScreen) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    // when view loads check orientation.
    [self didRotateScreen];
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
    self.stop.text = self.stopAndRouteInfo.stopTitle;
    NSString* str = [NSString stringWithFormat:@"%@\n\n%@", self.stopAndRouteInfo.routeTitle, self.stopAndRouteInfo.stopTitle];
    [self.scheduleButton setTitle:str forState:UIControlStateNormal];    
}

#pragma mark - NOTIFICATIONS

- (void)didRotateScreen
{
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];

    if (UIDeviceOrientationIsPortrait(orientation)) {
        [self.scrollView setScrollEnabled:NO];
    } else {
        [self.scrollView setScrollEnabled:YES];
    }
    
}
@end
