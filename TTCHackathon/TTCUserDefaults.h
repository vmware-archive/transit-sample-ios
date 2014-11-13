//
//  TTCUserDefaults.h
//  TTCHackathon
//
//  Created by Rob Szumlakowski on 2014-11-13.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTCUserDefaults : NSObject

+ (NSString*) getLastNotificationText;
+ (void) setLastNotificationText:(NSString*)text;
+ (NSDate*) getLastNotificationTime;
+ (void) setLastNotificationTime:(NSDate*)date;

@end
