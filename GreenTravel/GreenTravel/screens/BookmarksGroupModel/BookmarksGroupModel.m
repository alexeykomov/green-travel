//
//  BookmarksModel.m
//  GreenTravel
//
//  Created by Alex K on 8/30/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import "BookmarksGroupModel.h"
#import "BookmarksModel.h"
#import "IndexModel.h"
#import "BookmarksGroupObserver.h"
#import "BookmarkItem.h"
#import "Category.h"
#import "PlaceItem.h"

@interface BookmarksGroupModel ()

@property (strong, nonatomic) IndexModel *indexModel;
@property (strong, nonatomic) BookmarksModel *bookmarksModel;
@property (strong, nonatomic) NSMutableSet<NSString*> *itemUUIDs;
@property (strong, nonatomic) NSMutableDictionary<NSString*, NSNumber*> *categoryTypeToBookmark;

@end

@implementation BookmarksGroupModel

- (instancetype)initWithIndexModel:(IndexModel *)indexModel
                    bookmarksModel:(BookmarksModel *)bookmarksModel {
    self = [super init];
    if (self) {
        _indexModel = indexModel;
        _bookmarksModel = bookmarksModel;
        _bookmarkItems = [[NSMutableArray alloc] init];
        _categoryTypeToBookmark = [[NSMutableDictionary alloc] init];
        _itemUUIDs = [[NSMutableSet alloc] init];
        _bookmarksGroupObservers = [[NSMutableArray alloc] init];
        [self.indexModel addObserver:self];
        [self.bookmarksModel addObserver:self];
    }
    return self;
}

- (void)onCategoriesUpdate:(nonnull NSArray<Category *> *)categories {
    [self fillBookmarkItemsFromCategories:categories];
    [self notifyObservers];
}

- (void)fillBookmarkItemsFromCategories:(NSArray<Category *> *)categories {
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
        [weakSelf fillBookmarkItemsFromCategories:category.categories];
        [category.items enumerateObjectsUsingBlock:^(PlaceItem * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![weakSelf.itemUUIDs containsObject:item.uuid] &&
                !!self.bookmarksModel.bookmarkItems[item.uuid]) {
                [weakSelf.itemUUIDs addObject:item.uuid];
                weakSelf.categoryTypeToBookmark[category.uuid] = @([weakSelf.categoryTypeToBookmark[category.uuid] intValue] + 1);
            }
        }];
    }];
    [self.bookmarkItems enumerateObjectsUsingBlock:^(BookmarkItem * _Nonnull bookmarkItem, NSUInteger idx, BOOL * _Nonnull stop) {
        bookmarkItem.howMany = [weakSelf.categoryTypeToBookmark[bookmarkItem.uuid] intValue];
    }];
}

- (void)addObserver:(nonnull id<BookmarksGroupObserver>)observer {
    [self.bookmarksGroupObservers addObject:observer];
}

- (void)notifyObservers {
    [self.bookmarksGroupObservers enumerateObjectsUsingBlock:^(id<BookmarksGroupObserver>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj onBookmarksUpdate:self.bookmarkItems];
    }];
}

- (void)removeObserver:(nonnull id<BookmarksGroupObserver>)observer {
    [self.bookmarksGroupObservers removeObject:observer];
}

- (void)onBookmarksUpdate:(nonnull NSDictionary<NSString *,PlaceItem *> *)bookmarkItems {
    [self fillBookmarkItemsFromCategories:self.indexModel.categories];
    [self notifyObservers];
}

@end
