//
//  IndexViewController.h
//  GreenTravel
//
//  Created by Alex K on 8/15/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CategoriesObserver.h"

NS_ASSUME_NONNULL_BEGIN

@class ApiService;
@class IndexModel;
@class SearchModel;
@class LocationModel;
@class MapModel;

@interface IndexViewController : UITableViewController<CategoriesObserver>

- (instancetype) initWithApiService:(ApiService *)apiService
                              model:(IndexModel *)model
                        searchModel:(SearchModel *)searchModel
                      locationModel:(LocationModel *)locationModel
                           mapModel:(MapModel *)mapModel;

@end

NS_ASSUME_NONNULL_END
