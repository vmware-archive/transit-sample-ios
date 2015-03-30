//
//  TTCRouteUtil.m
//  TTCHackathon
//
//  Created by DX181-XL on 2015-03-30.
//  Copyright (c) 2015 Pivotal. All rights reserved.
//

#import "TTCRouteUtil.h"

@implementation TTCRouteUtil

+ (TTCRouteTitleModel*) routeTitleModelFromRouteTitle:(NSString*)routeTitle {
    
    NSUInteger delimiterIndex = [routeTitle rangeOfString:@"-"].location;
    NSString *routeNumber;
    NSString *routeName;
    if (delimiterIndex != -1) {
        routeNumber = [routeTitle substringToIndex:delimiterIndex];
        routeName = [routeTitle substringFromIndex:delimiterIndex + 1];
    }
    TTCRouteTitleModel* routeTitleModel = [[TTCRouteTitleModel alloc] initWithRouteName:routeName routeNumber:routeNumber];
    return routeTitleModel;
}

@end
