//
//  TTCRouteUtil.h
//  TTCHackathon
//
//  Created by DX181-XL on 2015-03-30.
//  Copyright (c) 2015 Pivotal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTCRouteTitleModel.h"

@interface TTCRouteUtil : NSObject

+ (TTCRouteTitleModel*) routeTitleModelFromRouteTitle:(NSString*)routeTitle;

@end
