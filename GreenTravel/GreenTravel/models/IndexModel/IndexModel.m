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
#import "ApiService.h"
#import "CoreDataService.h"
#import "CategoryUtils.h"

@interface IndexModel ()

@property (strong, nonatomic) ApiService *apiService;
@property (strong, nonatomic) CoreDataService *coreDataService;
@property (assign, nonatomic) BOOL loaded;
- (NSArray<Category *>*)mergeCategoriesOld:(NSArray<Category *>*)oldCategories
                                   withNew:(NSArray<Category *>*)newCategories;

@end

@implementation IndexModel
 
static IndexModel *instance;

- (instancetype)initWithApiService:(ApiService *)apiService
                   coreDataService:(CoreDataService *)coreDataService
{
    self = [super init];
    if (self) {
        _categoriesObservers = [[NSMutableArray alloc] init];
        _coreDataService = coreDataService;
        _apiService = apiService;
        // TODO: IndexModel would benefit from subsribing to BookmarksModel updates
    }
    return self;
}

- (void)loadCategories {
    if (self.loaded) {
        return;
    }
    NSLog(@"loadCategories");
    __weak typeof(self) weakSelf = self;
    [self.coreDataService loadCategoriesWithCompletion:^(NSArray<Category *> * _Nonnull categories) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf updateCategories:categories];
        [strongSelf.apiService loadCategoriesWithCompletion:^(NSArray<Category *>  * _Nonnull categories) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            NSArray<Category*> *newCategories = [strongSelf mergeCategoriesOld:strongSelf.categories withNew:categories];
            if (!isCategoriesEqual(strongSelf.categories, newCategories)) {
                [strongSelf updateCategories:newCategories];
                [strongSelf.coreDataService saveCategories:newCategories];
            }
        }];
    }];
    self.loaded = YES;
}

- (NSArray<Category *>*)mergeCategoriesOld:(NSArray<Category *>*)oldCategories
                                   withNew:(NSArray<Category *>*)newCategories {
    NSMutableSet *uuids = [[NSMutableSet alloc] init];
    traverseCategories(oldCategories, ^(Category *category, PlaceItem *item) {
        if (item.bookmarked) {
            [uuids addObject:item.uuid];
        }
    });
    traverseCategories(newCategories, ^(Category *category, PlaceItem *item) {
        if ([uuids containsObject:item.uuid]) {
            item.bookmarked = YES;
        }
    });
    return newCategories;
}

- (void)updateCategories:(NSArray<Category *> *)categories {
    self.categories = categories;
    [self notifyObservers];
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

