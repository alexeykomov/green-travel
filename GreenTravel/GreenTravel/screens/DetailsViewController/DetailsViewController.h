//
//  DetailsViewController.h
//  GreenTravel
//
//  Created by Alex K on 8/19/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailsObserver.h"

NS_ASSUME_NONNULL_BEGIN

@class PlaceItem;
@class ApiService;
@class DetailsModel;
@class MapModel;
@class LocationModel;
@class IndexModel;

@interface DetailsViewController : UIViewController <DetailsObserver>

- (instancetype)initWithApiService:(ApiService *)apiService
                      detailsModel:(DetailsModel *)detailsModel
                        indexModel:(IndexModel *)indexModel
                          mapModel:(MapModel *)mapModel
                     locationModel:(LocationModel *)locationModel;
@property (strong, nonatomic) PlaceItem *item;

@end

NS_ASSUME_NONNULL_END
