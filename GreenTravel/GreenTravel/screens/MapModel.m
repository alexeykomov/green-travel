//
//  MapModel.m
//  GreenTravel
//
//  Created by Alex K on 8/30/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import "MapModel.h"
#import "IndexModel.h"
#import "MapItemsObserver.h"
#import "Category.h"
#import "PlaceItem.h"
#import "MapItem.h"

@interface MapModel ()

@property (strong, nonatomic) IndexModel *indexModel;
@property (strong, nonatomic) NSMutableSet *uuids;

@end

@implementation MapModel

- (instancetype)initWithIndexModel:(IndexModel *)model {
        self = [super init];
        if (self) {
            self.indexModel = model;
            self.mapItems = [[NSMutableArray alloc] init];
            self.uuids = [[NSMutableSet alloc] init];
            self.mapItemsObservers = [[NSMutableArray alloc] init];
            [self.indexModel addObserver:self];
        }
        return self;
}

- (void)onCategoriesUpdate:(nonnull NSArray<Category *> *)categories {
    [self fillMapItemsFromCategories:categories];
    [self notifyObservers];
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
