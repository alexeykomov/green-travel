//
//  MapModel.m
//  GreenTravel
//
//  Created by Alex K on 8/30/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import "MapModel.h"
#import "IndexModel.h"
#import "LocationModel.h"
#import "MapItemsObserver.h"
#import "Category.h"
#import "PlaceItem.h"
#import "MapItem.h"
#import <CoreLocation/CoreLocation.h>

@interface MapModel ()

@property (strong, nonatomic) IndexModel *indexModel;
@property (strong, nonatomic) LocationModel *locationModel;
@property (strong, nonatomic) NSMutableSet *uuids;

@end

static const CLLocationDistance kCloseDistance = 200.0;
static const CLLocationDistance kMetersInKilometer = 1000.0;
static const CLLocationDistance kLocationAccuracy = 500.0;

@implementation MapModel

- (instancetype)initWithIndexModel:(IndexModel *)model
                     locationModel:(nonnull LocationModel *)locationModel{
        self = [super init];
        if (self) {
            self.indexModel = model;
            _locationModel = locationModel;
            self.mapItems = [[NSMutableArray alloc] init];
            self.closeMapItems = [[NSMutableArray alloc] init];
            self.uuids = [[NSMutableSet alloc] init];
            self.mapItemsObservers = [[NSMutableArray alloc] init];
            [self.indexModel addObserver:self];
            [self.locationModel addObserver:self];
        }
        return self;
}

- (void)onCategoriesUpdate:(nonnull NSArray<Category *> *)categories {
    [self fillMapItemsFromCategories:categories];
    [self updateCloseItems];
    [self notifyObservers];
}

- (void)onLocationUpdate:(CLLocation *)lastLocation {
    [self updateCloseItems];
}

- (void)onAuthorizationStatusChange:(CLAuthorizationStatus)status {
    [self updateCloseItems];
}

- (void)fillMapItemsFromCategories:(NSArray<Category *> *)categories {
    __weak typeof(self) weakSelf = self;
    [categories enumerateObjectsUsingBlock:^(Category * _Nonnull category, NSUInteger idx, BOOL * _Nonnull stop) {
        [weakSelf fillMapItemsFromCategories:category.categories];
        [category.items enumerateObjectsUsingBlock:^(PlaceItem * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![weakSelf.uuids containsObject:item.uuid]) {
                MapItem *mapItem = [[MapItem alloc] init];
                mapItem.coords = item.coords;
                mapItem.title = item.title;
                mapItem.correspondingPlaceItem = item;
                [weakSelf.mapItems addObject:mapItem];
                
                [weakSelf.uuids addObject:item.uuid];
            }
        }];
    }];
}

- (void)updateCloseItems {
    NSMutableArray<MapItem *> *closeItems = [[NSMutableArray alloc] init];
    [self.mapItems enumerateObjectsUsingBlock:^(MapItem * _Nonnull mapItem, NSUInteger idx, BOOL * _Nonnull stop) {
        if (self.locationModel.lastLocation) {
            CLLocation *lastLocation = self.locationModel.lastLocation;
            NSLog(@"Last location: %@", lastLocation);
            CLLocation *itemLocation = [[CLLocation alloc] initWithCoordinate:mapItem.coords altitude:0 horizontalAccuracy:kLocationAccuracy verticalAccuracy:kLocationAccuracy timestamp:NSDate.now];
            CLLocationDistance distance = [lastLocation distanceFromLocation:itemLocation] / kMetersInKilometer;
            NSLog(@"Distance: %f", distance);
            if (distance <= kCloseDistance) {
                [closeItems addObject:mapItem];
            }
        }
    }];
    [self.closeMapItems removeAllObjects];
    [self.closeMapItems addObjectsFromArray:closeItems];
}

- (void)addObserver:(nonnull id<MapItemsObserver>)observer {
    [self.mapItemsObservers addObject:observer];
}

- (void)notifyObservers {
    [self.mapItemsObservers enumerateObjectsUsingBlock:^(id<MapItemsObserver>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj onMapItemsUpdate:self.mapItems];
    }];
}

- (void)removeObserver:(nonnull id<MapItemsObserver>)observer {
    [self.mapItemsObservers removeObject:observer];
}

@end
