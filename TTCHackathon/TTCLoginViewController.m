//
//  TTCLoginViewController.m
//  TTCHackathon
//
//  Created by DX181-XL on 2015-03-30.
//  Copyright (c) 2015 Pivotal. All rights reserved.
//

#import "TTCLoginViewController.h"

@import PCFAppAnalytics;

@implementation TTCLoginViewController

- (instancetype)init {
    return [super initWithNibName:@"TTCLoginViewController" bundle:[NSBundle mainBundle]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.usernameField) {
        [self.passwordField becomeFirstResponder];
    } else if (textField == self.passwordField) {
        [self grantTypePassword:textField];
    }
    return YES;
}


- (IBAction)grantTypePassword:(id)sender {
    // Once we have segmentation support I would report events like this
    // [[PCFAppAnalytics shared] eventWithName:@"loginAttempt" properties:@{ @"grantType" : @"password" }];
    [[PCFAppAnalytics shared] eventWithName:@"loginPassword"];
    [super grantTypePassword:sender];
}

- (IBAction)grantTypeAuthCode:(id)sender {
    // Once we have segmentation support I would report events like this
    // [[PCFAppAnalytics shared] eventWithName:@"loginAttempt" properties:@{ @"grantType" : @"authcode" }];
    [[PCFAppAnalytics shared] eventWithName:@"loginAuthCode"];
    [super grantTypeAuthCode:sender];
}

@end
