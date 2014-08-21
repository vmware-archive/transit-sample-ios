//
//  Copyright (C) 2014 Pivotal Software, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol signInViewDelegate <NSObject>
    -(void)authenticationSuccess;
@end

@interface PCFSignInViewController : UIViewController

@property id <signInViewDelegate> delegate;

@end
