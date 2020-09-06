//
//  SearchViewController.h
//  GreenTravel
//
//  Created by Alex K on 8/16/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchItemsObserver.h"
#import "LocationObserver.h"
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@class SearchModel;
@class LocationModel;
@class MapModel;
@class ApiService;
@class DetailsModel;

@interface SearchViewController : UITableViewController<UISearchResultsUpdating, SearchItemsObserver, CLLocationManagerDelegate, LocationObserver> 

- (instancetype)initWithModel:(SearchModel *)model
                locationModel:(LocationModel *)locationModel
                     mapModel:(MapModel *)mapModel
apiService:(ApiService *)apiService
detailsModel:(DetailsModel *)detailsModel;

@end

NS_ASSUME_NONNULL_END
