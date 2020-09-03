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
@property (strong, nonatomic) NSMutableSet<NSString*> *itemUUIDs;

@end

@implementation BookmarksModel

- (instancetype)initWithIndexModel:(IndexModel *)model {
        self = [super init];
        if (self) {
            self.indexModel = model;
            self.bookmarkItems = [[NSMutableArray alloc] init];
            self.categoryTypeToBookmark = [[NSMutableDictionary alloc] init];
            self.itemUUIDs = [[NSMutableSet alloc] init];
            self.bookmarksObservers = [[NSMutableArray alloc] init];
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
        if (!weakSelf.categoryTypeToBookmark[category.uuid] && [category.categories count] == 0) {
            weakSelf.categoryTypeToBookmark[category.uuid] = @0;
            BookmarkItem *bookmarkItem = [[BookmarkItem alloc] init];
            bookmarkItem.correspondingCategory = category;
            bookmarkItem.howMany = 0;
            bookmarkItem.title = category.title;
            bookmarkItem.uuid = category.uuid;
            [weakSelf.bookmarkItems addObject:bookmarkItem];
        }
        [weakSelf fillMapItemsFromCategories:category.categories];
        [category.items enumerateObjectsUsingBlock:^(PlaceItem * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![weakSelf.itemUUIDs containsObject:item.uuid] &&
                item.bokmarked) {
                [weakSelf.itemUUIDs addObject:item.uuid];
                weakSelf.categoryTypeToBookmark[category.uuid] = @([weakSelf.categoryTypeToBookmark[category.uuid] intValue] + 1);
            }
        }];
    }];
    [self.bookmarkItems enumerateObjectsUsingBlock:^(BookmarkItem * _Nonnull bookmarkItem, NSUInteger idx, BOOL * _Nonnull stop) {
        bookmarkItem.howMany = [weakSelf.categoryTypeToBookmark[bookmarkItem.uuid] intValue];
    }];
}

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