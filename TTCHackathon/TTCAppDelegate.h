//
//  Copyright (C) 2014 Pivotal Software, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTCNotificationStore.h"

#if SHOW_TOUCHES
#import "QTouchposeApplication.h"
#endif

extern NSString *const kRemoteNotificationReceived;

@interface TTCAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
