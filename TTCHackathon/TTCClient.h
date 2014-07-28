//
//  Copyright (C) 2014 Pivotal Software, Inc. All rights reserved.
//

#import <MSSData/AFHTTPClient.h>

@interface TTCClient : AFHTTPClient

+ (instancetype)sharedClient;

@end
