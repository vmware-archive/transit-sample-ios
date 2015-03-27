//
//  TTCAboutViewController.m
//  TTCHackathon
//
//  Created by DX181-XL on 2015-03-27.
//  Copyright (c) 2015 Pivotal. All rights reserved.
//

#import "TTCAboutViewController.h"
#import "RESideMenu.h"

static const NSString *pushSdkVersion = @"PCFPush: 1.0.4";
static const NSString *dataSdkVersion = @"PCFData: 1.1.0";
static const NSString *authSdkVersion = @"PCFAuth: 1.0.0";

@implementation TTCAboutViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor redColor]];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController.navigationBar setTranslucent:YES];
    
    NSString * appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
    NSString *aboutString = [NSString stringWithFormat:@"Application version: %@ \n\nPivotal CF Mobile Services component versions:\n\n  %@ \n  %@ \n  %@", appVersionString, pushSdkVersion, dataSdkVersion, authSdkVersion];
    
    
    /*
     sb.append("Application version: ");
     sb.append(BuildConfig.VERSION_NAME);
     sb.append("\n\nPivotal CF Mobile Services\ncomponent versions:\n\n  ");
     sb.append(BuildConfig.AUTH_SDK_VERSION);
     sb.append("\n  ");
     sb.append(BuildConfig.DATA_SDK_VERSION);
     sb.append("\n  ");
     sb.append(BuildConfig.PUSH_SDK_VERSION);*/
    
    
    [self.aboutTextView setText:aboutString];
    
}

- (IBAction)showSideMenu:(id)sender {
    [self presentLeftMenuViewController:sender];
}

@end