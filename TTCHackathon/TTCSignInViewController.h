//
//  Copyright (C) 2014 Pivotal Software, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TTCSignInViewDelegate <NSObject>

- (void) authenticationSuccess;

@end

@interface TTCSignInViewController : UIViewController

@property id <TTCSignInViewDelegate> delegate;

@end
