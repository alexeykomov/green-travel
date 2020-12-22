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
#import "DotsIndexes.h"

typedef NS_ENUM(NSInteger, PageControlState) {
    PageControlStateLeftDots5,
    PageControlStateLeftDots6,
    PageControlStateDots7,
    PageControlStateRightDots6,
    PageControlStateRightDots5
};


typedef NS_ENUM(NSInteger, DotSize) {
    DotSizeXS,
    DotSizeS,
    DotSizeM,
    DotSizeL
};

typedef NS_OPTIONS(NSInteger, DotsGrow) {
    DotsGrowOff = 1 << 0,
    DotsGrowConstant = 1 << 1,
    DotsGrowDown = 1 << 2,
    DotsGrowUp = 1 << 3
};

struct IndexWindow {
    NSInteger left;
    NSInteger right;
};

NSInteger indexWindowLength(struct IndexWindow indexWindow) {
    return indexWindow.right - indexWindow.left + 1;
}

BOOL indexWindowEquals(struct IndexWindow indexWindowA, struct IndexWindow indexWindowB) {
    return indexWindowA.right == indexWindowB.right &&
            indexWindowA.left == indexWindowB.left;
}

NSUInteger normalizedPage(NSUInteger page, struct IndexWindow indexWindow) {
    return page - indexWindow.left;
}

NSUInteger normalizedPageRight(NSUInteger page, struct IndexWindow indexWindow) {
    return indexWindow.right - page;
}

static const CGFloat kDotWidth = 16.0;
static const CGFloat kSpacing = 12.0;
static const NSUInteger kMaxNumberOfDotsOnStart = 5;

@interface GalleryPageControl ()

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIStackView *contentView;
@property (strong, nonatomic) UIPageControl *pageControl;
@property (strong, nonatomic) NSArray<NSString *> *imageURLs;
@property (assign, nonatomic) CGFloat aspectRatio;
@property (assign, nonatomic) CGFloat indexOfScrolledItem;
@property (strong, nonatomic) NSLayoutConstraint *centerOffsetConstraint;

@property (assign, nonatomic) PageControlState pageControlState;
@property (assign, nonatomic) struct IndexWindow indexWindow;

@end

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
    self.indexWindow = (struct IndexWindow){0, kMaxNumberOfDotsOnStart - 1};
    self.numberOfPages = 0;
    self.currentPage = 0;
    [self drawDotsBeforeAnimation:self.currentPage forIndexWindow:self.indexWindow];
    
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
    _numberOfPages = numberOfPages;
    
    NSUInteger maxVisibleDotsOnStart = fmin(kMaxNumberOfDotsOnStart, _numberOfPages);
    for (UIView *subview in self.contentView.subviews) {
        [self.contentView removeArrangedSubview:subview];
        [subview removeFromSuperview];
    }
    for (int counter = 0; counter < maxVisibleDotsOnStart; counter++) {
        [self.contentView addArrangedSubview:[self createDotView:self.currentPage == counter]];
    }
}

#pragma mark - Move to next page

