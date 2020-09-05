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

@interface DetailsViewController : UIViewController <DetailsObserver>

- (instancetype)initWithApiService:(ApiService *)apiService
                      detailsModel:(DetailsModel *)detailsModel;
@property (strong, nonatomic) PlaceItem *item;

@end

NS_ASSUME_NONNULL_END
