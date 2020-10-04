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

#import "PlaceItem.h"
#import "Category.h"
#import "BookmarksModel.h"
#import "CategoryUtils.h"

@interface CoreDataService ()

{
NSPersistentContainer *_persistentContainer;
}

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
        }
    }
    return _persistentContainer;
}

- (void)updatePlaceItem:(PlaceItem *)placeItem bookmark:(BOOL)bookmark {
    [self.persistentContainer performBackgroundTask:^(NSManagedObjectContext *ctx) {
        NSFetchRequest *fetchRequest = [StoredCategory fetchRequest];
        NSError *error;
        NSArray<StoredCategory *> *fetchResult = [ctx executeFetchRequest:fetchRequest error:&error];
        traverseStoredCategories(fetchResult,
                                 ^(StoredCategory *category, StoredPlaceItem *storedPlaceItem) {
            if([storedPlaceItem.uuid isEqualToString:placeItem.uuid]){
                storedPlaceItem.bookmarked = bookmark;
            }
        });
        [ctx save:&error];
    }];
}

- (void)loadCategoriesWithCompletion:(void(^)(NSArray<Category *>*))completion {
    __weak typeof(self) weakSelf = self;
    [self.persistentContainer performBackgroundTask:^(NSManagedObjectContext *ctx) {
        NSFetchRequest *fetchRequest = [StoredCategory fetchRequest];
        NSError *error;
        NSArray<StoredCategory *> *fetchResult = [ctx executeFetchRequest:fetchRequest error:&error];
        NSMutableArray<Category *> *categories = [weakSelf mapStoredCategoriesToCategories:fetchResult];
        completion(categories);
    }];
}

- (NSMutableArray<Category *>*)mapStoredCategoriesToCategories:(NSArray<StoredCategory *>*)storedCategories {
    NSMutableArray<Category *> *categories = [[NSMutableArray alloc] init];
    __weak typeof(self) weakSelf = self;
    [storedCategories enumerateObjectsUsingBlock:^(StoredCategory * _Nonnull storedCategory, NSUInteger idx, BOOL * _Nonnull stop) {
        Category *category = [[Category alloc] init];
        category.title = storedCategory.title;
        category.uuid = storedCategory.uuid;
        category.cover = storedCategory.coverURL;
        NSMutableArray *items = [[NSMutableArray alloc] init];
        [storedCategory.items enumerateObjectsUsingBlock:^(StoredPlaceItem * _Nonnull storedItem, NSUInteger idx, BOOL * _Nonnull stop) {
            PlaceItem *item = [[PlaceItem alloc] init];
            item.title = storedItem.title;
            CLLocationCoordinate2D coords;
            [storedItem.coords getBytes:&coords length:sizeof(coords)];
            item.coords = coords;
            item.cover = storedItem.coverURL;
            item.bookmarked = storedItem.bookmarked;
            [items addObject:item];
        }];
        category.items = items;
        category.categories = [weakSelf mapStoredCategoriesToCategories:storedCategory.categories.array];
        [categories addObject:category];
    }];
    return categories;
}

- (void)saveCategories:(NSArray<Category *> *)categories {
    __weak typeof(self) weakSelf = self;
    [weakSelf.persistentContainer performBackgroundTask:^(NSManagedObjectContext *ctx) {
        NSError *error;
        [categories enumerateObjectsUsingBlock:^(Category * _Nonnull category, NSUInteger idx, BOOL * _Nonnull stop) {
            StoredCategory *storedCategory = [[StoredCategory alloc] initWithContext:ctx];
            storedCategory.title = category.title;
            [category.items enumerateObjectsUsingBlock:^(PlaceItem * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
                StoredPlaceItem *storedItem = [[StoredPlaceItem alloc] initWithContext:ctx];
                storedItem.title = item.title;
                CLLocationCoordinate2D coords = item.coords;
                NSData *coordsAsData = [NSData dataWithBytes:&coords
                                                      length:sizeof(item.coords)];
                storedItem.coords = coordsAsData;
                storedItem.coverURL = item.cover;
                storedItem.uuid = item.uuid;
                [storedCategory addItemsObject:storedItem];
            }];
            [weakSelf saveCategories:category.categories];
        }];
        [ctx save:&error];
    }];
}

@end
