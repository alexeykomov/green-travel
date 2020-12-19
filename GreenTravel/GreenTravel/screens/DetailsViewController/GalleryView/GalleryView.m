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
#import "GalleryPageControl.h"

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
@property (strong, nonatomic) GalleryPageControl *pageControl;
@property (strong, nonatomic) NSArray<NSString *> *imageURLs;
@property (assign, nonatomic) CGFloat aspectRatio;
@property (assign, nonatomic) CGFloat indexOfScrolledItem;
@property (strong, nonatomic) NSLayoutConstraint *scrollViewWidthConstraint;

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
    self.pageControl = [[GalleryPageControl alloc] init];
    [self addSubview:self.pageControl];
    self.pageControl.translatesAutoresizingMaskIntoConstraints = NO;
    
    [NSLayoutConstraint activateConstraints:@[
        [self.pageControl.topAnchor constraintEqualToAnchor:self.collectionView.bottomAnchor],
        [self.pageControl.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [self.pageControl.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [self.pageControl.heightAnchor constraintEqualToConstant:20.0],
    ]];
    
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
    CGFloat indexOfScrolledItem = ABS(round([self getIndexOfScrolledItem]));
    NSLog(@"Collection view did scroll: %f", indexOfScrolledItem);
    if (indexOfScrolledItem > self.indexOfScrolledItem) {
        self.indexOfScrolledItem = indexOfScrolledItem;
        [self.pageControl moveToNextPage];
    }
    if (indexOfScrolledItem < self.indexOfScrolledItem) {
        self.indexOfScrolledItem = indexOfScrolledItem;
        [self.pageControl moveToPrevPage];
    }
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat indexOfScrolledItem = [self getIndexOfScrolledItem];
    NSLog(@"Collection view did end decelerating: %f", indexOfScrolledItem);
//    self.indexOfScrolledItem = indexOfScrolledItem;
//    NSInteger prevPage = self.pageControl.currentPage;
//		NSInteger currentPage = (NSInteger) indexOfScrolledItem;
//    [self updateBeforeSettingCurrentPage];
//		[self.pageControl setCurrentPage:currentPage];
//    [self updateAfterSettingCurrentPage:indexOfScrolledItem
//                               prevPage:prevPage
//                            currentPage:currentPage];
}

#pragma mark - Update page control
- (void)updateBeforeSettingCurrentPage {
   
}

- (void)updateAfterSettingCurrentPage:(NSInteger)indexOfScrolledItem
          prevPage:(NSInteger)prevPage
       currentPage:(NSInteger)currentPage {
}

@end
 
