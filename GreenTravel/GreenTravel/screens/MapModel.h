//
//  MapModel.h
//  GreenTravel
//
//  Created by Alex K on 8/30/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CategoriesObserver.h"
#import "MapItemsObservable.h"

NS_ASSUME_NONNULL_BEGIN

@class MapItem;
@class IndexModel;
@protocol MapItemsObserver;

@interface MapModel : NSObject<CategoriesObserver, MapItemsObservable>

- (instancetype)initWithIndexModel:(IndexModel *)model;
@property (strong, nonatomic) NSMutableArray<MapItem *> *mapItems;
@property (strong, nonatomic) NSMutableArray<id<MapItemsObserver>> *mapItemsObservers;

@end

NS_ASSUME_NONNULL_END
