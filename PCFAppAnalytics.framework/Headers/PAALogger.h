//
//  PAALogger.h
//  PCFAppAnalytics
//
//  Created by David Protasowski on 2014-11-17.
//  Copyright (c) 2015 Pivotal. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 * @typedef PAALogLevel
 * @brief Available log levels
 */
typedef NS_ENUM(NSInteger, PAALogLevel) {
    PAALogLevelDebug = 0,
    PAALogLevelInfo,
    PAALogLevelWarning,
    PAALogLevelError,
    PAALogLevelCritical
};

/*!
 * @discussion Convert a PAALogLevel into a human-readable string.
 * @param level PAALogLevel to convert.
 * @return The human-readable string representaion of the PAALogLevel.
 */
extern NSString* PAALogLevelString(PAALogLevel level);

@protocol PAALogListener
- (void)log:(PAALogLevel)level
        tag:(NSString *)tag
    message:(NSString *)message;
@end

@interface PAALogger : NSObject

/*!
 * @brief The delegate to receive the log messages.
 */
@property (nonatomic, weak) id<PAALogListener> delegate;

/*!
 * @discussion Retrieve the shared App Analytics Logger.
 * @return The shared PAALogger.
 */
+ (instancetype)sharedLogger;

@end
