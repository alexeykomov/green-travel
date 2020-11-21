//
//  GalleryView.m
//  GreenTravel
//
//  Created by Alex K on 11/21/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import "GalleryView.h"
#import "SlideCollectionViewCell.h"

@interface GalleryView ()

@property (strong, nonatomic) UIPageControl *pageControl;
@property (strong, nonatomic) NSArray<NSString *> *imageURLs;
@property (assign, nonatomic) CGFloat aspectRatio;

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

- (instancetype)initWithFrame:(CGRect)frame aspectRatio:(CGFloat)aspectRatio
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    self = [super initWithFrame:frame collectionViewLayout:flowLayout];
    if (self) {
        self.aspectRatio = aspectRatio;
        [self setPagingEnabled:YES];
        self.showsHorizontalScrollIndicator = NO;
        [self registerClass:SlideCollectionViewCell.class forCellWithReuseIdentifier:kSlideCellIdentifier];
        self.dataSource = self;
        self.delegate = self;
    }
    return self;
}

- (void)setUpWithPictureURLs:(NSArray<NSString *>*)pictureURLs {
    self.imageURLs = [[NSArray alloc] initWithArray:pictureURLs];
    [self reloadData];
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    SlideCollectionViewCell *cell = [self dequeueReusableCellWithReuseIdentifier:kSlideCellIdentifier  forIndexPath:indexPath];
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


@end
