//
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import "TTCAddNotificationViewController.h"

@import PCFAppAnalytics;

@interface TTCAddNotificationViewController ()

@property (weak, nonatomic) IBOutlet UIButton *scheduleButton;
@property (strong, nonatomic) IBOutlet UIView *scheduleView;
@property (weak, nonatomic) IBOutlet UIDatePicker *scheduleDatePicker;
@property (weak, nonatomic) IBOutlet UIView *innerScheduleView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;

@end

@implementation TTCAddNotificationViewController

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = NO;
    [self.scrollView setScrollEnabled:NO];
    
    self.stopAndRouteInfo = [[TTCStopAndRouteInfo alloc] init];
    self.scheduleButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.scheduleButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.scheduleButton.layer.borderWidth = 1.0f;
    self.scheduleButton.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.scheduleButton.layer.cornerRadius = 3.0f;

    [[PCFAppAnalytics shared] eventWithName:@"viewAddNotification"];
}

- (void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self.scrollView setContentSize:CGSizeMake(320, 600)];
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - press events

- (IBAction) doneButtonPressed:(id)sender {
    [self formatTime];
    [self performSegueWithIdentifier:@"unwindToSavedTableView" sender:self];
}

- (IBAction) routeStopContainerPressed:(id)sender {
    
    [self performSegueWithIdentifier:@"segueToDataTable" sender:self];
}

#pragma mark - segue functions

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[TTCRouteViewController class]]) {
        [[segue destinationViewController] setStopAndRouteInfo:self.stopAndRouteInfo];
        
    } else if ([segue.destinationViewController isKindOfClass:[TTCPreferencesTableViewController class]]) {
        
        if (self.stopAndRouteInfo.route != nil  && self.stopAndRouteInfo.stop != nil) {
            self.stopAndRouteInfo.enabled = YES;
            [self.stopAndRouteInfo generateTag];
            [[segue destinationViewController] addToStopAndRoute:self.stopAndRouteInfo];
        }
    }
}

- (IBAction) unwindToTimeAndStopView:(UIStoryboardSegue *)sender
{
    [[PCFAppAnalytics shared] eventWithName:@"routeSelected"];
    self.route.text = self.stopAndRouteInfo.route;
    self.stop.text = self.stopAndRouteInfo.stop;
    NSString* str = [NSString stringWithFormat:@"%@\n\n%@", self.stopAndRouteInfo.route, self.stopAndRouteInfo.stop];
    [self.scheduleButton setTitle:str forState:UIControlStateNormal];    
}

#pragma mark - datePicker

/* Format the time based on AM/PM and 24h for our stops and routes */
- (void) formatTime
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    //time in 12 hour for displaying on saved table
    [formatter setDateFormat:@"hh:mm a"];
    NSTimeZone *zone = [NSTimeZone defaultTimeZone];
    [formatter setTimeZone:zone];
    [self.stopAndRouteInfo setTime:[formatter stringFromDate:self.timePick.date]];
    
    NSTimeZone *utcTimeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [formatter setTimeZone:utcTimeZone];
    
    //time format in UTC for identifier
    [formatter setDateFormat:@"HHmm"];
    [self.stopAndRouteInfo setTimeInUtc:[formatter stringFromDate:self.timePick.date]];
    
    NSLog(@"Time in UTC: %@", self.stopAndRouteInfo.timeInUtc);
    NSLog(@"Time in 12 hr: %@",self.stopAndRouteInfo.time);
}

@end
