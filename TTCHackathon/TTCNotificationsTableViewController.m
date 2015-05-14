//
//  TTCNotificationStoreTableViewController.m
//  TTCHackathon
//
//  Created by DX122-XL on 2015-04-28.
//  Copyright (c) 2015 Pivotal. All rights reserved.
//

#import "TTCNotificationsTableViewController.h"
#import "TTCNotificationViewController.h"
#import "TTCNotificationsTableViewCell.h"
#import "TTCNotificationStore.h"
#import "TTCNotification.h"
#import "RESideMenu.h"

@interface TTCNotificationsTableViewController ()

@property (strong) TTCNotificationStore *notificationStore;
@property (strong) NSArray *notifications;
@property UIRefreshControl *refreshControl;

@end

@implementation TTCNotificationsTableViewController

NSString * const TTCMessagesKey = @"notifications:messages";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.notificationStore = [[TTCNotificationStore alloc] init];
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor redColor]];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController.navigationBar setTranslucent:YES];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchNotifications) forControlEvents:UIControlEventValueChanged];
    
    [self.tableView addSubview:self.refreshControl];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self fetchNotifications];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults addObserver:self forKeyPath:TTCMessagesKey options:NSKeyValueObservingOptionNew context:0];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObserver:self forKeyPath:TTCMessagesKey];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([object isKindOfClass:[NSUserDefaults class]]) {
        if ([keyPath isEqualToString:TTCMessagesKey]) {
            [self fetchNotifications];
        }
    }
}

- (IBAction)showSideMenu:(id)sender {
    [self presentLeftMenuViewController:sender];
}

- (IBAction)clearNotifications:(id)sender {
    [self clearNotifications];
}

#pragma mark - Notifications

- (void)fetchNotifications {
    [self.notificationStore fetchNotificationsWithBlock:^(NSArray *messages, NSError *error) {
        [self.refreshControl endRefreshing];
        
        if (error) {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"%@", error] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            return;
        }
        
        self.notifications = messages;
        [self.tableView reloadData];
    }];
}

- (void)updateNotifications:(NSArray *)notifications {
    [self.notificationStore updateNotifications:notifications withBlock:^(NSArray *messages, NSError *error) {
        [self.refreshControl endRefreshing];
        
        if (error) {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"%@", error] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            return;
        }
        
        self.notifications = messages;
        [self.tableView reloadData];
    }];
}

- (void)clearNotifications {
    [self.notificationStore clearNotificationsWithBlock:^(NSError *error) {
        
        if (error) {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"%@", error] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            return;
        }
        
        self.notifications = [NSArray new];
        [self.tableView reloadData];
    }];
}

- (void)markNotificationAsRead:(NSIndexPath *)indexPath {
    NSDictionary *notification = [self.notifications objectAtIndex:indexPath.row];
    
    if (![[notification objectForKey:@"read"] boolValue]) {
        
        NSMutableDictionary *dictionary = [notification mutableCopy];
        [dictionary setObject:[NSNumber numberWithBool:true] forKey:@"read"];
        
        NSMutableArray *array = [self.notifications mutableCopy];
        [array replaceObjectAtIndex:indexPath.row withObject:dictionary];
        
        [self updateNotifications:array];
    }
}

#pragma mark - Tableview

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.notifications.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TTCNotificationsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"inboxCell"];
    TTCNotification *notification = [self notificationForIndexPath:indexPath];
    
    cell.messageLabel.text = notification.message;
    cell.timestampLabel.text = notification.formattedDate;
    
    if (!notification.read) {
        cell.messageLabel.font = [UIFont boldSystemFontOfSize:16.0f];
        cell.backgroundColor = [UIColor whiteColor];
    } else {
        cell.messageLabel.font = [UIFont systemFontOfSize:16.0f];
        cell.backgroundColor = [UIColor clearColor];
    }

    return cell;
}

#pragma mark - Seque


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    TTCNotificationViewController *destViewController = segue.destinationViewController;
    destViewController.notification = [self notificationForIndexPath:indexPath];
    
    [self markNotificationAsRead:indexPath];
}

#pragma mark - Util

- (TTCNotification *)notificationForIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dictionary = [self.notifications objectAtIndex:indexPath.row];
    TTCNotification *notification = [[TTCNotification alloc] initWithDictionary:dictionary];
    return notification;
}
@end
