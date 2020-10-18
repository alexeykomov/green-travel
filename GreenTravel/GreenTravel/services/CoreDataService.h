//
//  CoreDataService.h
//  GreenTravel
//
//  Created by Alex K on 9/6/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@class PlaceItem;
@class Category;
@class BookmarksModel;
@class SearchItem;

@interface CoreDataService : NSObject

@property (readonly, strong) NSPersistentContainer *persistentContainer;
- (void)fetchStoredPlaceItems;
- (void)updatePlaceItem:(PlaceItem *)placeItem bookmark:(BOOL)bookmark;
- (void)loadCategoriesWithCompletion:(void(^)(NSArray<Category *>*))completion;
- (void)saveCategories:(NSArray<Category *> *)categories;
- (void)loadSearchItemsWithCompletion:(void(^)(NSArray<SearchItem *>*))completion;
- (void)addSearchItem:(SearchItem *)searchItem;
- (void)removeSearchItem:(SearchItem *)searchItem;

@end

NS_ASSUME_NONNULL_END
