//
//  FeedItemTableViewCell.h
//  GreenTravel
//
//  Created by Alex K on 3/7/21.
//  Copyright © 2021 Alex K. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PlaceItem;

NS_ASSUME_NONNULL_BEGIN

@interface FeedItemCell : UITableViewCell

- (void)update:(PlaceItem *)item 
onBookmarkButtonPress:(void(^)(void))onBookmarkButtonPress
onLocationButtonPress:(void(^)(void))onLocationButtonPress
onMapButtonPress:(void(^)(void))onMapButtonPress
onCategoriesLinkPress:(void(^)(NSOrderedSet<NSString *> *))onCategoriesLinkPress;
- (void)showDetailed;

@end

NS_ASSUME_NONNULL_END
