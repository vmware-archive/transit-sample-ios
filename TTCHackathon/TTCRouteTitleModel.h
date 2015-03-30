//
//  TTCRouteTitleModel.h
//  TTCHackathon
//
//  Created by DX181-XL on 2015-03-30.
//  Copyright (c) 2015 Pivotal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTCRouteTitleModel : NSObject

@property (nonatomic, strong) NSString *routeName;
@property (nonatomic, strong) NSString *routeNumber;

- (id) initWithRouteName:(NSString*)routeName routeNumber:(NSString*)routeNumber;

@end
