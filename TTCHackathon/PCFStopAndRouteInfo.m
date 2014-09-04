//
//  PCFStopAndRouteInfo.m
//  TTCHackathon
//
//  Created by DX121-XL on 2014-08-08.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import "PCFStopAndRouteInfo.h"

@implementation PCFStopAndRouteInfo

- (void)createIdentifier
{
    self.identifier = [NSString stringWithFormat:@"%@_%@_%@", self.timeInUtc, self.routeTag, self.stopTag];
}
@end
