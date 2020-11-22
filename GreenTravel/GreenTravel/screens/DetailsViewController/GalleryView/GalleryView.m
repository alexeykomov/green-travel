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

@interface GalleryView ()

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
    
    self.pageControl = [[UIPageControl alloc] init];
    self.pageControl.pageIndicatorTintColor = [Colors get].grey;
    self.pageControl.currentPageIndicatorTintColor = [Colors get].black;
    [self addSubview:self.pageControl];
    self.pageControl.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.pageControl.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
        [self.pageControl.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:15.0],
        [self.pageControl.heightAnchor constraintEqualToConstant:50.0],
        [self.pageControl.widthAnchor constraintEqualToConstant:150.0],
    ]];
}

- (void)setUpWithPictureURLs:(NSArray<NSString *>*)pictureURLs {
    self.imageURLs = [[NSArray alloc] initWithArray:pictureURLs];
    [self.collectionView reloadData];
    [self.pageControl setNumberOfPages:[self.imageURLs count]];
    [self.pageControl setCurrentPage:0];
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
    [self.pageControl setCurrentPage:(int) indexOfScrolledItem];
}

@end
