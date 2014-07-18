//
//  TTCClient.m
//  TTCHackathon
//
//  Created by Elliott Garcea on 2014-06-20.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import "TTCClient.h"

static NSString *const kBaseURL = @"";

@implementation TTCClient

+ (instancetype)sharedClient
{
    static dispatch_once_t onceToken;
    static TTCClient *sharedClient;
    dispatch_once(&onceToken, ^{
        sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:kBaseURL]];
        sharedClient.parameterEncoding = AFJSONParameterEncoding;
    });
    return sharedClient;
}



@end