- (void)moveToPage:(BOOL)next {
    NSUInteger nextPage = self.currentPage + (next ? 1 : -1);
    PageControlState prevState = self.pageControlState;
    PageControlState nextState = [self getNextState:self.pageControlState
                                        forNextPage:nextPage];
    struct IndexWindow prevIndexWindow = self.indexWindow;
    struct IndexWindow nextIndexWindow =
    [self getNextIndexWindowForPrevState:self.pageControlState
                               nextState:nextState nextPage:nextPage
                         prevIndexWindow:self.indexWindow];
    DotsGrow growBehavior =
    [self getNextDotsGrowStateFromPrevIndexWindow:self.indexWindow
                                  nextIndexWindow:nextIndexWindow];
    self.pageControlState = nextState;
    [self setCurrentPage:nextPage];
    self.indexWindow = nextIndexWindow;
    
    
    if (growBehavior & DotsGrowOff) {
        [self drawDotsBeforeAnimation:nextPage forIndexWindow:prevIndexWindow];
        return;
    }
    
    NSInteger prevCount = [self.contentView.arrangedSubviews count];
    
    
    [self drawDotsBeforeAnimation:nextPage forIndexWindow:prevIndexWindow];
    
    
    if (growBehavior & DotsGrowUp || growBehavior & DotsGrowConstant) {
        [self.contentView insertArrangedSubview:[self createDotView:NO]
                                        atIndex:next ? prevCount : 0];
    } else {
        [self.contentView.arrangedSubviews[next ? 0 : prevCount - 1] removeFromSuperview];
    }
    
    [self prepareDotsBeforeAnimationForPrevState:prevState nextState:nextState];
    
    NSInteger newCount = [self.contentView.arrangedSubviews count];
    CGFloat centerOffsetCompensation = (newCount * kDotWidth + (newCount - 1) *
        kSpacing - (prevCount * kDotWidth + (prevCount - 1) * kSpacing)) / 2;
    
    self.centerOffsetConstraint.constant += fabs(centerOffsetCompensation) * (next ? 1 : -1);
    [self setNeedsLayout];
    [self layoutIfNeeded];
    __weak typeof(self) weakSelf = self;
    UIViewPropertyAnimator *moveAnimator = [[UIViewPropertyAnimator alloc] initWithDuration:0.2 curve:UIViewAnimationCurveLinear animations:^{
        if (growBehavior & DotsGrowConstant) {
            weakSelf.centerOffsetConstraint.constant = -centerOffsetCompensation * (next ? 1 : -1);
        } else {
            weakSelf.centerOffsetConstraint.constant = 0;
        }
        [weakSelf layoutIfNeeded];
    }];
    [moveAnimator addCompletion:^(UIViewAnimatingPosition finalPosition) {
        if (growBehavior & DotsGrowConstant) {
            [weakSelf.contentView.arrangedSubviews[next ? 0 : newCount - 1] removeFromSuperview];
            weakSelf.centerOffsetConstraint.constant = 0.0;
            [weakSelf layoutIfNeeded];
        }
    }];
    [moveAnimator startAnimation];
}

- (void)moveToNextPage {
    [self moveToPage:YES];
}

- (void)moveToPrevPage {
    [self moveToPage:NO];
}

- (void)drawDotsBeforeAnimation:(NSInteger)currentPage forIndexWindow:(struct IndexWindow)indexWindow {
    for (UIView *dotView in self.contentView.arrangedSubviews) {
        dotView.backgroundColor = [Colors get].black;

    }
    [self.contentView.arrangedSubviews enumerateObjectsWithOptions:0
                                                usingBlock:^(__kindof UIView * _Nonnull dotView, NSUInteger dotIndex, BOOL * _Nonnull stop) {
        if (dotIndex == normalizedPage(currentPage, indexWindow)) {
            //insertGradientLayer(dotView, 8.0);
            dotView.backgroundColor = [Colors get].shamrock;
            *stop = YES;
        }
//        if (!next && (viewsCount - dotIndex - 1) == normalizedPageRight(currentPage, indexWindow)) {
//            //insertGradientLayer(dotView, 8.0);
//            dotView.backgroundColor = [Colors get].shamrock;
//            *stop = YES;
//        }
    }];
}

