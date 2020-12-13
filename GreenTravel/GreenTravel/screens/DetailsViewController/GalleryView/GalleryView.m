//
//  GalleryView.m
//  GreenTravel
//
//  Created by Alex K on 11/21/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import "GalleryView.h"
#import "SlideCollectionViewCell.h"
#import "Colors.h"
#import "StyleUtils.h"

typedef NS_ENUM(NSInteger, PageControlState) {
    PageControlStateLeftDots5,
    PageControlStateLeftDots6,
    PageControlStateDots7,
    PageControlStateRightDots6,
    PageControlStateRightDots5
};

@interface GalleryView ()

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UIPageControl *pageControl;
@property (strong, nonatomic) NSArray<NSString *> *imageURLs;
@property (assign, nonatomic) CGFloat aspectRatio;
@property (assign, nonatomic) CGFloat indexOfScrolledItem;
@property (strong, nonatomic) NSLayoutConstraint *scrollViewWidthConstraint;
@property (assign, nonatomic) PageControlState pageControlState;

@end

static NSString * const kSlideCellIdentifier = @"slideCellId";
static const NSInteger kMaximalNumberOfDotsForCustomPageControl = 6;
static const CGFloat kPageControlScrollContainerWidthFor5 = 78.0;
static const CGFloat kPageControlScrollContainerWidthFor6 = 88.0;
static const CGFloat kPageControlScrollContainerWidthFor7 = 98.0;

@implementation GalleryView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame
                    imageURLs:(NSArray<NSString *>*)imageURLs
                  aspectRatio:(CGFloat)aspectRatio
            pageControlHeight:(CGFloat)pageControlHeight
{

    self = [super initWithFrame:frame];
    if (self) {
        [self setUp:imageURLs aspectRatio:aspectRatio pageControlHeight:pageControlHeight];
        self.pageControlState = PageControlStateLeftDots5;
    }
    return self;
}

- (void)setUp:(NSArray<NSString *>*)imageURLs aspectRatio:(CGFloat)aspectRatio pageControlHeight:(CGFloat)pageControlHeight {
    self.aspectRatio = aspectRatio;

    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    [self addSubview:self.collectionView];
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.collectionView.topAnchor constraintEqualToAnchor:self.topAnchor],
        [self.collectionView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [self.collectionView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [self.collectionView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-pageControlHeight],
    ]];

    [self.collectionView setPagingEnabled:YES];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    [self.collectionView registerClass:SlideCollectionViewCell.class forCellWithReuseIdentifier:kSlideCellIdentifier];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [Colors get].white;

