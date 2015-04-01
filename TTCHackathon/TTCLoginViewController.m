//
//  TTCLoginViewController.m
//  TTCHackathon
//
//  Created by DX181-XL on 2015-03-30.
//  Copyright (c) 2015 Pivotal. All rights reserved.
//

#import "TTCLoginViewController.h"

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

@end
