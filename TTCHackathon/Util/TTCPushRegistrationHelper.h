//
//  TTCPushRegistrationHelper.h
//  TTCHackathon
//
//  Created by Rob Szumlakowski on 2014-09-23.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTCPushRegistrationHelper : NSObject

+ (void) initializePushSDK:(NSSet*)pushTags;

@end
