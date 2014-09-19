//
//  Copyright (C) 2014 Pivotal Software, Inc. All rights reserved.
//

#import <MSSData/MSSDataSignIn.h>

#import "PCFSignInViewController.h"

static NSString *const kOAuthServerURL = @"http://datasync-authentication.demo.vchs.cfms-apps.com";
static NSString *const kDataServiceURL = @"http://datasync-datastore.demo.vchs.cfms-apps.com";

static NSString *const kClientID = @"cd68e385-c0e8-4740-a563-748e643a2280";
static NSString *const kClientSecret = @"IaioD3Mcj4XU67ySMidiFDNrKwv68RB4Cft2zLrdJHoWcdqjsCSWf1U1EZDR6JKufpNp9NTcBqSxbR6bA95_eg";

static NSString *const textBeforeSignInView = @"This application requires that you authenticate before proceeding.";
static NSString *const textAfterSignInView = @"Waiting to receive access token from identity server.";

@interface PCFSignInViewController () <MSSSignInDelegate>
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (weak, nonatomic) IBOutlet UILabel *signInLabel;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;

@end

@implementation PCFSignInViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.signInButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.signInButton.layer.shadowOffset = CGSizeMake(0.0f,5.0f);
    self.signInButton.layer.masksToBounds = NO;
    self.signInButton.layer.shadowRadius = 5.0f;
    self.signInButton.layer.shadowOpacity = 0.5;
    
    MSSDataSignIn *instance = [MSSDataSignIn sharedInstance];
    instance.clientID = kClientID;
    instance.clientSecret = kClientSecret;
    instance.openIDConnectURL = kOAuthServerURL;
    instance.dataServiceURL = kDataServiceURL;
    instance.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    self.navigationController.navigationBarHidden = YES;
    [self.signInButton setHidden:NO];
    [self.signInLabel setText:textBeforeSignInView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signInClick:(id)sender {
    [[MSSDataSignIn sharedInstance] authenticate];
    [self.signInButton setHidden:YES];
    [self.activityIndicatorView startAnimating];
    [self.signInLabel setText:textAfterSignInView];
}

- (IBAction)signOutClicked:(id)sender {
    [[MSSDataSignIn sharedInstance] signOut];
}

- (void)finishedWithAuth:(MSSAFOAuthCredential *)auth
                   error:(NSError *)error
{
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sign In Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
    } else {
        [self.activityIndicatorView stopAnimating];
        [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
            [self.delegate authenticationSuccess];
        }];
    }
}


@end
