//
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import "TTCSettings.h"

//#define PWS // <-- comment this line for demo.vchs
#ifdef PWS

/* API Gateway Parameters */
NSString *const kRoutePath = @"http://transit-gateway-app.cfapps.io/ttc/routes";
NSString *const kStopsPath = @"http://transit-gateway-app.cfapps.io/ttc/routes/%@";

#else

/* API Gateway Parameters */
NSString *const kRoutePath = @"https://transit-gateway-app.borg.vchs.cfms-apps.com/ttc/routes";
NSString *const kStopsPath = @"https://transit-gateway-app.borg.vchs.cfms-apps.com/ttc/routes/%@";

#endif
