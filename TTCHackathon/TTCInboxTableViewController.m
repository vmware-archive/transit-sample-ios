//
//  TTCNotificationStoreTableViewController.m
//  TTCHackathon
//
//  Created by DX122-XL on 2015-04-28.
//  Copyright (c) 2015 Pivotal. All rights reserved.
//

#import "TTCInboxTableViewController.h"
#import "TTCInboxItemViewController.h"
#import "TTCInboxTableViewCell.h"
#import "TTCNotificationStore.h"
#import "TTCNotification.h"
#import "RESideMenu.h"

@interface TTCInboxTableViewController ()

@property (strong) TTCNotificationStore *notificationStore;
@property (strong) NSArray *notifications;

@end

@implementation TTCInboxTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor redColor]];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController.navigationBar setTranslucent:YES];
    
    self.notificationStore = [[TTCNotificationStore alloc] init];
    self.notifications = self.notificationStore.notifications;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults addObserver:self forKeyPath:TTCNotificationsKey options:NSKeyValueObservingOptionNew context:0];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObserver:self forKeyPath:TTCNotificationsKey];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([object isKindOfClass:[NSUserDefaults class]]) {
        if ([keyPath isEqualToString:TTCNotificationsKey]) {
            
            self.notifications = self.notificationStore.notifications;
            
            [self.tableView reloadData];
        }
    }
}

- (IBAction)showSideMenu:(id)sender {
    [self presentLeftMenuViewController:sender];
}

- (IBAction)clearNotifications:(id)sender {
    [self.notificationStore clearNotifications];
}

#pragma mark - Seque 

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    TTCInboxItemViewController *destViewController = segue.destinationViewController;
    destViewController.notification = [self notificationForIndexPath:indexPath];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.notifications.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TTCInboxTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"inboxCell"];

    TTCNotification *notification = [self notificationForIndexPath:indexPath];
    
    cell.messageLabel.text = notification.message;
    cell.timestampLabel.text = notification.formattedDate;

    return cell;
}

#pragma mark - util 

- (TTCNotification *)notificationForIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dictionary = [self.notifications objectAtIndex:indexPath.row];
    TTCNotification *notification = [[TTCNotification alloc] initWithDictionary:dictionary];
    
    return notification;
}
@end
