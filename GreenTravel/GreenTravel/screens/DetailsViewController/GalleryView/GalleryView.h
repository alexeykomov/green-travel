//
//  GalleryView.h
//  GreenTravel
//
//  Created by Alex K on 11/21/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GalleryView : UICollectionView<UICollectionViewDelegate,
    UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

- (instancetype)initWithFrame:(CGRect)frame aspectRatio:(CGFloat)aspectRatio;
- (void)setUpWithPictureURLs:(NSArray<NSString *>*)pictureURLs;

@end

NS_ASSUME_NONNULL_END
