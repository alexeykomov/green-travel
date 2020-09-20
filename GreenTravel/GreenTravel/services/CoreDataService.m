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
#import "PlaceItem.h"
#import "Category.h"
#import "BookmarksModel.h"

@interface CoreDataService ()

{
NSPersistentContainer *_persistentContainer;
}

@property (strong, nonatomic) dispatch_queue_global_t queue;
@property (strong, nonatomic) BookmarksModel *bookmarksModel;

@end

@implementation CoreDataService

- (instancetype)initWithBookmarksModel:(BookmarksModel *)bookmarksModel
{
    self = [super init];
    if (self) {
        _queue = dispatch_get_global_queue(QOS_CLASS_UTILITY, 0);
        _bookmarksModel = bookmarksModel;
    }
    return self;
}

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

- (void)fetchStoredPlaceItems {
    __weak typeof(self) weakSelf = self;
    
    [self.persistentContainer performBackgroundTask:^(NSManagedObjectContext *ctx) {
        NSFetchRequest *fetchRequest = [StoredPlaceItem fetchRequest];
        NSError *error;
        NSArray<StoredPlaceItem *> *fetchResult = [ctx executeFetchRequest:fetchRequest error:&error];
        NSMutableArray<PlaceItem *> *outputResult = [[NSMutableArray alloc] init];
        [fetchResult enumerateObjectsUsingBlock:^(StoredPlaceItem * _Nonnull storedPlaceItem, NSUInteger idx, BOOL * _Nonnull stop) {
            PlaceItem *item = [[PlaceItem alloc] init];
            item.bookmarked = YES;
            item.uuid = storedPlaceItem.uuid;
            CLLocationCoordinate2D coords;
            [storedPlaceItem.coords getBytes:&coords length:sizeof(coords)];
            item.coords = coords;
            item.cover = storedPlaceItem.coverURL;
            [outputResult addObject:item];
        }];
        [weakSelf.bookmarksModel fillItemsFromList:outputResult];
    }];
}

- (void)updatePlaceItem:(PlaceItem *)placeItem bookmark:(BOOL)bookmark {
    __weak typeof(self) weakSelf = self;
    
    [weakSelf.persistentContainer performBackgroundTask:^(NSManagedObjectContext *ctx) {
        NSFetchRequest *fetchRequest = [StoredPlaceItem fetchRequest];
        NSError *error;
        NSArray<StoredPlaceItem *> *fetchResult = [ctx executeFetchRequest:fetchRequest error:&error];
        __block StoredPlaceItem *foundStoredPlaceItem;
        [fetchResult enumerateObjectsUsingBlock:^(StoredPlaceItem * _Nonnull storedPlaceItem, NSUInteger idx, BOOL * _Nonnull stop) {
            NSLog(@"StoredPlaceItem uuid: %@", storedPlaceItem.uuid);
            if([storedPlaceItem.uuid isEqualToString:placeItem.uuid]){
                foundStoredPlaceItem = storedPlaceItem;
            }
        }];
        if (foundStoredPlaceItem && bookmark) {
            // Do nothing, item is already in db.
            return;
        }
        if (!foundStoredPlaceItem && bookmark) {
            StoredPlaceItem *storedPlaceItem = [[StoredPlaceItem alloc] initWithContext:ctx];
            storedPlaceItem.uuid = placeItem.uuid;
            storedPlaceItem.title = placeItem.title;
            CLLocationCoordinate2D coords = placeItem.coords;
            NSData *coordsAsData = [NSData dataWithBytes:&coords
                                                  length:sizeof(placeItem.coords)];
            storedPlaceItem.coords = coordsAsData;
            storedPlaceItem.bookmarked = YES;
            [ctx save:&error];
        }
        if (foundStoredPlaceItem && !bookmark) {
            [ctx deleteObject:foundStoredPlaceItem];
            [ctx save:&error];
        }
    }];
}

- (void)saveCategories:(NSArray<Category *> *)categories {
    [categories enumerateObjectsUsingBlock:^(Category * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        *stop = YES;
    }];
}

@end
