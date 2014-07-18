//
//  PCFSignInViewController.m
//  PCFDataServices Example
//
//  Created by Elliott Garcea on 2014-06-06.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <MSSData/MSSDataSignIn.h>

#import "PCFSignInViewController.h"

static NSString *const kOAuthServerURL = @"http://ident.one.pepsi.cf-app.com";
static NSString *const kDataServiceURL = @"http://data-service.one.pepsi.cf-app.com";

static NSString *const kClientID = @"PushSDKDemoApp";
static NSString *const kClientSecret = @"secret";

@interface PCFSignInViewController () <MSSSignInDelegate>

@property (weak, nonatomic) IBOutlet UIButton *signInButton;

@end

@implementation PCFSignInViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    MSSDataSignIn *instance = [MSSDataSignIn sharedInstance];
    instance.clientID = kClientID;
    instance.clientSecret = kClientSecret;
    instance.openIDConnectURL = kOAuthServerURL;
    instance.dataServiceURL = kDataServiceURL;
    instance.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signInClick:(id)sender {
    [[MSSDataSignIn sharedInstance] authenticate];
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
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        UIViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"PCFDataTableViewController"];
        [self.navigationController pushViewController:controller animated:YES];
    }
}


@end
