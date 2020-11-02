//
//  CoreDataService.m
//  GreenTravel
//
//  Created by Alex K on 9/6/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import "CoreDataService.h"
#import <CoreData/CoreData.h>
#import "StoredPlaceItem+CoreDataProperties.h"
#import "StoredCategory+CoreDataProperties.h"
#import "StoredSearchItem+CoreDataProperties.h"
#import "StoredPlaceDetails+CoreDataProperties.h"

#import "PlaceItem.h"
#import "Category.h"
#import "SearchItem.h"
#import "BookmarksModel.h"
#import "CategoryUtils.h"
#import "PlaceDetails.h"
#import "TextUtils.h"

@interface CoreDataService ()

{
NSPersistentContainer *_persistentContainer;
}

@property (strong, nonatomic) NSManagedObjectContext *ctx;

@end

@implementation CoreDataService

- (NSPersistentContainer *)persistentContainer {
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [NSPersistentContainer  persistentContainerWithName:@"GreenTravel"];
            
            [_persistentContainer loadPersistentStoresWithCompletionHandler:
             ^(NSPersistentStoreDescription *storeDescription, NSError *error) {
              if (error != nil) {
                NSLog(@"Failed to load store: %@", error);
                abort();
              }
            }];
            
            _ctx = _persistentContainer.newBackgroundContext;
        }
    }
    return _persistentContainer;
}

#pragma mark - PlaceItem

- (void)updatePlaceItem:(PlaceItem *)placeItem bookmark:(BOOL)bookmark {
    [self.persistentContainer performBackgroundTask:^(NSManagedObjectContext *ctx) {
        NSFetchRequest *fetchRequest = [StoredCategory fetchRequest];
        NSError *error;
        NSArray<StoredCategory *> *fetchResult = [ctx executeFetchRequest:fetchRequest error:&error];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"parent == %@", nil];
        traverseStoredCategories(fetchResult,
                                 ^(StoredCategory *category, StoredPlaceItem *storedPlaceItem) {
            if([storedPlaceItem.uuid isEqualToString:placeItem.uuid]){
                storedPlaceItem.bookmarked = bookmark;
            }
        });
        [ctx save:&error];
    }];
}

#pragma mark - Categories

- (void)loadCategoriesWithCompletion:(void(^)(NSArray<Category *>*))completion {
    __weak typeof(self) weakSelf = self;
    [self.persistentContainer performBackgroundTask:^(NSManagedObjectContext *ctx) {
        NSFetchRequest *fetchRequest = [StoredCategory fetchRequest];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"parent == %@", nil];
        NSError *error;
        NSArray<StoredCategory *> *fetchResult = [ctx executeFetchRequest:fetchRequest error:&error];
        NSMutableArray<Category *> *categories = [weakSelf mapStoredCategoriesToCategories:fetchResult];
        completion(categories);
    }];
}

- (PlaceItem *)mapStoredPlaceItemToPlaceItem:(StoredPlaceItem *)storedItem
                                withCategory:(Category *)category {
    PlaceItem *item = [[PlaceItem alloc] init];
    item.title = storedItem.title;
    item.uuid = storedItem.uuid;
    item.category = category;
    CLLocationCoordinate2D coords;
    [storedItem.coords getBytes:&coords length:sizeof(coords)];
    item.coords = coords;
    item.cover = storedItem.coverURL;
    item.bookmarked = storedItem.bookmarked;
    return item;
}

- (Category *)mapStoredCategoryToCategory:(StoredCategory *)storedCategory {
    Category *category = [[Category alloc] init];
    category.title = storedCategory.title;
    category.uuid = storedCategory.uuid;
    category.cover = storedCategory.coverURL;
    NSMutableArray *items = [[NSMutableArray alloc] init];
    [storedCategory.items enumerateObjectsUsingBlock:^(StoredPlaceItem * _Nonnull storedItem, NSUInteger idx, BOOL * _Nonnull stop) {
        [items addObject:[self mapStoredPlaceItemToPlaceItem:storedItem withCategory:category]];
    }];
    category.items = items;
    category.categories = [self mapStoredCategoriesToCategories:storedCategory.categories.array];
    return category;
}
    

- (NSMutableArray<Category *>*)mapStoredCategoriesToCategories:(NSArray<StoredCategory *>*)storedCategories {
    NSMutableArray<Category *> *categories = [[NSMutableArray alloc] init];
    __weak typeof(self) weakSelf = self;
    [storedCategories enumerateObjectsUsingBlock:^(StoredCategory * _Nonnull storedCategory, NSUInteger idx, BOOL * _Nonnull stop) {
        Category *category = [weakSelf mapStoredCategoryToCategory:storedCategory];
        [categories addObject:category];
    }];
    return categories;
}

