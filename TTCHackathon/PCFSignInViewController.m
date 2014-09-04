//
//  Copyright (C) 2014 Pivotal Software, Inc. All rights reserved.
//

#import <MSSData/MSSDataSignIn.h>

#import "PCFSignInViewController.h"

static NSString *const kOAuthServerURL = @"http://ident.one.pepsi.cf-app.com";
static NSString *const kDataServiceURL = @"http://data-service.one.pepsi.cf-app.com";

static NSString *const kClientID = @"38797289-4c41-4484-8b1d-e5e9b3322bf9";
static NSString *const kClientSecret = @"JCA_kYEfST2POx41VS-JiiddwsF36Ydz_HzvuvsyNTNekp7qlXcaFH-fZ6Tw3Sf1oCrh0T6QpEOMQsLdjWHyLw";

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

- (void)finishedWithAuth:(AFOAuthCredential *)auth
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
