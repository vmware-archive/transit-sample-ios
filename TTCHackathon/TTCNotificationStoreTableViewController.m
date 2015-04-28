//
//  TTCNotificationStoreTableViewController.m
//  TTCHackathon
//
//  Created by DX122-XL on 2015-04-28.
//  Copyright (c) 2015 Pivotal. All rights reserved.
//

#import "TTCNotificationStoreTableViewController.h"
#import "TTCNotificationStore.h"
#import "TTCNotification.h"
#import "RESideMenu.h"

@interface TTCNotificationStoreTableViewController ()

@property (strong) TTCNotificationStore *notificationStore;
@property (strong) NSArray *notifications;

@end

@implementation TTCNotificationStoreTableViewController

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


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.notifications.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 96;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:NSStringFromClass([UITableViewCell class])];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    NSDictionary *dictionary = [self.notifications objectAtIndex:indexPath.row];
    TTCNotification *notification = [[TTCNotification alloc] initWithDictionary:dictionary];
    
    cell.textLabel.text = notification.message;
    cell.detailTextLabel.text = notification.formattedDate;

    return cell;
}

@end
