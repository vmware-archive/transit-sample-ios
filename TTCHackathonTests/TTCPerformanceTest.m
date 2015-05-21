//
//  TTCPerformanceTest.m
//  TTCHackathon
//
//  Created by DX122-XL on 2015-05-20.
//  Copyright (c) 2015 Pivotal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <PCFData/PCFData.h>
#import <PCFAuth/PCFAuth.h>
#import "TTCNotificationStore.h"

@interface TTCPerformanceTest : XCTestCase

@property TTCNotificationStore *notificationStore;

@end

@implementation TTCPerformanceTest

- (void)setUp {
    [super setUp];

//    [PCFData logLevel:PCFDataLogLevelDebug];
//    [PCFAuth logLevel:PCFAuthLogLevelDebug];
    
    [PCFData registerTokenProviderBlock:^{
        return [PCFAuth fetchToken].accessToken;
    }];
    
    self.notificationStore = [[TTCNotificationStore alloc] init];
}

- (void)tearDown {
    
    
    [super tearDown];
}

- (void)testPerformanceWithSingleObject {
    [self measureBlock:^{
        XCTestExpectation *expectation1 = [self expectationWithDescription:@""];
        
        NSArray *notificationArray = [self notificationArrayWithItemCount:1];
        [self.notificationStore updateNotifications:notificationArray withBlock:^(NSArray *notifications, NSError *error) {
            [expectation1 fulfill];
        }];
        [self waitForExpectationsWithTimeout:1 handler:nil];

        XCTestExpectation *expectation2 = [self expectationWithDescription:@""];
        [self.notificationStore fetchNotificationsWithBlock:^(NSArray *notifications, NSError *error) {
            [expectation2 fulfill];
        }];
        
        [self waitForExpectationsWithTimeout:1 handler:nil];
    }];
}

- (void)testPerformanceWith10Objects {
    [self measureBlock:^{

        XCTestExpectation *expectation1 = [self expectationWithDescription:@""];
        
        NSArray *notificationArray = [self notificationArrayWithItemCount:10];
        [self.notificationStore updateNotifications:notificationArray withBlock:^(NSArray *notifications, NSError *error) {
            [expectation1 fulfill];
        }];
        [self waitForExpectationsWithTimeout:1 handler:nil];
        
        XCTestExpectation *expectation2 = [self expectationWithDescription:@""];
        [self.notificationStore fetchNotificationsWithBlock:^(NSArray *notifications, NSError *error) {
            [expectation2 fulfill];
        }];
        
        [self waitForExpectationsWithTimeout:1 handler:nil];
    }];
}

- (void)testPerformanceWith100Objects {
//    [self measureBlock:^{
    
        XCTestExpectation *expectation1 = [self expectationWithDescription:@""];
        
        NSArray *notificationArray = [self notificationArrayWithItemCount:100];
        [self.notificationStore updateNotifications:notificationArray withBlock:^(NSArray *notifications, NSError *error) {
            [expectation1 fulfill];
        }];
        [self waitForExpectationsWithTimeout:1 handler:nil];
        
        XCTestExpectation *expectation2 = [self expectationWithDescription:@""];
        [self.notificationStore fetchNotificationsWithBlock:^(NSArray *notifications, NSError *error) {
            [expectation2 fulfill];
        }];
        
        [self waitForExpectationsWithTimeout:1 handler:nil];
//    }];
}

- (void)testPerformanceWith1000Objects {
//    [self measureBlock:^{
    
        XCTestExpectation *expectation1 = [self expectationWithDescription:@""];
        
        NSArray *notificationArray = [self notificationArrayWithItemCount:1000];
        [self.notificationStore updateNotifications:notificationArray withBlock:^(NSArray *notifications, NSError *error) {
            [expectation1 fulfill];
        }];
        [self waitForExpectationsWithTimeout:2 handler:nil];
        
        XCTestExpectation *expectation2 = [self expectationWithDescription:@""];
        [self.notificationStore fetchNotificationsWithBlock:^(NSArray *notifications, NSError *error) {
            [expectation2 fulfill];
        }];
        
        [self waitForExpectationsWithTimeout:1 handler:nil];
//    }];
}

- (void)testPerformanceWith10000Objects {
//    [self measureBlock:^{
    
        XCTestExpectation *expectation1 = [self expectationWithDescription:@""];
        
        NSArray *notificationArray = [self notificationArrayWithItemCount:10000];
        [self.notificationStore updateNotifications:notificationArray withBlock:^(NSArray *notifications, NSError *error) {
            [expectation1 fulfill];
        }];
        [self waitForExpectationsWithTimeout:1000 handler:nil];
        
        XCTestExpectation *expectation2 = [self expectationWithDescription:@""];
        [self.notificationStore fetchNotificationsWithBlock:^(NSArray *notifications, NSError *error) {
            [expectation2 fulfill];
        }];
        
        [self waitForExpectationsWithTimeout:1000 handler:nil];
//    }];
}

- (void)testPerformanceWith100000Objects {
//    [self measureBlock:^{
    
        XCTestExpectation *expectation1 = [self expectationWithDescription:@""];
        
        NSArray *notificationArray = [self notificationArrayWithItemCount:100000];
    
        [self.notificationStore updateNotifications:notificationArray withBlock:^(NSArray *notifications, NSError *error) {
            [expectation1 fulfill];
        }];

        [self waitForExpectationsWithTimeout:10000 handler:nil];
        
        XCTestExpectation *expectation2 = [self expectationWithDescription:@""];
        [self.notificationStore fetchNotificationsWithBlock:^(NSArray *notifications, NSError *error) {
            [expectation2 fulfill];
        }];
        
        [self waitForExpectationsWithTimeout:1000 handler:nil];
//    }];
}

- (NSArray *)notificationArrayWithItemCount:(int)count {
    NSMutableArray *notificationArray = [NSMutableArray array];
    
    for (int a = 0; a < count; a++) {
        [notificationArray addObject:@{ @"aps" : @{ @"alert" : [[NSUUID UUID] UUIDString], @"content-available" : @"1" }, @"read" : @"false", @"timestamp" : [[NSUUID UUID] UUIDString] } ];
    }
    
    return notificationArray;
}

@end
