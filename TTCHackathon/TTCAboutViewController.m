//
//  TTCAboutViewController.m
//  TTCHackathon
//
//  Created by DX181-XL on 2015-03-27.
//  Copyright (c) 2015 Pivotal. All rights reserved.
//

#import "TTCAboutViewController.h"
#import "RESideMenu.h"
#import "TTCAboutTableViewCell.h"

@interface TTCAboutViewController ()
@property (nonatomic, strong) NSArray *aboutTitlesArray;
@property (nonatomic, strong) NSArray *aboutVersionsArray;
@end

@implementation TTCAboutViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor redColor]];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController.navigationBar setTranslucent:YES];
    
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"Pivotal" ofType:@"plist"];
    NSDictionary* contentArray = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    
    self.aboutTitlesArray = @[@"PCFPush", @"", @"PCFData", @"", @"PCFAuth", @""];
    self.aboutVersionsArray = @[@"1.0.4", contentArray[@"pivotal.push.serviceUrl"], @"1.1.0", contentArray[@"pivotal.auth.authorizeUrl"], @"1.0.0", contentArray[@"pivotal.data.serviceUrl"]];

}

- (IBAction)showSideMenu:(id)sender {
    [self presentLeftMenuViewController:sender];
}

#pragma mark - Table view data source

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else {
        return self.aboutTitlesArray.count;
    }
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TTCAboutTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"aboutCell" forIndexPath:indexPath];
    
    if (indexPath.section == 0) {
        cell.titleLabel.text = @"Application Version";
        cell.descriptionLabel.text = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    } else {
        cell.titleLabel.text = self.aboutTitlesArray[indexPath.row];
        cell.descriptionLabel.text = self.aboutVersionsArray[indexPath.row];
    }
    
    return cell;
}


@end