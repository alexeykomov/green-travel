//
//  IndexModel.m
//  GreenTravel
//
//  Created by Alex K on 8/27/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import "IndexModel.h"
#import "CategoriesObserver.h"
#import "BookmarksModel.h"
#import "Category.h"
#import "PlaceItem.h"

@interface IndexModel ()

@property (strong, nonatomic) BookmarksModel *bookmarksModel;

@end

@implementation IndexModel 
 
static IndexModel *instance;

- (instancetype)initWithBookmarksModel:(BookmarksModel *)bookmarksModel
{
    self = [super init];
    if (self) {
        _categoriesObservers = [[NSMutableArray alloc] init];
        _bookmarksModel = bookmarksModel;
    }
    return self;
}

- (void)updateCategories:(NSArray<Category *> *)categories {
    self.categories = categories;
    [self fillItemsWithBookmarks:self.categories];
    [self notifyObservers];
}

- (void)fillItemsWithBookmarks:(NSArray<Category *>*)categories {
    __weak typeof(self) weakSelf = self;
    [categories enumerateObjectsUsingBlock:^(Category * _Nonnull category, NSUInteger idx, BOOL * _Nonnull stop) {
        [weakSelf fillItemsWithBookmarks:category.categories];
        [category.items enumerateObjectsUsingBlock:^(PlaceItem * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
            item.bookmarked = !!weakSelf.bookmarksModel.bookmarkItems[item.uuid];
        }];
    }];
}

- (void)addObserver:(nonnull id<CategoriesObserver>)observer {
    [self.categoriesObservers addObject:observer];
}

- (void)notifyObservers {
    __weak typeof(self) weakSelf = self;
    [self.categoriesObservers enumerateObjectsUsingBlock:^(id<CategoriesObserver>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj onCategoriesUpdate:weakSelf.categories];
    }];
}

- (void)removeObserver:(nonnull id<CategoriesObserver>)observer {
    [self.categoriesObservers removeObject:observer];
}

@end

