//
//  Copyright (C) 2014 Pivotal Software, Inc. All rights reserved.
//

#import <MSSData/MSSDataSignIn.h>

#import "PCFSignInViewController.h"

static NSString *const kOAuthServerURL = @"http://ident.one.pepsi.cf-app.com";
static NSString *const kDataServiceURL = @"http://data-service.one.pepsi.cf-app.com";

//static NSString *const kOAuthServerURL = @"http://datasync-authentication.kona.coffee.cfms-apps.com";
//static NSString *const kDataServiceURL = @"http://datasync-datastore.kona.coffee.cfms-apps.com";

static NSString *const textBeforeSignInView = @"This application requires that you authenticate before proceeding.";
static NSString *const textAfterSignInView = @"Waiting to receive access token from identity server.";

//static NSString *const kClientID = @"PushSDKDemoApp";
//static NSString *const kClientSecret = @"secret";

//static NSString *const kClientID = @"6006fa24-2757-481d-b894-f79ed8037e1f";
//static NSString *const kClientSecret = @"C8eJhboAHq_h-oP6po5MoRWQsjWATFDZM8dqbKXBZ8RdeMvv_faF88DVBAp6OsAozU9brBqhYt0RTwpZABYRIQ";

static NSString *const kClientID = @"ios-client";
static NSString *const kClientSecret = @"006d0cea91f01a82cdc57afafbbc0d26c8328964029d5b5eae920e2fdc703169";

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

- (void)finishedWithAuth:(AFOAuthCredential *)auth
                   error:(NSError *)error
{
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sign In Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
    } else {
        [self.activityIndicatorView stopAnimating];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        UIViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"PCFSavedTableViewController"];
        [self.navigationController pushViewController:controller animated:YES];
    }
}


@end
