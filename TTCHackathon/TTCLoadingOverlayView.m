//
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import "TTCLoadingOverlayView.h"

@implementation TTCLoadingOverlayView

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.activityIndicatorView = [[UIActivityIndicatorView alloc] init];
        self.activityIndicatorView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2.2);
        [self.activityIndicatorView startAnimating];
        [self addSubview:self.activityIndicatorView];
    }
    
    return self;
}

@end