- (DotsIndexes *)prepareDotsBeforeAnimationForPrevState:(PageControlState)prevState
                                     nextState:(PageControlState)nextState {
    DotsIndexes *dotsIndexes = [[DotsIndexes alloc] init];
    switch (prevState) {
        case PageControlStateLeftDots5:
            if (nextState == PageControlStateLeftDots6) {
                [dotsIndexes.smallestDotIndexesInitial addIndex:5];
                [dotsIndexes.smallDotIndexesInitial addIndex:4]; 
                [dotsIndexes.mediumDotIndexesInitial addIndex:3];
                
                [dotsIndexes.mediumDotIndexesFinal addIndex:0];
                [dotsIndexes.mediumDotIndexesFinal addIndex:4];
                [dotsIndexes.smallDotIndexesFinal addIndex:5];
            }
            return dotsIndexes;
        case PageControlStateLeftDots6:
            if (nextState == PageControlStateDots7) {
                [dotsIndexes.smallestDotIndexesInitial addIndex:5];
                [dotsIndexes.smallDotIndexesInitial addIndex:4];
                [dotsIndexes.mediumDotIndexesInitial addIndex:3];
                
                [dotsIndexes.mediumDotIndexesFinal addIndex:0];
                [dotsIndexes.mediumDotIndexesFinal addIndex:4];
                [dotsIndexes.smallDotIndexesFinal addIndex:5];
            }
            if (nextState == PageControlStateLeftDots5) {
                return (struct IndexWindow) {
                    prevIndexWindow.left,
                    prevIndexWindow.right - 1
                };
            }
            return prevIndexWindow;
        case PageControlStateDots7:
            if (nextState == prevState) {
                if (normalizedPage(nextPage, prevIndexWindow) > 4) {
                    return (struct IndexWindow){
                        prevIndexWindow.left + 1,
                        prevIndexWindow.right + 1
                    };
                }
                if (normalizedPage(nextPage, prevIndexWindow) < 2) {
                    return (struct IndexWindow){
                        prevIndexWindow.left - 1,
                        prevIndexWindow.right - 1
                    };
                }
                return prevIndexWindow;
            }
            if (nextState == PageControlStateRightDots6) {
                return (struct IndexWindow){
                    prevIndexWindow.left + 1,
                    prevIndexWindow.right
                };
            }
            if (nextState == PageControlStateLeftDots6) {
                return (struct IndexWindow){
                    prevIndexWindow.left,
                    prevIndexWindow.right - 1
                };
            }
            return prevIndexWindow;
        case PageControlStateRightDots6:
            if (nextState == PageControlStateRightDots5) {
                return (struct IndexWindow){
                    prevIndexWindow.left + 1,
                    prevIndexWindow.right
                };
            }
            if (nextState == PageControlStateDots7) {
                return (struct IndexWindow){
                    prevIndexWindow.left - 1,
                    prevIndexWindow.right
                };
            }
            return prevIndexWindow;
        case PageControlStateRightDots5:
            if (nextState == PageControlStateRightDots6) {
                return (struct IndexWindow){
                    prevIndexWindow.left - 1,
                    prevIndexWindow.right
                };
            }
            return prevIndexWindow;
    }
    [self.contentView.arrangedSubviews enumerateObjectsWithOptions:0
                                                        usingBlock:^(__kindof UIView * _Nonnull dotView, NSUInteger dotIndex, BOOL * _Nonnull stop) {
        if ([smallestDotIndexes containsIndex:dotIndex]) {
            dotView.transform = CGAffineTransformScale(dotView.transform, 0.2, 0.2);
            dotView.alpha = 0.2;
        } else if ([smallDotIndexes containsIndex:dotIndex]) {
            dotView.transform = CGAffineTransformScale(dotView.transform, 0.5, 0.5);
            dotView.alpha = 0.5;
        } else if ([mediumDotIndexes containsIndex:dotIndex]) {
            dotView.transform = CGAffineTransformScale(dotView.transform, 0.8, 0.8);
            dotView.alpha = 0.2;
        } else {
            dotView.transform = CGAffineTransformIdentity;
            dotView.alpha = 1.0;
        }
    }];
    
}