- (void)saveCategories:(NSArray<Category *> *)categories {
    __weak typeof(self) weakSelf = self;
    [self.ctx performBlockAndWait:^{
        NSError *error;
        
        NSFetchRequest *fetchRequest = [StoredCategory fetchRequest];
        NSArray<StoredCategory *> *fetchResult = [weakSelf.ctx executeFetchRequest:fetchRequest error:&error];
        
        [fetchResult enumerateObjectsUsingBlock:^(StoredCategory * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [weakSelf.ctx deleteObject:obj];
        }];
        [weakSelf.ctx save:&error];
        fetchResult = [weakSelf.ctx executeFetchRequest:fetchRequest error:&error];
        
        if ([categories count]) {
            [weakSelf saveCategoriesWithinBlock:categories parentCategory:nil];
        }
    }];
}

- (void)saveCategoriesWithinBlock:(NSArray<Category *> *)categories
        parentCategory:(StoredCategory *)parentCategory {
    __weak typeof(self) weakSelf = self;
    [categories enumerateObjectsUsingBlock:^(Category * _Nonnull category, NSUInteger idx, BOOL * _Nonnull stop) {
        NSError *error;
        StoredCategory *storedCategory = [NSEntityDescription insertNewObjectForEntityForName:@"StoredCategory" inManagedObjectContext:weakSelf.ctx];
        storedCategory.title = category.title;
        storedCategory.uuid = category.uuid;
        storedCategory.coverURL = category.cover;
        storedCategory.parent = parentCategory;
        [category.items enumerateObjectsUsingBlock:^(PlaceItem * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
            StoredPlaceItem *storedItem = [NSEntityDescription insertNewObjectForEntityForName:@"StoredPlaceItem" inManagedObjectContext:weakSelf.ctx];
            storedItem.title = item.title;
            CLLocationCoordinate2D coords = item.coords;
            NSData *coordsAsData = [NSData dataWithBytes:&coords
                                                  length:sizeof(item.coords)];
            storedItem.coords = coordsAsData;
            storedItem.coverURL = item.cover;
            storedItem.uuid = item.uuid;
            storedItem.bookmarked = item.bookmarked;
            [storedCategory addItemsObject:storedItem];
        }];
        [parentCategory addCategoriesObject:storedCategory];
        if ([category.categories count]) {
            [weakSelf saveCategoriesWithinBlock:category.categories parentCategory:storedCategory];
        }
        [weakSelf.ctx save:&error];
    }];
}

#pragma mark - Search items
 
- (void)addSearchItem:(SearchItem *)searchItem {
    __weak typeof(self) weakSelf = self;
    [self.persistentContainer performBackgroundTask:^(NSManagedObjectContext *ctx) {
        __strong typeof(self) strongSelf = weakSelf;
        NSError *error;
        // Delete dublicate.
        [strongSelf removeSearchItem:searchItem];
        // Request place item.
        NSFetchRequest *fetchRequestItem = [StoredPlaceItem fetchRequest];
        fetchRequestItem.predicate = [NSPredicate predicateWithFormat:@"uuid == %@",
                                  searchItem.correspondingPlaceItem.uuid];
        NSArray<StoredPlaceItem *> *fetchResultItem = [ctx executeFetchRequest:fetchRequestItem error:&error];
        StoredPlaceItem *item = [fetchResultItem firstObject];
        // Request order.
        NSFetchRequest *fetchRequestSearchItem = [StoredSearchItem fetchRequest];
        NSUInteger count = [strongSelf.ctx
                            countForFetchRequest:fetchRequestSearchItem
                            error:&error];
        // Create new search item.
        StoredSearchItem *storedSearchItem = [NSEntityDescription insertNewObjectForEntityForName:@"StoredSearchItem" inManagedObjectContext:ctx];
        storedSearchItem.order = count;
        storedSearchItem.correspondingPlaceItem = item;
        [ctx save:&error];
    }];
}

- (void)removeSearchItem:(SearchItem *)searchItem {
    __weak typeof(self) weakSelf = self;
    __block StoredSearchItem *foundItem;
    [self.ctx performBlockAndWait:^{
        __strong typeof(self) strongSelf = weakSelf;
        NSError *error;
        NSFetchRequest *fetchRequestSearchItem = [StoredSearchItem fetchRequest];
        fetchRequestSearchItem.predicate = [NSPredicate predicateWithFormat:@"correspondingPlaceItem.uuid == %@",
                                  searchItem.correspondingPlaceItem.uuid];
        NSArray<StoredSearchItem *> *fetchResultSearchItem = [strongSelf.ctx
                                                              executeFetchRequest:fetchRequestSearchItem
                                                              error:&error];
        foundItem = [fetchResultSearchItem firstObject];
        if (foundItem) {
            [weakSelf.ctx deleteObject:foundItem];
            [weakSelf.ctx save:&error];
        }
    }];
    if (foundItem) {
        [weakSelf reorder];
    }
}

