//
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import "TTCStopAndRouteInfo.h"

@implementation TTCStopAndRouteInfo

- (void) createIdentifier
{
    self.identifier = [NSString stringWithFormat:@"%@_%@_%@", self.timeInUtc, self.routeTag, self.stopTag];
}

@end
