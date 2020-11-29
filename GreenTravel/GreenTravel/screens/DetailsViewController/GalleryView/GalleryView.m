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

@interface GalleryView ()

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UIPageControl *pageControl;
@property (strong, nonatomic) NSArray<NSString *> *imageURLs;
@property (assign, nonatomic) CGFloat aspectRatio;
@property (assign, nonatomic) CGFloat indexOfScrolledItem;

@end

NSString * const kSlideCellIdentifier = @"slideCellId";

@implementation GalleryView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame
                  aspectRatio:(CGFloat)aspectRatio
            pageControlHeight:(CGFloat)pageControlHeight
{

    self = [super initWithFrame:frame];
    if (self) {
        [self setUp:aspectRatio pageControlHeight:pageControlHeight];
    }
    return self;
}

- (void)setUp:(CGFloat)aspectRatio pageControlHeight:(CGFloat)pageControlHeight {
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
    } else {
        self.scrollView = [[UIScrollView alloc] init];
        self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.scrollView];
        [NSLayoutConstraint activateConstraints:@[
            [self.scrollView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
            [self.scrollView.widthAnchor constraintEqualToConstant:88.0],
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
}

- (void)setUpWithPictureURLs:(NSArray<NSString *>*)pictureURLs {
    self.imageURLs = [[NSArray alloc] initWithArray:pictureURLs];
    [self.collectionView reloadData];
    [self.pageControl setNumberOfPages:[self.imageURLs count]];
    [self.pageControl setCurrentPage:0];
    [self updateAfterSettingCurrentPage:0 prevPage:0 currentPage:0];
}

- (void)updateBeforeSettingCurrentPage {
    if (__builtin_available(iOS 14.0, *)) {} else {
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
}

- (void)updateAfterSettingCurrentPage:(NSInteger)indexOfScrolledItem
          prevPage:(NSInteger)prevPage
       currentPage:(NSInteger)currentPage {
    if (__builtin_available(iOS 14.0, *)) {} else {
        NSInteger indexToShow = indexOfScrolledItem;
        if (indexToShow < self.pageControl.numberOfPages - 2 && prevPage < currentPage) {
                indexToShow+=2;
        }
        if (indexToShow > 1 && prevPage > currentPage) {
                indexToShow-=2;
        }
        [self.scrollView scrollRectToVisible:self.pageControl.subviews[indexToShow].frame animated:YES];
    
        int dotIndex = 0;
        for (UIView *dotView in self.pageControl.subviews) {
            if (dotIndex == self.pageControl.currentPage) {
                insertGradientLayer(dotView, dotView.layer.cornerRadius);
            }
            dotIndex++;
        }
    }
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    SlideCollectionViewCell *cell = [self.collectionView
                                     dequeueReusableCellWithReuseIdentifier:kSlideCellIdentifier
                                     forIndexPath:indexPath];
    [cell setUpWithImageURL:self.imageURLs[indexPath.row]];
    return cell;
}

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

@end
 
