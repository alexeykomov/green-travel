//
//  StyleUtils.m
//  GreenTravel
//
//  Created by Alex K on 8/19/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import "StyleUtils.h"
#import "Colors.h"
#import "TextUtils.h"


UIImage* getGradientImageToFillRect(CGRect rect) {
    CAGradientLayer *gradient = [[CAGradientLayer alloc] init];
    gradient.frame = rect;
    gradient.colors = @[(__bridge id)[Colors get].green.CGColor, (__bridge id)[Colors get].shamrock.CGColor];
    gradient.startPoint = CGPointMake(0, 0);
    gradient.endPoint = CGPointMake(1, 0);
    
    UIImage* gradientImage;
    UIGraphicsBeginImageContext(gradient.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [gradient renderInContext:context];
    gradientImage = [UIGraphicsGetImageFromCurrentImageContext() resizableImageWithCapInsets:UIEdgeInsetsZero resizingMode:UIImageResizingModeStretch];
    UIGraphicsEndImageContext();
    return gradientImage;
}

void configureNavigationBar(UINavigationBar *navigationBar) {
    navigationBar.titleTextAttributes = getTextAttributes([Colors get].white, 16.0, UIFontWeightSemibold);
    navigationBar.barStyle = UIBarStyleBlack;
    navigationBar.tintColor = [Colors get].white;
#pragma mark - Navigation item gradient
    CGRect navBarBounds = navigationBar.bounds;
    
    navBarBounds.size.height += UIApplication.sharedApplication.statusBarFrame.size.height;
    
    [navigationBar setBackgroundImage:getGradientImageToFillRect(navBarBounds) forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
}

void drawShadow(UIView *view) {
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:view.bounds];
    view.layer.masksToBounds = NO;
    view.layer.shadowColor = [[Colors get].heavyMetal CGColor];
    view.layer.shadowOpacity = 0.2;
    view.layer.shadowOffset = CGSizeMake(0.0, 5.0);
    view.layer.shadowRadius = 8.0;
    view.layer.shadowPath = [shadowPath CGPath];
}
