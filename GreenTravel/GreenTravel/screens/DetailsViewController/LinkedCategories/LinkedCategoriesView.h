//
//  LinkedCategoriesView.h
//  GreenTravel
//
//  Created by Alex K on 11/6/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Category;
@class ApiService;
@class MapModel;
@class LocationModel;
@class IndexModel;
@class CategoryUUIDToRelatedItemUUIDs;
@class PlacesViewController;

NS_ASSUME_NONNULL_BEGIN

@interface LinkedCategoriesView : UITableView<UITableViewDataSource, UITableViewDelegate>

- (instancetype)initWithIndexModel:(IndexModel *)indexModel
                     apiService:(nonnull ApiService *)apiService
                       mapModel:(nonnull MapModel *)mapModel
                  locationModel:(nonnull LocationModel *)locationModel
     pushToNavigationController:(void(^)(PlacesViewController *))pushToNavigationController;

- (void)update:(NSArray<CategoryUUIDToRelatedItemUUIDs *>*)categoryIdToItems;

@end

NS_ASSUME_NONNULL_END
