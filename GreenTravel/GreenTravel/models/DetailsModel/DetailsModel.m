//
//  DetailsModel.m
//  GreenTravel
//
//  Created by Alex K on 9/5/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import "DetailsModel.h"
#import "Category.h"
#import "IndexModel.h"
#import "DetailsObserver.h"
#import "PlaceItem.h"
#import "BookmarkItem.h"
#import "ApiService.h"
#import "CoreDataService.h"

@interface DetailsModel()

@property (strong, nonatomic) IndexModel *indexModel;
@property (strong, nonatomic) NSMutableSet<NSString*> *itemUUIDs;
@property (strong, nonatomic) ApiService *apiService;
@property (strong, nonatomic) CoreDataService *coreDataService;

@end

@implementation DetailsModel

- (instancetype)initWithIndexModel:(IndexModel *)model
                        apiService:(nonnull ApiService *)apiService
                   coreDataService:(nonnull CoreDataService *)coreDataService {
        self = [super init];
        if (self) {
            _indexModel = model;
            _itemUUIDs = [[NSMutableSet alloc] init];
            _detailsObservers = [[NSMutableArray alloc] init];
            _itemUUIDToItem = [[NSMutableDictionary alloc] init];
            _itemUUIDToDetails = [[NSMutableDictionary alloc] init];
            _apiService = apiService;
            _coreDataService = coreDataService;
            [self.indexModel addObserver:self];
        }
        return self;
}

- (void)onCategoriesUpdate:(nonnull NSArray<Category *> *)categories {
    [self fillPlaceItemsFromCategories:categories];
    [self notifyObservers];
}

- (void)fillPlaceItemsFromCategories:(NSArray<Category *> *)categories {
    __weak typeof(self) weakSelf = self;
    [categories enumerateObjectsUsingBlock:^(Category * _Nonnull category, NSUInteger idx, BOOL * _Nonnull stop) {
        [weakSelf fillPlaceItemsFromCategories:category.categories];
        [category.items enumerateObjectsUsingBlock:^(PlaceItem * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![weakSelf.itemUUIDs containsObject:item.uuid]) {
                [weakSelf.itemUUIDToItem setValue:item forKey:item.uuid];
                [weakSelf.itemUUIDs addObject:item.uuid];
            }
        }];
    }];
}

- (void)updateDetails:(PlaceDetails *)details forUUID:(NSString *)uuid {
    [self.itemUUIDToDetails setValue:details forKey:uuid];
    [self notifyObservers];
}

- (void)loadDetailsByUUID:(NSString *)uuid {
    [self.apiService loadDetailsByUUID:uuid withCompletion:^(PlaceDetails * _Nonnull details) {
        
    }];
}

- (void)addObserver:(nonnull id<DetailsObserver>)observer {
    [self.detailsObservers addObject:observer];
}

- (void)notifyObservers {
    NSLog(@"notifyObservers");
    [self.detailsObservers enumerateObjectsUsingBlock:^(id<DetailsObserver>  _Nonnull observer, NSUInteger idx, BOOL * _Nonnull stop) {
        [observer onDetailsUpdate:self.itemUUIDToDetails items:self.itemUUIDToItem]; 
    }];
}

- (void)removeObserver:(nonnull id<DetailsObserver>)observer {
    [self.detailsObservers removeObject:observer];
}

@end
