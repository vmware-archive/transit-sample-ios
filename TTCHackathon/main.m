//
//  Copyright (C) 2014 Pivotal Software, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TTCAppDelegate.h"

#if SHOW_TOUCHES
#import "QTouchposeApplication.h"
#endif

int main(int argc, char *argv[])
{
    @autoreleasepool
    {
        #if SHOW_TOUCHES
            return UIApplicationMain(argc, argv, NSStringFromClass([QTouchposeApplication class]), NSStringFromClass([TTCAppDelegate class]));
        #else
            return UIApplicationMain(argc, argv, nil, NSStringFromClass([TTCAppDelegate class]));
        #endif
    }
}