- (void)prepareDotsAfterAnimationForPrevState:(PageControlState)prevState
                                     nextState:(PageControlState)nextState {
    [self.contentView.arrangedSubviews enumerateObjectsWithOptions:0
                                                        usingBlock:^(__kindof UIView * _Nonnull dotView, NSUInteger dotIndex, BOOL * _Nonnull stop) {
        
    }];
    
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

#pragma mark - State transition
- (PageControlState)getNextState:(PageControlState)prevState
                       forNextPage:(NSInteger)nextPage {
    NSInteger currentPage = self.currentPage;
    if (labs(nextPage - currentPage) <= 1) {
        switch (prevState) {
            case PageControlStateLeftDots5:
                if (nextPage <= 2) {
                    return PageControlStateLeftDots5;
                }
                return PageControlStateLeftDots6;
            case PageControlStateLeftDots6:
                if (nextPage < 1) {
                    return PageControlStateLeftDots5;
                }
                if (nextPage > 3) {
                    return PageControlStateDots7;
                }
                return PageControlStateLeftDots6;
            case PageControlStateDots7:
                if (nextPage == 1) {
                    return PageControlStateLeftDots6;
                }
                if (nextPage == self.numberOfPages - 2) {
                    return PageControlStateRightDots6;
                }
                return PageControlStateDots7;
            case PageControlStateRightDots6:
                if (nextPage > self.numberOfPages - 2) {
                    return PageControlStateRightDots5;
                }
                if (nextPage < self.numberOfPages - 4) {
                    return PageControlStateDots7;
                }
                return PageControlStateRightDots6;
            case PageControlStateRightDots5:
                if (nextPage < self.numberOfPages - 3) {
                    return PageControlStateRightDots6;
                }
                return PageControlStateRightDots5;
        }
        return self.pageControlState;
    }
    PageControlState newState = prevState;
    while (labs(nextPage - currentPage) > 1) {
        NSInteger decrementedNextPage = nextPage < currentPage ? nextPage + 1 : nextPage - 1;
        newState = [self getNextState:newState forNextPage:decrementedNextPage];
    }
    return newState;
}

#pragma mark - Grow state
- (DotsGrow)getNextDotsGrowStateFromPrevIndexWindow:(struct IndexWindow)prevIndexWindow
             nextIndexWindow:(struct IndexWindow)nextIndexWindow {
    if (indexWindowEquals(prevIndexWindow, nextIndexWindow)) {
        return DotsGrowOff;
    }
    NSUInteger indexWindowLengthPrev = indexWindowLength(prevIndexWindow);
    NSUInteger indexWindowLengthNext = indexWindowLength(nextIndexWindow);
    if (indexWindowLengthPrev < indexWindowLengthNext) {
        return DotsGrowUp;
    }
    if (indexWindowLengthPrev > indexWindowLengthNext) {
        return DotsGrowDown;
    }
    return DotsGrowConstant;
}

#pragma mark - Index window
- (struct IndexWindow)getNextIndexWindowForPrevState:(PageControlState)prevState
                               nextState:(PageControlState)nextState
                                nextPage:(NSUInteger)nextPage
             prevIndexWindow:(struct IndexWindow)prevIndexWindow {
    switch (prevState) {
        case PageControlStateLeftDots5:
            if (nextState == PageControlStateLeftDots6) {
                return (struct IndexWindow){
                    prevIndexWindow.left,
                    prevIndexWindow.right + 1
                };
            }
            return prevIndexWindow;
        case PageControlStateLeftDots6:
            if (nextState == PageControlStateDots7) {
                return (struct IndexWindow){
                    prevIndexWindow.left,
                    prevIndexWindow.right + 1
                };
            }
            if (nextState == PageControlStateLeftDots5) {
                return (struct IndexWindow) {
                    prevIndexWindow.left,
                    prevIndexWindow.right - 1
                };
            }
            return prevIndexWindow;
        case PageControlStateDots7:
            if (nextState == prevState) {
                if (normalizedPage(nextPage, prevIndexWindow) > 4) {
                    return (struct IndexWindow){
                        prevIndexWindow.left + 1,
                        prevIndexWindow.right + 1
                    };
                }
                if (normalizedPage(nextPage, prevIndexWindow) < 2) {
                    return (struct IndexWindow){
                        prevIndexWindow.left - 1,
                        prevIndexWindow.right - 1
                    };
                }
                return prevIndexWindow;
            }
            if (nextState == PageControlStateRightDots6) {
                return (struct IndexWindow){
                    prevIndexWindow.left + 1,
                    prevIndexWindow.right
                };
            }
            if (nextState == PageControlStateLeftDots6) {
                return (struct IndexWindow){
                    prevIndexWindow.left,
                    prevIndexWindow.right - 1
                };
            }
            return prevIndexWindow;
        case PageControlStateRightDots6:
            if (nextState == PageControlStateRightDots5) {
                return (struct IndexWindow){
                    prevIndexWindow.left + 1,
                    prevIndexWindow.right
                };
            }
            if (nextState == PageControlStateDots7) {
                return (struct IndexWindow){
                    prevIndexWindow.left - 1,
                    prevIndexWindow.right
                };
            }
            return prevIndexWindow;
        case PageControlStateRightDots5:
            if (nextState == PageControlStateRightDots6) {
                return (struct IndexWindow){
                    prevIndexWindow.left - 1,
                    prevIndexWindow.right
                };
            }
            return prevIndexWindow;
    }
    return prevIndexWindow;
}

- (NSUInteger)getPage:(NSUInteger)page inIndexWindow:(struct IndexWindow)indexWindow {
    return page - indexWindow.left;
}


@end
