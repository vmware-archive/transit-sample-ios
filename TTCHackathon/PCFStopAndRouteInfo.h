//
//  PCFStopAndRouteInfo.h
//  TTCHackathon
//
//  Created by DX121-XL on 2014-08-08.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface PCFStopAndRouteInfo : NSObject
//@property (nonatomic, strong) NSString* routeTitle;
//@property (nonatomic, strong) NSString* routeTag;
//@property (nonatomic, strong) NSString* stopTitle;
//@property (nonatomic, strong) NSString* stopTag;
//
//@property (nonatomic, strong) NSString *time;

@property (nonatomic, strong) NSString* route;
@property (nonatomic, strong) NSString* stop;
@property (nonatomic, strong) NSString* time;
@property (nonatomic, strong) NSString *tag;
@property BOOL enabled;
@end

