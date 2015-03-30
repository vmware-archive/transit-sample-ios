//
//  TTCRouteTitleModel.m
//  TTCHackathon
//
//  Created by DX181-XL on 2015-03-30.
//  Copyright (c) 2015 Pivotal. All rights reserved.
//

#import "TTCRouteTitleModel.h"

@implementation TTCRouteTitleModel

- (id) initWithRouteName:(NSString*)routeName routeNumber:(NSString*)routeNumber {
    self = [super init];
    
    if (self) {
        _routeName = routeName;
        _routeNumber = routeNumber;
    }
    
    return self;
}

@end
