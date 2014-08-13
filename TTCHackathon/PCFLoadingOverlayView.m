//
//  PCFLoadingOverlayView.m
//  TTCHackathon
//
//  Created by DX121-XL on 2014-08-13.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import "PCFLoadingOverlayView.h"

@implementation PCFLoadingOverlayView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.activityIndicatorView = [[UIActivityIndicatorView alloc] init];
        self.activityIndicatorView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2.2);
        [self.activityIndicatorView startAnimating];
        [self addSubview:self.activityIndicatorView];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
