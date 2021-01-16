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
#import "LocationModel.h"
#import "CoreDataService.h"
#import "CategoryUtils.h"

@interface SearchModel ()

@property (strong, nonatomic) IndexModel *indexModel;
@property (strong, nonatomic) LocationModel *locationModel;
@property (strong, nonatomic) NSMutableSet *uuids;
@property (strong, nonatomic) CoreDataService *coreDataService;

@end

@implementation SearchModel

- (instancetype)initWithIndexModel:(IndexModel *)model
                     locationModel:(LocationModel *)locationModel
                   coreDataService:(CoreDataService *)coreDataService
{
    self = [super init];
    if (self) {
        _indexModel = model;
        _locationModel = locationModel;
        _coreDataService = coreDataService;
        self.searchItems = [[NSMutableArray alloc] init];
        self.searchHistoryItems = [[NSMutableArray alloc] init];
        self.uuids = [[NSMutableSet alloc] init];
        self.searchItemsObservers = [[NSMutableArray alloc] init];
        [self.indexModel addObserver:self];
        [self.locationModel addObserver:self];
    }
    return self;
}
 
- (void)onCategoriesUpdate:(nonnull NSArray<Category *> *)categories {
    [self.searchItems removeAllObjects];
    [self.uuids removeAllObjects];
    [self fillSearchItemsFromCategories:categories];
    [self notifyObservers];
}

- (void)onBookmarkUpdate:(nonnull PlaceItem *)item bookmark:(BOOL)bookmark {}

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
    if ([self.searchItemsObservers containsObject:observer]) {
        return;
    }
    [self.searchItemsObservers addObject:observer];
}

- (void)notifyObservers {
    [self.searchItemsObservers enumerateObjectsUsingBlock:^(id<SearchItemsObserver>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj onSearchItemsUpdate:self.searchItems];
    }];
}

- (void)notifyObserversOfSearchHistoryUpdate {
    [self.searchItemsObservers enumerateObjectsUsingBlock:^(id<SearchItemsObserver>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj onSearchHistoryItemsUpdate:self.searchHistoryItems];
    }];
}

- (void)removeObserver:(nonnull id<SearchItemsObserver>)observer {
    [self.searchItemsObservers removeObject:observer];
}

- (void)onLocationUpdate:(CLLocation *)lastLocation {
    NSLog(@"Last location: %@", lastLocation);
    [self.searchItems enumerateObjectsUsingBlock:^(SearchItem * _Nonnull searchItem, NSUInteger idx, BOOL * _Nonnull stop) {
        CLLocation *itemLocation =
        [[CLLocation alloc] initWithCoordinate:searchItem.correspondingPlaceItem.coords
                                              altitude:0
                                    horizontalAccuracy:500.0
                                      verticalAccuracy:500.0
                                             timestamp:[[NSDate alloc] init]];
        searchItem.distance = [lastLocation distanceFromLocation:itemLocation] / 1000.0;
    }];
    [self notifyObservers];
}

- (void)onAuthorizationStatusChange:(CLAuthorizationStatus)status {
    
}

- (void)fillSearchItemsWithCategories {
    __weak typeof(self) weakSelf = self;
    traverseCategories(self.indexModel.categories, ^(Category *category, PlaceItem *item) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf.searchHistoryItems enumerateObjectsUsingBlock:^(SearchItem * _Nonnull searchItem, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([item.uuid isEqualToString:searchItem.correspondingPlaceItem.uuid]) {
                searchItem.correspondingPlaceItem.category = category;
            }
        }];
    });
}

- (void)loadSearchItems {
    __weak typeof(self) weakSelf = self;
    [self.coreDataService loadSearchItemsWithCompletion:^(NSArray<SearchItem *> * _Nonnull searchItems) {
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.searchHistoryItems = [[NSMutableArray alloc] initWithArray:searchItems];
        [strongSelf fillSearchItemsWithCategories];
        [strongSelf notifyObserversOfSearchHistoryUpdate];
    }];
}

- (void)addSearchHistoryItem:(SearchItem *)searchItem {
    NSUInteger foundIndex = [self findIndexOfSearchHistoryItem:searchItem];
    if (foundIndex != NSNotFound) {
        [self.searchHistoryItems removeObjectAtIndex:foundIndex];
    }
    [self.searchHistoryItems addObject:searchItem];
    [self.coreDataService addSearchItem:searchItem];
}

- (void)removeSearchHistoryItem:(SearchItem *)searchItem {
    NSUInteger foundIndex = [self findIndexOfSearchHistoryItem:searchItem];
    if (foundIndex == NSNotFound) {
        return;
    }
    [self.searchHistoryItems removeObjectAtIndex:foundIndex];
    [self.coreDataService removeSearchItem:searchItem];
}

- (NSUInteger)findIndexOfSearchHistoryItem:(SearchItem *)searchItem {
    NSUInteger foundIndex = [self.searchHistoryItems indexOfObjectPassingTest:^BOOL(SearchItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return [obj.correspondingPlaceItem.uuid isEqualToString:searchItem.correspondingPlaceItem.uuid];
    }];
    return foundIndex;
}

@end
