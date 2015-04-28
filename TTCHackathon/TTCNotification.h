//
//  TTCNotification.h
//  TTCHackathon
//
//  Created by DX122-XL on 2015-04-28.
//  Copyright (c) 2015 Pivotal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTCNotification : NSObject

@property (strong) NSString *message;
@property (strong) NSDate *date;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (NSString *)formattedDate;

@end
