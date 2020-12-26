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
#import "DotSizes.h"

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

static const CGFloat kDotScaleOriginal = 1.0;
static const CGFloat kDotScaleMedium = 5.0 / 7.0;
static const CGFloat kDotScaleSmall = 3.0 / 7.0;
static const CGFloat kDotScaleExtraSmall = 0.2;

static const CGFloat kDotWidth = 7.0;
static const CGFloat kSpacing = 5.0;

static const NSUInteger kMaxNumberOfDotsOnStart = 5;
static const NSUInteger kMaxNumberOfPagesWhenSwichToContinuousMode = 6;

@interface GalleryPageControl ()

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIStackView *contentView;
@property (strong, nonatomic) UIPageControl *pageControl;
@property (strong, nonatomic) NSArray<NSString *> *imageURLs;
@property (assign, nonatomic) CGFloat aspectRatio;
@property (assign, nonatomic) CGFloat indexOfScrolledItem;
@property (strong, nonatomic) NSLayoutConstraint *centerOffsetConstraint;
@property (assign, nonatomic) BOOL continuousMode;

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

#pragma mark - Set up
- (void)setUp {
    self.pageControlState = PageControlStateLeftDots5;
    self.indexWindow = (struct IndexWindow){0, kMaxNumberOfDotsOnStart - 1};
    self.numberOfPages = 0;
    self.currentPage = 0;
    
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
    self.continuousMode = numberOfPages > kMaxNumberOfPagesWhenSwichToContinuousMode;
    NSUInteger maxVisibleDotsOnStart = fmin(kMaxNumberOfDotsOnStart, _numberOfPages);
    for (UIView *subview in self.contentView.subviews) {
        [self.contentView removeArrangedSubview:subview];
        [subview removeFromSuperview];
    }
    for (int counter = 0; counter < maxVisibleDotsOnStart; counter++) {
        [self.contentView addArrangedSubview:[self createDotView]];
    }
    if (_numberOfPages > kMaxNumberOfDotsOnStart) {
        [self applyDotSizes:@[@(DotSizeL), @(DotSizeL), @(DotSizeL), @(DotSizeM), @(DotSizeS)]];
    }
    [self applyDotColorsWithCurrentPage:0 indexWindow:(struct IndexWindow){0, 4}];
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
    DotSizes *dotSizes =
    [self prepareDotsBeforeAnimationForPrevState:prevState
                                       nextState:nextState
                                            next:next
                                indexWindowMoved:indexWindowEquals(prevIndexWindow, nextIndexWindow)];
#pragma mark - Setting new state
    self.pageControlState = nextState;
    [self setCurrentPage:nextPage];
    self.indexWindow = nextIndexWindow;
    
    __weak typeof(self) weakSelf = self;
    if (growBehavior & DotsGrowOff) {
        [self applyDotSizes:dotSizes.before];
        UIViewPropertyAnimator *moveAnimator = [[UIViewPropertyAnimator alloc] initWithDuration:0.2 curve:UIViewAnimationCurveLinear animations:^{
            [weakSelf applyDotColorsWithCurrentPage:nextPage indexWindow:nextIndexWindow];
            [weakSelf applyDotSizes:dotSizes.after];
        }];
        [moveAnimator startAnimation];
        return;
    }
    
    NSInteger prevCount = [self.contentView.arrangedSubviews count];
    
    if (growBehavior & DotsGrowUp || growBehavior & DotsGrowConstant) {
        [self.contentView insertArrangedSubview:[self createDotView]
                                        atIndex:next ? prevCount : 0];
    } else {
        [self.contentView.arrangedSubviews[next ? 0 : prevCount - 1] removeFromSuperview];
    }
    
    [self applyDotSizes:dotSizes.before];
    
    NSInteger newCount = [self.contentView.arrangedSubviews count];
    CGFloat centerOffsetCompensation = (newCount * kDotWidth + (newCount - 1) *
        kSpacing - (prevCount * kDotWidth + (prevCount - 1) * kSpacing)) / 2;
    
    self.centerOffsetConstraint.constant += fabs(centerOffsetCompensation) * (next ? 1 : -1);
    [self setNeedsLayout];
    [self layoutIfNeeded];
    UIViewPropertyAnimator *moveAnimator = [[UIViewPropertyAnimator alloc] initWithDuration:0.2 curve:UIViewAnimationCurveLinear animations:^{
        if (growBehavior & DotsGrowConstant) {
            weakSelf.centerOffsetConstraint.constant = -centerOffsetCompensation * (next ? 1 : -1);
            [weakSelf applyDotColorsWithCurrentPage:nextPage + (next ? 1 : 0) indexWindow:nextIndexWindow];
        } else {
            weakSelf.centerOffsetConstraint.constant = 0;
            [weakSelf applyDotColorsWithCurrentPage:nextPage indexWindow:nextIndexWindow];
        }
        [weakSelf applyDotSizes:dotSizes.after];
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

#pragma mark - Prepare dot sizes
- (DotSizes *)prepareDotsBeforeAnimationForPrevState:(PageControlState)prevState
                                     nextState:(PageControlState)nextState
                                                next:(BOOL)next
                                    indexWindowMoved:(BOOL)indexWindowMoved{
    DotSizes *dotsIndexes = [[DotSizes alloc] init];
    switch (prevState) {
        case PageControlStateLeftDots5:
            if (nextState == PageControlStateLeftDots6) {
                dotsIndexes.before = @[@(DotSizeL), @(DotSizeL), @(DotSizeL),
                                       @(DotSizeM), @(DotSizeS), @(DotSizeXS)];
                dotsIndexes.after = @[@(DotSizeM), @(DotSizeL), @(DotSizeL),
                                      @(DotSizeL), @(DotSizeM), @(DotSizeS)];
            } else {
                dotsIndexes.before = dotsIndexes.after =
                @[@(DotSizeL), @(DotSizeL), @(DotSizeL), @(DotSizeM), @(DotSizeS)];
            }
            break;
        case PageControlStateLeftDots6:
            if (nextState == PageControlStateDots7) {
                dotsIndexes.before = @[@(DotSizeM), @(DotSizeL), @(DotSizeL),
                                      @(DotSizeL), @(DotSizeM), @(DotSizeS), @(DotSizeXS)];
                dotsIndexes.after = @[@(DotSizeS), @(DotSizeM), @(DotSizeL),
                                      @(DotSizeL), @(DotSizeL), @(DotSizeM), @(DotSizeS)];;
            } else if (nextState == PageControlStateLeftDots5) {
                dotsIndexes.before = @[@(DotSizeM), @(DotSizeL), @(DotSizeL),
                                      @(DotSizeL), @(DotSizeM), @(DotSizeS)];
                dotsIndexes.after = @[@(DotSizeL), @(DotSizeL), @(DotSizeL),
                                      @(DotSizeM), @(DotSizeS)];
            } else if (nextState == PageControlStateRightDots6) {
                dotsIndexes.before = @[@(DotSizeM), @(DotSizeL), @(DotSizeL),
                                      @(DotSizeL), @(DotSizeM), @(DotSizeS)];
                dotsIndexes.after = @[@(DotSizeS), @(DotSizeM), @(DotSizeL),
                                      @(DotSizeL), @(DotSizeL), @(DotSizeM)];
            } else {
                dotsIndexes.before = dotsIndexes.after =
                @[@(DotSizeM), @(DotSizeL), @(DotSizeL), @(DotSizeL), @(DotSizeM), @(DotSizeS)];
            }
            break;
        case PageControlStateDots7:
            if (nextState == prevState && next && !indexWindowMoved) {
                dotsIndexes.before = @[@(DotSizeS), @(DotSizeM), @(DotSizeL), @(DotSizeL),
                                      @(DotSizeL), @(DotSizeM), @(DotSizeS), @(DotSizeXS)];
                dotsIndexes.after = @[@(DotSizeXS), @(DotSizeS), @(DotSizeM), @(DotSizeL),
                                      @(DotSizeL), @(DotSizeL), @(DotSizeM), @(DotSizeS)];
            } else if (nextState == prevState && !next && !indexWindowMoved) {
                dotsIndexes.before = @[@(DotSizeXS), @(DotSizeS), @(DotSizeM), @(DotSizeL),
                                       @(DotSizeL), @(DotSizeL), @(DotSizeM), @(DotSizeS)];
                dotsIndexes.after = @[@(DotSizeS), @(DotSizeM), @(DotSizeL), @(DotSizeL),
                                      @(DotSizeL), @(DotSizeM), @(DotSizeS), @(DotSizeXS)];
            } else if (nextState == PageControlStateRightDots6) {
                dotsIndexes.before = @[@(DotSizeM), @(DotSizeL), @(DotSizeL), @(DotSizeL),
                                      @(DotSizeM), @(DotSizeS)];
                dotsIndexes.after = @[@(DotSizeS), @(DotSizeM), @(DotSizeL), @(DotSizeL),
                                      @(DotSizeL), @(DotSizeM)];
            } else if (nextState == PageControlStateLeftDots6) {
                dotsIndexes.before = @[@(DotSizeS), @(DotSizeM), @(DotSizeL), @(DotSizeL),
                                       @(DotSizeL), @(DotSizeM)];
                dotsIndexes.after = @[@(DotSizeM), @(DotSizeL), @(DotSizeL), @(DotSizeL),
                                      @(DotSizeM), @(DotSizeS)];
            } else {
                dotsIndexes.before = dotsIndexes.after =
                @[@(DotSizeS), @(DotSizeM), @(DotSizeL), @(DotSizeL),@(DotSizeL), @(DotSizeM), @(DotSizeS)];
            }
            break;
        case PageControlStateRightDots6:
            if (nextState == PageControlStateRightDots5) {
                dotsIndexes.before = @[@(DotSizeM), @(DotSizeL), @(DotSizeL), @(DotSizeL),
                                       @(DotSizeM)];
                dotsIndexes.after = @[@(DotSizeS), @(DotSizeM), @(DotSizeL), @(DotSizeL),
                                      @(DotSizeL)];
            } else if (nextState == PageControlStateDots7) {
                dotsIndexes.before = @[@(DotSizeXS), @(DotSizeS), @(DotSizeM), @(DotSizeL), @(DotSizeL),
                                       @(DotSizeL), @(DotSizeM)];
                dotsIndexes.after = @[@(DotSizeS), @(DotSizeM), @(DotSizeL), @(DotSizeL), @(DotSizeL),
                                      @(DotSizeM), @(DotSizeS)];
            } else if (nextState == PageControlStateLeftDots6) {
                dotsIndexes.before = @[@(DotSizeS), @(DotSizeM), @(DotSizeL), @(DotSizeL), @(DotSizeL),
                                       @(DotSizeM)];
                dotsIndexes.after = @[@(DotSizeM), @(DotSizeL), @(DotSizeL), @(DotSizeL),
                                      @(DotSizeM), @(DotSizeS)];
            } else {
                dotsIndexes.before = dotsIndexes.after =
                @[@(DotSizeS), @(DotSizeM), @(DotSizeL), @(DotSizeL), @(DotSizeL), @(DotSizeM)];
            }
            break;
        case PageControlStateRightDots5:
            if (nextState == PageControlStateRightDots6) {
                dotsIndexes.before = @[@(DotSizeXS), @(DotSizeS), @(DotSizeM), @(DotSizeL), @(DotSizeL),
                                       @(DotSizeL)];
                dotsIndexes.after = @[@(DotSizeS), @(DotSizeM), @(DotSizeL), @(DotSizeL), @(DotSizeL),
                                      @(DotSizeM)];
            } else {
                dotsIndexes.before = dotsIndexes.after =
                @[@(DotSizeS), @(DotSizeM), @(DotSizeL), @(DotSizeL), @(DotSizeL)];
            }
            break;
    }
    return dotsIndexes;
}

#pragma mark - Apply dot attributes
- (void)applyDotColorsWithCurrentPage:(NSUInteger)currentPage
           indexWindow:(struct IndexWindow)indexWindow {
    NSUInteger currentDotIndex = normalizedPage(currentPage, indexWindow);
    [self.contentView.arrangedSubviews
    enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull dotView,
                  NSUInteger dotIndex, BOOL * _Nonnull stop) {
    if (dotIndex == currentDotIndex) {
        dotView.backgroundColor = [Colors get].apple;
    } else {
        dotView.backgroundColor = [Colors get].alto;
    }}];
}

- (void)applyDotSizes:(NSArray<NSNumber *>*)dotSizes {
    [self.contentView.arrangedSubviews
     enumerateObjectsWithOptions:0
     usingBlock:^(__kindof UIView * _Nonnull dotView,
                  NSUInteger dotIndex, BOOL * _Nonnull stop) {
        switch ([dotSizes[dotIndex] intValue]) {
            case DotSizeXS:
                dotView.transform = CGAffineTransformScale(CGAffineTransformIdentity, kDotScaleExtraSmall, kDotScaleExtraSmall);
                return;
            case DotSizeS:
                dotView.transform = CGAffineTransformScale(CGAffineTransformIdentity, kDotScaleSmall, kDotScaleSmall);
                return;
            case DotSizeM:
                dotView.transform = CGAffineTransformScale(CGAffineTransformIdentity, kDotScaleMedium, kDotScaleMedium);
                return;
            case DotSizeL:
                dotView.transform = CGAffineTransformIdentity;
                return;
        }
    }];
}

- (UIView *)createDotView {
    UIView *dotView = [[UIView alloc] init];
    dotView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [dotView.widthAnchor constraintEqualToConstant:kDotWidth],
        [dotView.heightAnchor constraintEqualToConstant:kDotWidth],
    ]];
    dotView.layer.cornerRadius = kDotWidth / 2;
    dotView.backgroundColor = [Colors get].alto;
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
                if (nextPage > 3 && self.numberOfPages ==
                    kMaxNumberOfPagesWhenSwichToContinuousMode) {
                    return PageControlStateRightDots6;
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
                if (nextPage < self.numberOfPages - 4 && self.numberOfPages == kMaxNumberOfPagesWhenSwichToContinuousMode) {
                    return PageControlStateLeftDots6;
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
            if (nextState == PageControlStateRightDots6) {
                return (struct IndexWindow) {
                    prevIndexWindow.left,
                    prevIndexWindow.right
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
            if (nextState == PageControlStateLeftDots6) {
                return (struct IndexWindow) {
                    prevIndexWindow.left,
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

@end
