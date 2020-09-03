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

@interface SearchViewController : UITableViewController<UISearchResultsUpdating, SearchItemsObserver, CLLocationManagerDelegate, LocationObserver> 

- (instancetype)initWithModel:(SearchModel *)model
                locationModel:(LocationModel *)locationModel;

@end

NS_ASSUME_NONNULL_END
