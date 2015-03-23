//
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import "TTCSettings.h"

#define PWS // <-- comment this line for demo.vchs
#ifdef PWS
/* Data Sync Parameters */
NSString *const kOAuthServerURL = @"http://transit-authz.cfapps.io";
NSString *const kDataServiceURL = @"http://transit-ds.cfapps.io";
NSString *const kDataClientID = @"ios-client";
NSString *const kDataClientSecret = @"006d0cea91f01a82cdc57afafbbc0d26c8328964029d5b5eae920e2fdc703169";

/* API Gateway Parameters */
NSString *const kRoutePath = @"http://transit-gateway-app.cfapps.io/ttc/routes";
NSString *const kStopsPath = @"http://transit-gateway-app.cfapps.io/ttc/routes/%@";

/* Push Notifications parameters */
NSString *const kPushBaseServerUrl = @"http://transit-push.cfapps.io";
NSString *const kPushDevelopmentVariantUuid = @"15a001cd-f200-40a1-b052-763fbeee12a3";
NSString *const kPushDevelopmentVariantSecret = @"84def001-645b-4dfa-af5f-e2659dd27b0f";
NSString *const kPushProductionVariantUuid = @"211ef0cb-acac-4816-ac46-a401f46ee463";
NSString *const kPushProductionVariantSecret = @"3a02ec0e-85e3-47c6-8d5b-27ef3a0c386e";
NSString *const kPushDeviceAlias = @"TransitApp";

#else
/* Data Sync Parameters */
NSString *const kOAuthServerURL = @"http://datasync-authentication.demo.vchs.cfms-apps.com";
NSString *const kDataServiceURL = @"http://datasync-datastore.demo.vchs.cfms-apps.com";
NSString *const kDataClientID = @"aedc2fcf-d7bb-4e80-8505-0540afe17974";
NSString *const kDataClientSecret = @"AMtcNHQR6Ur89ZQcn8CNper-BGCRpOji4Jz1RMJ4eGO-r1R6jlre0kJ6ji1zvX-I2SSqqo1HlH9V-MVETH_pr0Y";

/* API Gateway Parameters */
NSString *const kRoutePath = @"http://transit-gateway.demo.vchs.cfms-apps.com/ttc/routes";
NSString *const kStopsPath = @"http://transit-gateway.demo.vchs.cfms-apps.com/ttc/routes/%@";

/* Push Notifications parameters */
NSString *const kPushBaseServerUrl = @"http://push-notifications.demo.vchs.cfms-apps.com";
NSString *const kPushDevelopmentVariantUuid = @"15a001cd-f200-40a1-b052-763fbeee12a3";
NSString *const kPushDevelopmentVariantSecret = @"84def001-645b-4dfa-af5f-e2659dd27b0f";
NSString *const kPushProductionVariantUuid = @"211ef0cb-acac-4816-ac46-a401f46ee463";
NSString *const kPushProductionVariantSecret = @"3a02ec0e-85e3-47c6-8d5b-27ef3a0c386e";
NSString *const kPushDeviceAlias = @"Transit";

#endif
