//
//  PlacesViewController.h
//  GreenTravel
//
//  Created by Alex K on 8/19/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CategoriesObserver.h"
#import "BookmarksObserver.h"

NS_ASSUME_NONNULL_BEGIN

@class Category;
@class PlaceItem;
@class ApiService;
@class MapModel;
@class LocationModel;
@class IndexModel;


@interface PlacesViewController : UICollectionViewController<CategoriesObserver, BookmarksObserver>

@property (strong, nonatomic) Category *category;
- (instancetype)initWithIndexModel:(IndexModel *)indexModel
                        apiService:(ApiService *)apiService
                          mapModel:(MapModel *)mapModel
                     locationModel:(LocationModel *)locationModel
                        bookmarked:(BOOL)bookmarked
                  allowedItemUUIDs:(nullable NSOrderedSet<NSString *> *) allowedItemUUIDs;

@end

NS_ASSUME_NONNULL_END
