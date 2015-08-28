//
//  PCFAppAnalytics.h
//  PCFAppAnalytics
//
//  Created by David Protasowski on 2014-11-17.
//  Copyright (c) 2015 Pivotal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PAALogger.h"

//! Project version number for PCFAppAnalytics.h.
FOUNDATION_EXPORT double PCFAppAnalyticsVersionNumber;

//! Project version string for PCFAppAnalytics.h.
FOUNDATION_EXPORT const unsigned char PCFAppAnalyticsVersionString[];

/**
 * Primary entry point for the PCF App Analytics SDK library.
 *
 * Usage: see `Development Guide` on the Pivotal Cloud Foundry Mobile Services documentation site.
 */

@interface PCFAppAnalytics : NSObject

/*!
 * @brief The PCF App Analytics server to capture the events (Read Only).
 */
@property (nonatomic, readonly) NSString *domain;

/*!
 * @brief The API key used to identify the application (Read Only).
 */
@property (nonatomic, readonly) NSString *apiKey;

/*!
 * @brief Number of events to send in each request. Defaults to 50.
 */
@property (atomic) NSUInteger eventBatchUploadSize;


/*!
 * @brief Indicates if the SDK should accept self-signed SSL Certificates from the App Analytics server. Defaults to NO.
 */
@property (atomic) BOOL acceptSelfSignedCertificates;

/*!
 * @discussion Initializes the SDK for your server and application. The SDK should be initialized in the
 * AppDelegate's application:didFinishLaunchingWithOptions:
 *
 * To provide parameters, you must provide a PLIST file called "Pivotal.plist" with the following keys:
 *
 *    pivotal.appanalytics.domain - The URL of the PCF App Analytics Receiver
 *    pivotal.appanalytics.apiKey - The Api Key of your application.
 *
 * None of the above values may be `nil`.  None of the above values may be empty.
 * A configured PLIST file can be downloaded from the Settings page of your application in the Dashboard.
 *
 * @return An initialized shared instance of PCFAppAnalytics.
 */

+ (PCFAppAnalytics *)initWithLaunchOptions:(NSDictionary *)dictionary;

/*!
 * @discussion Retrieves the PCFAppAnalytics for configuration and sending custom events.
 * @return A shared instance of PCFAppAnalytics.
 */
+ (PCFAppAnalytics *)shared;


/*!
 * @discussion Triggers a custom event.
 * @param name The name of the custom event.
 * @param properties Additional properties to associate with the event.
 */
- (void)eventWithName:(NSString *)name
           properties:(NSDictionary *)userProperties;

/*!
 * @discussion Triggers a custom event.
 * @param name The name of the custom event.
 */
- (void)eventWithName:(NSString *)name;


@end
