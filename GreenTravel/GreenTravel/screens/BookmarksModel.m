//
//  BookmarksModel.m
//  GreenTravel
//
//  Created by Alex K on 8/30/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import "BookmarksModel.h"
#import "Category.h"
#import "IndexModel.h"
#import "BookmarksObserver.h"
#import "PlaceItem.h"
#import "BookmarkItem.h"

@interface BookmarksModel()

@property (strong, nonatomic) IndexModel *indexModel;
@property (strong, nonatomic) NSMutableDictionary<NSString*, NSNumber*> *categoryTypeToBookmark;

@end

@implementation BookmarksModel

- (instancetype)initWithIndexModel:(IndexModel *)model {
        self = [super init];
        if (self) {
            self.indexModel = model;
            self.bookmarkItems = [[NSMutableArray alloc] init];
            self.categoryTypeToBookmark = [[NSMutableDictionary alloc] init];
            self.bookmarksObservers = [[NSMutableArray alloc] init];
            [self.indexModel addObserver:self];
        }
        return self;
}

- (void)onCategoriesUpdate:(nonnull NSArray<Category *> *)categories {
    //[self fillMapItemsFromCategories:categories];
    [self notifyObservers];
}

//- (void)fillMapItemsFromCategories:(NSArray<Category *> *)categories {
//    __weak typeof(self) weakSelf = self;
//    [categories enumerateObjectsUsingBlock:^(Category * _Nonnull category, NSUInteger idx, BOOL * _Nonnull stop) {
//        if (!self.categoryTypeToBookmark[category.uuid]) {
//            BookmarkItem *bookmarkItem = [[BookmarkItem alloc] init];
//            bookmarkItem.correspondingCategory = category;
//            bookmarkItem.title = category.title;
//            bookmarkItem.uuid = category.uuid;
//
//            self.categoryTypeToBookmark[category.uuid] = @1;
//            [self.bookmarkItems addObject:bookmarkItem];
//        } else {
//            self.categoryTypeToBookmark[category.uuid] = self.categoryTypeToBookmark[category.uuid] + 1;
//        }
//        
//        [weakSelf fillMapItemsFromCategories:category.categories];
//        [category.items enumerateObjectsUsingBlock:^(PlaceItem * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
//            if (![weakSelf.uuids containsObject:item.uuid]) {
//                BookmarkItem *bookmarkItem = [[BookmarkItem alloc] init];
//                bookmarkItem.coords = item.coords;
//                bookmarkItem.title = item.title;
//                bookmarkItem.correspondingPlaceItem = item;
//                [bookmarkItem.bookmarkItems addObject:mapItem];
//                
//                [bookmarkItem.uuids addObject:item.uuid];
//            }
//        }];
//    }];
//}

- (void)addObserver:(nonnull id<BookmarksObserver>)observer {
    [self.bookmarksObservers addObject:observer];
}

- (void)notifyObservers {
    [self.bookmarksObservers enumerateObjectsUsingBlock:^(id<BookmarksObserver>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj onBookmarksUpdate:self.bookmarkItems];
    }];
}

- (void)removeObserver:(nonnull id<BookmarksObserver>)observer {
    [self.bookmarksObservers removeObject:observer];
}

@end
