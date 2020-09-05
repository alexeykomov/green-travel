//
//  NearbyPlacesViewController.h
//  GreenTravel
//
//  Created by Alex K on 8/21/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapItemsObserver.h"
@import Mapbox;

NS_ASSUME_NONNULL_BEGIN

@class MapModel;

@interface MapViewController : UIViewController<MapItemsObserver, MGLMapViewDelegate>

- (instancetype)initWithMapModel:(MapModel *)mapModel
               showClosestPoints:(BOOL)showClosestPoints;

@end

NS_ASSUME_NONNULL_END
