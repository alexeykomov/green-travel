//
//  DescriptionView.h
//  GreenTravel
//
//  Created by Alex K on 3/8/21.
//  Copyright © 2021 Alex K. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PlaceItem;
@class Category;

NS_ASSUME_NONNULL_BEGIN

@interface DetailsView : UIView

- (instancetype)initWithItem:(PlaceItem *)item
       onBookmarkButtonPress:(void(^)(void))onBookmarkButtonPress
       onLocationButtonPress:(void(^)(void))onLocationButtonPress
            onMapButtonPress:(void(^)(void))onMapButtonPress
       onCategoriesLinkPress:(void(^)(NSOrderedSet<NSString *> *, Category *))onCategoriesLinkPress;

@end

NS_ASSUME_NONNULL_END
