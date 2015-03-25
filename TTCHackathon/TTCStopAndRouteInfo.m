//
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import "TTCStopAndRouteInfo.h"

@implementation TTCStopAndRouteInfo

- (id) initWithDictionary: (NSDictionary *)dictionary {
    self = [super init];
    
    if (self) {
        [self setEnabled:[dictionary[@"enabled"] boolValue]];
        [self setRoute:dictionary[@"route"]];
        [self setStop:dictionary[@"stop"]];
        [self setTag: dictionary[@"tag"]];
        [self setTime: dictionary[@"time"]];
    }
    
    return self;
}

- (void) generateTag
{
    self.tag = [NSString stringWithFormat:@"%@_%@_%@", self.timeInUtc, self.routeTag, self.stopTag];
}

- (NSDictionary *)formattedDictionary {
    NSDictionary *dictionary = @{
                           @"enabled" :    (self.enabled) ? @"1" : @"0",
                           @"route"   :    self.route,
                           @"stop"    :    self.stop,
                           @"tag"     :    self.tag,
                           @"time"    :    self.time
                           };
    
    return dictionary;
}
@end
