//
//  SearchModel.m
//  GreenTravel
//
//  Created by Alex K on 8/29/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import "SearchModel.h"
#import "IndexModel.h"
#import "SearchItemsObserver.h"
#import "Category.h"
#import "SearchItem.h"
#import "PlaceItem.h"

@interface SearchModel ()

@property (strong, nonatomic) IndexModel *indexModel;
@property (strong, nonatomic) NSMutableSet *uuids;

@end

@implementation SearchModel

- (instancetype)initWithIndexModel:(IndexModel *)model
{
    self = [super init];
    if (self) {
        self.indexModel = model;
        self.searchItems = [[NSMutableArray alloc] init];
        self.uuids = [[NSMutableSet alloc] init];
        self.searchItemsObservers = [[NSMutableArray alloc] init];
        [self.indexModel addObserver:self];
    }
    return self;
}
 
- (void)onCategoriesUpdate:(nonnull NSArray<Category *> *)categories {
    [self.searchItems removeAllObjects];
    [self.uuids removeAllObjects];
    [self fillSearchItemsFromCategories:categories];
    [self notifyObservers];
}

- (void)fillSearchItemsFromCategories:(NSArray<Category *>*)categories {
    __weak typeof(self) weakSelf = self;
    [categories enumerateObjectsUsingBlock:^(Category * _Nonnull category, NSUInteger idx, BOOL * _Nonnull stop) {
        [weakSelf fillSearchItemsFromCategories:category.categories];
        [category.items enumerateObjectsUsingBlock:^(PlaceItem * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![weakSelf.uuids containsObject:item.uuid]) {
                SearchItem *searchItem = [[SearchItem alloc] init];
                searchItem.correspondingPlaceItem = item;
                searchItem.title = item.title;
                // TODO: Take into account when Geolocation is enabled.
                searchItem.distance = -1;
                
                [weakSelf.searchItems addObject:searchItem];
                [weakSelf.uuids addObject:item.uuid];
            }
        }];
    }];
}

- (void)addObserver:(nonnull id<SearchItemsObserver>)observer {
    [self.searchItemsObservers addObject:observer];
}

- (void)notifyObservers {
    [self.searchItemsObservers enumerateObjectsUsingBlock:^(id<SearchItemsObserver>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj onSearchItemsUpdate:self.searchItems];
    }];
}

- (void)removeObserver:(nonnull id<SearchItemsObserver>)observer {
    [self.searchItemsObservers removeObject:observer];
}

@end
