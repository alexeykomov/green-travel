//
//  BannerView.m
//  GreenTravel
//
//  Created by Alex K on 11/15/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import "BannerView.h"
#import "Colors.h"

@interface BannerView ()

@property (strong, nonatomic) CAGradientLayer *gradient;

@end

@implementation BannerView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self = [self initWithFrame:CGRectZero];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    
    self.gradient.frame = self.bounds;
    self.gradient.colors = @[(__bridge id)[Colors get].green.CGColor, (__bridge id)[Colors get].shamrock.CGColor];
    self.gradient.startPoint = CGPointMake(0, 0);
    self.gradient.endPoint = CGPointMake(1, 0);
    if (!self.gradient.superlayer) {
        [self.layer insertSublayer:self.gradient atIndex:0];
    }
    
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.gradient = [[CAGradientLayer alloc] init];
    }
    return self;
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {
    [super layoutSublayersOfLayer:layer];
    self.gradient.frame = self.bounds;
}

@end
