//
//  BookmarkCell.h
//  GreenTravel
//
//  Created by Alex K on 8/20/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PlacesItem;

@interface BookmarkCell : UICollectionViewCell

@property (strong, nonatomic) PlacesItem *item;
- (void)update:(PlacesItem *)item;

@end

NS_ASSUME_NONNULL_END