- (void)reorder {
    __weak typeof(self) weakSelf = self;
    [self.ctx performBlockAndWait:^{
        NSError *error;
        NSFetchRequest *fetchRequestSearchItem = [StoredSearchItem fetchRequest];
        NSSortDescriptor *sortByOrder = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
        fetchRequestSearchItem.sortDescriptors = @[sortByOrder];
        NSArray<StoredSearchItem *> *fetchResultSearchItem = [weakSelf.ctx executeFetchRequest:fetchRequestSearchItem error:&error];
        [fetchResultSearchItem enumerateObjectsUsingBlock:^(StoredSearchItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.order = idx;
        }];
        [weakSelf.ctx save:&error];
    }];
}

- (void)loadSearchItemsWithCompletion:(void (^)(NSArray<SearchItem *> * _Nonnull))completion {
    __weak typeof(self) weakSelf = self;
    [self.ctx performBlockAndWait:^{
        __strong typeof(self) strongSelf = weakSelf;
        NSError *error;
        NSMutableArray *searchItems = [[NSMutableArray alloc] init];
        NSFetchRequest *fetchRequestSearchItem = [StoredSearchItem fetchRequest];
        NSSortDescriptor *sortByOrder = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:NO];
        fetchRequestSearchItem.sortDescriptors = @[sortByOrder];
        NSArray<StoredSearchItem *> *fetchResultSearchItem = [strongSelf.ctx executeFetchRequest:fetchRequestSearchItem error:&error];
        [fetchResultSearchItem enumerateObjectsUsingBlock:^(StoredSearchItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            PlaceItem *placeItem = [self mapStoredPlaceItemToPlaceItem:obj.correspondingPlaceItem
                                                          withCategory:nil];
            SearchItem *searchItem = [[SearchItem alloc] init];
            searchItem.title = obj.correspondingPlaceItem.title;
            searchItem.correspondingPlaceItem = placeItem;
            [searchItems addObject:searchItem];
        }];
        completion(searchItems);
    }];
}

- (void)loadDetailsByUUID:(NSString *)uuid withCompletion:(void (^)(PlaceDetails *))completion {
    __weak typeof(self) weakSelf = self;
    [self.ctx performBlockAndWait:^{
        __strong typeof(self) strongSelf = weakSelf;
        NSError *error;
        NSFetchRequest *fetchRequestSearchItem = [StoredPlaceDetails fetchRequest];
        fetchRequestSearchItem.predicate = [NSPredicate predicateWithFormat:@"uuid == %@", uuid];
        NSArray<StoredPlaceDetails *> *fetchResult = [strongSelf.ctx executeFetchRequest:fetchRequestSearchItem error:&error];
        StoredPlaceDetails *storedDetails = [fetchResult firstObject];
        if (storedDetails) {
            PlaceDetails *details = [[PlaceDetails alloc] init];
            details.address = storedDetails.address;
            details.images = [storedDetails.imageURLs componentsSeparatedByString:@","];
            details.descriptionHTML = storedDetails.descriptionHTML;
            completion(details);
            return;
        }
        completion(nil);
    }];
}

- (void)savePlaceDetails:(PlaceDetails *)details forUUID:(NSString *)uuid {
    __weak typeof(self) weakSelf = self;
    [self.ctx performBlockAndWait:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSError *error;
        NSFetchRequest *fetchRequestSearchItem = [StoredPlaceDetails fetchRequest];
        fetchRequestSearchItem.predicate = [NSPredicate predicateWithFormat:@"uuid == %@", uuid];
        NSArray<StoredPlaceDetails *> *fetchResult = [strongSelf.ctx executeFetchRequest:fetchRequestSearchItem error:&error];
        StoredPlaceDetails *storedDetails = [fetchResult firstObject];
        if (storedDetails) {
            [strongSelf.ctx deleteObject:storedDetails];
            [strongSelf.ctx save:&error];
        };
        storedDetails = [NSEntityDescription insertNewObjectForEntityForName:@"StoredPlaceDetails" inManagedObjectContext:strongSelf.ctx];
        storedDetails.uuid = uuid;
        storedDetails.address = details.address;
        storedDetails.descriptionHTML = details.descriptionHTML;
        storedDetails.imageURLs = [details.images componentsJoinedByString:@","];
        [strongSelf.ctx save:&error];
    }];
}

@end