#pragma mark - Page control
    self.pageControl = [[UIPageControl alloc] init];
    self.pageControl.pageIndicatorTintColor = [Colors get].milkyGrey;
    self.pageControl.translatesAutoresizingMaskIntoConstraints = NO;
    
    if (@available(iOS 14.0, *)) {
        self.pageControl.currentPageIndicatorTintColor = [Colors get].green;
        self.pageControl.allowsContinuousInteraction = YES;
        [self addSubview:self.pageControl];
        [NSLayoutConstraint activateConstraints:@[
            [self.pageControl.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
            [self.pageControl.heightAnchor constraintEqualToConstant:50.0],
            [self.pageControl.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:15.0],
        ]];
    } else if ([imageURLs count] <= kMaximalNumberOfDotsForCustomPageControl) {
        self.pageControl.currentPageIndicatorTintColor = [Colors get].green;
        [self addSubview:self.pageControl];
        [NSLayoutConstraint activateConstraints:@[
            [self.pageControl.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
            [self.pageControl.heightAnchor constraintEqualToConstant:50.0],
            [self.pageControl.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:15.0],
        ]];
    } else {
        self.pageControl.currentPageIndicatorTintColor = [Colors get].green;
        self.scrollView = [[UIScrollView alloc] init];
        self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
        self.scrollView.backgroundColor = [Colors get].blue;
        [self addSubview:self.scrollView];
        self.scrollViewWidthConstraint = [self.scrollView.widthAnchor constraintEqualToConstant:kPageControlScrollContainerWidthFor5];
        [NSLayoutConstraint activateConstraints:@[
            [self.scrollView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
            self.scrollViewWidthConstraint,
            [self.scrollView.heightAnchor constraintEqualToConstant:50.0],
            [self.scrollView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:15.0],
        ]];
        self.contentView = [[UIScrollView alloc] init];
        self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.scrollView addSubview:self.contentView];
        [NSLayoutConstraint activateConstraints:@[
            [self.contentView.topAnchor constraintEqualToAnchor:self.scrollView.topAnchor],
            [self.contentView.leadingAnchor constraintEqualToAnchor:self.scrollView.leadingAnchor],
            [self.contentView.trailingAnchor constraintEqualToAnchor:self.scrollView.trailingAnchor],
            [self.contentView.bottomAnchor constraintEqualToAnchor:self.scrollView.bottomAnchor],
            [self.contentView.heightAnchor constraintEqualToConstant:50.0]
        ]];
        [self.contentView addSubview:self.pageControl];
        [NSLayoutConstraint activateConstraints:@[
            [self.pageControl.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor],
            [self.pageControl.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:0.0],
            [self.pageControl.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:0.0],
            [self.pageControl.heightAnchor constraintEqualToAnchor:self.contentView.heightAnchor],
        ]];
    }
    [self setUpWithPictureURLs:imageURLs];
}

- (void)setUpWithPictureURLs:(NSArray<NSString *>*)pictureURLs {
    self.imageURLs = [[NSArray alloc] initWithArray:pictureURLs];
    [self.collectionView reloadData];
    [self.pageControl setNumberOfPages:[self.imageURLs count]];
    [self.pageControl setCurrentPage:0];
    [self updateAfterSettingCurrentPage:0 prevPage:0 currentPage:0];
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    SlideCollectionViewCell *cell = [self.collectionView
                                     dequeueReusableCellWithReuseIdentifier:kSlideCellIdentifier
                                     forIndexPath:indexPath];
    [cell setUpWithImageURL:self.imageURLs[indexPath.row]];
    return cell;
}

#pragma mark - Collection view

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.imageURLs count];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = self.safeAreaLayoutGuide.layoutFrame.size.width;
    return CGSizeMake(self.safeAreaLayoutGuide.layoutFrame.size.width, self.aspectRatio * width);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

#pragma mark - Scroll view delegate

- (CGFloat)getIndexOfScrolledItem {
    CGFloat indexOfScrolledItem = self.collectionView.contentOffset.x / self.frame.size.width;
    return indexOfScrolledItem;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat indexOfScrolledItem = [self getIndexOfScrolledItem];
    self.indexOfScrolledItem = indexOfScrolledItem;
    NSInteger prevPage = self.pageControl.currentPage;
		NSInteger currentPage = (NSInteger) indexOfScrolledItem;
    [self updateBeforeSettingCurrentPage];
		[self.pageControl setCurrentPage:currentPage];
    [self updateAfterSettingCurrentPage:indexOfScrolledItem
                               prevPage:prevPage
                            currentPage:currentPage];
}

#pragma mark - Update page control
- (void)updateBeforeSettingCurrentPage {
    if (__builtin_available(iOS 14.0, *)) {
        return;
    }
    NSInteger dotIndex = 0;
    for (UIView *dotView in self.pageControl.subviews) {
        for (CALayer *layer in dotView.layer.sublayers) {
            if ([layer isKindOfClass:CAGradientLayer.class]) {
                [layer removeFromSuperlayer];
            }
        }
        dotIndex++;
    }
}

