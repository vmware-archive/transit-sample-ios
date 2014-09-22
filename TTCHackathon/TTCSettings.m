//
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import "TTCSettings.h"

// Data service parameters
NSString *const kOAuthServerURL = @"http://datasync-authentication.demo.vchs.cfms-apps.com";
NSString *const kDataServiceURL = @"http://datasync-datastore.demo.vchs.cfms-apps.com";
NSString *const kDataClientID = @"cd68e385-c0e8-4740-a563-748e643a2280";
NSString *const kDataClientSecret = @"IaioD3Mcj4XU67ySMidiFDNrKwv68RB4Cft2zLrdJHoWcdqjsCSWf1U1EZDR6JKufpNp9NTcBqSxbR6bA95_eg";

// API Gateway parameters
NSString *const kRoutePath = @"http://transit-gateway.demo.vchs.cfms-apps.com/ttc/routes";
NSString *const kStopsPath = @"http://transit-gateway.demo.vchs.cfms-apps.com/ttc/routes/%@";

// Push service parameters
NSString *const kPushBaseServerUrl = @"http://push-notifications.demo.vchs.cfms-apps.com";
NSString *const kPushDevelopmentVariantUuid = @"15a001cd-f200-40a1-b052-763fbeee12a3";
NSString *const kPushDevelopmentVariantSecret = @"84def001-645b-4dfa-af5f-e2659dd27b0f";
NSString *const kPushProductionVariantUuid = @"15a001cd-f200-40a1-b052-763fbeee12a3";
NSString *const kPushProductionVariantSecret = @"84def001-645b-4dfa-af5f-e2659dd27b0f";
NSString *const kPushDeviceAlias = @"Transit";