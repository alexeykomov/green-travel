//
//  GalleryPageControl.m
//  GreenTravel
//
//  Created by Alex K on 12/12/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import "GalleryPageControl.h"
#import "StyleUtils.h"
#import "Colors.h"

typedef NS_ENUM(NSInteger, PageControlState) {
    PageControlStateLeftDots5,
    PageControlStateLeftDots6,
    PageControlStateDots7,
    PageControlStateRightDots6,
    PageControlStateRightDots5
};

@interface GalleryPageControl ()

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIStackView *contentView;
@property (strong, nonatomic) UIPageControl *pageControl;
@property (strong, nonatomic) NSArray<NSString *> *imageURLs;
@property (assign, nonatomic) CGFloat aspectRatio;
@property (assign, nonatomic) CGFloat indexOfScrolledItem;
@property (strong, nonatomic) NSLayoutConstraint *centerOffsetConstraint;
@property (assign, nonatomic) PageControlState pageControlState;

@end

static const CGFloat kDotWidth = 16.0;
static const CGFloat kSpacing = 12.0;

@implementation GalleryPageControl

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;
}

- (void)setUp {
    self.pageControlState = PageControlStateLeftDots5;
    
#pragma mark - Content view
    self.contentView = [[UIStackView alloc] init];
    self.contentView.backgroundColor = [Colors get].milkyGrey;
    self.contentView.alignment = UIStackViewAlignmentCenter;
    self.contentView.distribution = UIStackViewDistributionFill;
    self.contentView.spacing = kSpacing;
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.contentView];
    self.centerOffsetConstraint = [self.contentView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor constant:0.0];
    [NSLayoutConstraint activateConstraints:@[
        [self.contentView.topAnchor constraintEqualToAnchor:self.topAnchor],
        self.centerOffsetConstraint,
        [self.contentView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
        [self.contentView.heightAnchor constraintEqualToAnchor:self.heightAnchor]
    ]];
}

- (void)setNumberOfPages:(NSInteger)numberOfPages {
    for (UIView *subview in self.contentView.subviews) {
        [subview removeFromSuperview];
    }
    for (int counter = 0; counter < numberOfPages; counter++) {
        [self.contentView addArrangedSubview:[self createDotView:self.currentPage == counter]];
    }
}

- (void)moveToNextPage {
    PageControlState newState = [self getNextState:self.pageControlState forNextPage:self.currentPage + 1];
    
    BOOL shouldAddNewSubview = YES;
    BOOL shouldDeleteOldSubview = NO;
    
    NSInteger prevCount = [self.contentView.arrangedSubviews count];
    
    [self.contentView addArrangedSubview:[self createDotView:NO]];
    
    NSInteger newCount = [self.contentView.arrangedSubviews count];
    CGFloat centerOffsetCompensation = (newCount * kDotWidth + (newCount - 1) *
        kSpacing - (prevCount * kDotWidth + (prevCount - 1) * kSpacing)) / 2;
    
    self.centerOffsetConstraint.constant += centerOffsetCompensation;
    [self setNeedsLayout];
    [self layoutIfNeeded];
    __weak typeof(self) weakSelf = self;
    UIViewPropertyAnimator *moveAnimator = [[UIViewPropertyAnimator alloc] initWithDuration:0.4 curve:UIViewAnimationCurveLinear animations:^{
        weakSelf.centerOffsetConstraint.constant = -centerOffsetCompensation;
        [weakSelf layoutIfNeeded];
    }];
    [moveAnimator addCompletion:^(UIViewAnimatingPosition finalPosition) {
        [weakSelf.contentView.subviews[0] removeFromSuperview];
        weakSelf.centerOffsetConstraint.constant = 0.0;
        [weakSelf layoutIfNeeded];
    }];
    [moveAnimator startAnimation];
}

- (void)moveToPrevPage {
    
}

- (void)setCurrentPage:(NSInteger)currentPage {
    NSInteger dotIndex = 0;
    for (UIView *dotView in self.contentView.subviews) {
//        for (CALayer *layer in dotView.layer.sublayers) {
//            if ([layer isKindOfClass:CAGradientLayer.class]) {
//                [layer removeFromSuperlayer];
//            }
//        }
        dotView.backgroundColor = [Colors get].black;
    }
    for (UIView *dotView in self.contentView.subviews) {
        if (dotIndex == currentPage) {
            //insertGradientLayer(dotView, 8.0);
            dotView.backgroundColor = [Colors get].shamrock;
        }
        dotIndex++;
    }
    
}

- (UIView *)createDotView:(BOOL)isCurrent {
    UIView *dotView = [[UIView alloc] init];
    dotView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [dotView.widthAnchor constraintEqualToConstant:16.0],
        [dotView.heightAnchor constraintEqualToConstant:16.0],
    ]];
    dotView.layer.cornerRadius = 8.0;
    if (isCurrent) {
        insertGradientLayer(dotView, 8.0);
        return dotView;
    }
    dotView.backgroundColor = [Colors get].black;
    return dotView;
}

- (void)moveScrollViewFor:(NSInteger)nextPage {
    NSInteger currentPage = self.currentPage;
    PageControlState pageControlStatePrev = self.pageControlState;
    PageControlState pageControlStateNew = [self getNextState:pageControlStatePrev forNextPage:nextPage];
    if (pageControlStatePrev != pageControlStateNew) {
        return;
    }
}

- (CGFloat)calculateWidthFor:(NSInteger)numberOfPages {
    CGFloat dotsWidth = numberOfPages * kDotWidth;
    CGFloat spacings = (numberOfPages - 1) * kSpacing;
    return dotsWidth + spacings;
}

#pragma mark - State transition
- (PageControlState)getNextState:(PageControlState)prevState
                       forNextPage:(NSInteger)nextPage {
    NSInteger currentPage = self.currentPage;
    if (ABS(nextPage) - ABS(currentPage) <= 1) {
        switch (prevState) {
            case PageControlStateLeftDots5:
                if (nextPage <= 2) {
                    return PageControlStateLeftDots5;
                }
                return PageControlStateLeftDots6;
            case PageControlStateLeftDots6:
                if (nextPage < 3) {
                    return PageControlStateLeftDots5;
                }
                return PageControlStateDots7;
            case PageControlStateDots7:
                if (nextPage == 1) {
                    return PageControlStateLeftDots6;
                }
                if (nextPage == 8) {
                    return PageControlStateRightDots6;
                }
                return PageControlStateDots7;
            case PageControlStateRightDots6:
                if (nextPage > 8) {
                    return PageControlStateRightDots5;
                }
                if (nextPage >= 6) {
                    return PageControlStateRightDots6;
                }
                return PageControlStateDots7;
            case PageControlStateRightDots5:
                if (nextPage >= 7) {
                    return PageControlStateRightDots5;
                }
                return PageControlStateRightDots6;
        }
        return self.pageControlState;
    }
    PageControlState newState = prevState;
    while (ABS(nextPage) - ABS(currentPage) > 1) {
        NSInteger decrementedNextPage = nextPage < currentPage ? nextPage + 1 : nextPage - 1;
        newState = [self getNextState:newState forNextPage:decrementedNextPage];
    }
    return newState;
}

@end