- (void)updateAfterSettingCurrentPage:(NSInteger)indexOfScrolledItem
          prevPage:(NSInteger)prevPage
       currentPage:(NSInteger)currentPage {
    if (__builtin_available(iOS 14.0, *)) {
        return;
    }
    if ([self.imageURLs count] > kMaximalNumberOfDotsForCustomPageControl) {
        NSInteger indexToShow = indexOfScrolledItem;
        if (indexToShow < self.pageControl.numberOfPages - 2 && prevPage < currentPage) {
                indexToShow+=2;
        }
        if (indexToShow > 1 && prevPage > currentPage) {
                indexToShow-=2;
        }
        
        [self updateScrollViewWidth:indexOfScrolledItem];
        
        [self.scrollView scrollRectToVisible:self.pageControl.subviews[indexToShow].frame animated:YES];
    }
    int dotIndex = 0;
    for (UIView *dotView in self.pageControl.subviews) {
        if (dotIndex == self.pageControl.currentPage) {
            insertGradientLayer(dotView, dotView.layer.cornerRadius);
        }
        dotIndex++;
    }
}

#pragma mark - State transitions

- (PageControlState)getStateFromPreviousAndIndex:(NSInteger)index {
    switch (self.pageControlState) {
        case PageControlStateLeftDots5:
            if (index <= 2) {
                return PageControlStateLeftDots5;
            }
            if (index == 3) {
                return PageControlStateLeftDots6;
            }
            if (index > 3 && index <= 7) {
                return PageControlStateDots7;
            }
            if (index == 8) {
                return PageControlStateRightDots6;
            }
            if (index > 8) {
                return PageControlStateRightDots5;
            }
            return PageControlStateDots7;
        case PageControlStateLeftDots6:
            if (index == 2 || index == 3) {
                return PageControlStateLeftDots6;
            }
            if (index == 1) {
                return PageControlStateLeftDots5;
            }
            if (index > 3 && index <= 7) {
                return PageControlStateDots7;
            }
            if (index == 8) {
                return PageControlStateRightDots6;
            }
            if (index > 8) {
                return PageControlStateRightDots5;
            }
        case PageControlStateDots7:
            if (index >= 2 && index <= 7) {
                return PageControlStateDots7;
            }
            if (index == 1) {
                return PageControlStateLeftDots6;
            }
            if (index < 1) {
                return PageControlStateLeftDots5;
            }
            if (index == 8) {
                return PageControlStateRightDots6;
            }
            if (index > 8) {
                return PageControlStateRightDots5;
            }
        case PageControlStateRightDots6:
            if (index > 8) {
                return PageControlStateRightDots5;
            }
            if (index >= 6 && index <= 8) {
                return PageControlStateRightDots6;
            }
            if (index < 6 && index >= 2) {
                return PageControlStateDots7;
            }
            if (index == 1) {
                return PageControlStateLeftDots6;
            }
            if (index < 1) {
                return PageControlStateLeftDots5;
            }
        case PageControlStateRightDots5:
            if (index <= 9 && index >= 7) {
                return PageControlStateRightDots5;
            }
            if (index == 6) {
                return PageControlStateRightDots6;
            }
            if (index < 6 && index >= 2) {
                return PageControlStateDots7;
            }
            if (index == 1) {
                return PageControlStateLeftDots6;
            }
            if (index < 1) {
                return PageControlStateLeftDots5;
            }
    }
    return self.pageControlState;
}

- (void)updateScrollViewWidth:(NSInteger)index {
    PageControlState pageControlState = [self getStateFromPreviousAndIndex:index];
    CGFloat scrollViewWidth = 0;
    if (pageControlState == PageControlStateLeftDots5 || pageControlState == PageControlStateRightDots5) {
        scrollViewWidth = kPageControlScrollContainerWidthFor5;
    } else if (pageControlState == PageControlStateLeftDots6 || pageControlState == PageControlStateRightDots6) {
        scrollViewWidth = kPageControlScrollContainerWidthFor6;
    } else {
        scrollViewWidth = kPageControlScrollContainerWidthFor7;
    }
    
    self.scrollViewWidthConstraint.constant = scrollViewWidth;
    [self.scrollView setNeedsLayout];
    [self.scrollView layoutIfNeeded];
}

@end
 
