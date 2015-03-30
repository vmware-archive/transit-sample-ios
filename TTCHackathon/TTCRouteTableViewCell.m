//
//  TTCRouteTableViewCell.m
//  TTCHackathon
//
//  Created by DX181-XL on 2015-03-30.
//  Copyright (c) 2015 Pivotal. All rights reserved.
//

#import "TTCRouteTableViewCell.h"

@implementation TTCRouteTableViewCell

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    UIColor *backgroundColor = self.circleView.backgroundColor;
    [super setHighlighted:highlighted animated:animated];
    self.circleView.backgroundColor = backgroundColor;
}

@end
