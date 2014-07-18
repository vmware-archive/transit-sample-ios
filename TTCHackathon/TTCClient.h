//
//  TTCClient.h
//  TTCHackathon
//
//  Created by Elliott Garcea on 2014-06-20.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import "AFHTTPClient.h"

@interface TTCClient : AFHTTPClient

+ (instancetype)sharedClient;

@end
