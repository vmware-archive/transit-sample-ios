//
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTCStopAndRouteInfo : NSObject

@property (nonatomic, strong) NSString* route;
@property (nonatomic, strong) NSString* stop;
@property (nonatomic, strong) NSString* time;
@property (nonatomic, strong) NSString* timeInUtc;
@property (nonatomic, strong) NSString* routeTag;
@property (nonatomic, strong) NSString* stopTag;
@property (nonatomic, strong) NSString* tag;
@property BOOL enabled;

- (id) initWithDictionary: (NSDictionary *)dictionary;
- (void) generateTag;
- (NSDictionary *) formattedDictionary;

@end

