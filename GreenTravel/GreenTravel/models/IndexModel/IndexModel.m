//
//  IndexModel.m
//  GreenTravel
//
//  Created by Alex K on 8/27/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import "IndexModel.h"
#import "CategoriesObserver.h"
#import "BookmarksObserver.h"
#import "Category.h"
#import "PlaceItem.h"
#import "ApiService.h"
#import "CoreDataService.h"
#import "CategoryUtils.h"
#import "UserDefaultsService.h"

@interface IndexModel ()

@property (strong, nonatomic) ApiService *apiService;
@property (strong, nonatomic) CoreDataService *coreDataService;
@property (strong, nonatomic) UserDefaultsService *userDefaultsService;
@property (assign, nonatomic) BOOL loadedFromDB;
@property (assign, nonatomic) BOOL loading;
@property (assign, nonatomic) BOOL loadingRemote;
@property (strong, nonatomic) NSArray<Category *> *categoriesRequestedToUpdate;
- (NSArray<Category *>*)copyBookmarksFromOldCategories:(NSArray<Category *>*)oldCategories
                                   toNew:(NSArray<Category *>*)newCategories;


@end

@implementation IndexModel
 
static IndexModel *instance;

- (instancetype)initWithApiService:(ApiService *)apiService
                   coreDataService:(CoreDataService *)coreDataService
               userDefaultsService:(UserDefaultsService *)userDefaultsService
{
    self = [super init];
    if (self) {
        _categoriesObservers = [[NSMutableArray alloc] init];
        _bookmarksObservers = [[NSMutableArray alloc] init];
        _coreDataService = coreDataService;
        _apiService = apiService;
        _userDefaultsService = userDefaultsService;
    }
    return self;
}

- (void)loadCategories {
    NSLog(@"loadCategories");
    __weak typeof(self) weakSelf = self;
    if (self.loadedFromDB) {
        [self loadCategoriesRemote];
        return;
    }
    [self.coreDataService loadCategoriesWithCompletion:^(NSArray<Category *> * _Nonnull categories) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf updateCategories:categories];
        [strongSelf loadCategoriesRemote];
        strongSelf.loadedFromDB = YES;
    }];
}

- (void)loadCategoriesRemote {
    __weak typeof(self) weakSelf = self;
    [self.apiService loadCategoriesWithCompletion:^(NSArray<Category *>  * _Nonnull categories, NSString *eTag) {
        __strong typeof(self) strongSelf = weakSelf;
        NSString *existingETag = [strongSelf.userDefaultsService loadETag];
        if (![existingETag isEqualToString:eTag]) {
            NSArray<Category*> *newCategories =
            [strongSelf copyBookmarksFromOldCategories:strongSelf.categories
                                                 toNew:categories];
            [strongSelf.userDefaultsService saveETag:eTag];
            [strongSelf requestCategoriesUpdate:newCategories];
            [strongSelf.coreDataService saveCategories:newCategories];
        }
    }];
}

- (NSArray<Category *>*)copyBookmarksFromOldCategories:(NSArray<Category *>*)oldCategories
                                   toNew:(NSArray<Category *>*)newCategories {
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

- (void)bookmarkItem:(PlaceItem *)item bookmark:(BOOL)bookmark {
    item.bookmarked = bookmark;
    [self.coreDataService updatePlaceItem:item bookmark:bookmark];
    [self notifyObserversBookmarks:item bookmark:bookmark];
}

- (void)updateCategories:(NSArray<Category *> *)categories {
    self.categories = categories;
    [self notifyObservers];
}

- (void)requestCategoriesUpdate:(NSArray<Category *> *)categories {
    // TODO: change this to show "new content is available" widget
    self.categories = categories;
    [self notifyObservers];
}

- (BOOL)isEmpty {
    return [self.categories count] == 0;
}

- (BOOL)loading {
    return [self.categories count] == 0 && self.loadingRemote;
}

- (void)addObserver:(nonnull id<CategoriesObserver>)observer {
    if ([self.categoriesObservers containsObject:observer]) {
        return;
    }
    [self.categoriesObservers addObject:observer];
}

- (void)notifyObservers {
    __weak typeof(self) weakSelf = self;
    [self.categoriesObservers enumerateObjectsUsingBlock:^(id<CategoriesObserver>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj onCategoriesUpdate:weakSelf.categories];
    }];
}

- (void)notifyObserversNewDataAvailable {
    [self.categoriesObservers enumerateObjectsUsingBlock:^(id<CategoriesObserver>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj onCategoriesNewDataAvailable];
    }];
}

- (void)notifyObserversLoading:(BOOL)loading {
    [self.categoriesObservers enumerateObjectsUsingBlock:^(id<CategoriesObserver>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj onCategoriesLoading:loading];
    }];
}

- (void)removeObserver:(nonnull id<CategoriesObserver>)observer {
    if ([self.categoriesObservers containsObject:observer]) {
        return;
    }
    [self.categoriesObservers removeObject:observer];
}

- (void)notifyObserversBookmarks:(PlaceItem *)item bookmark:(BOOL)bookmark {
    [self.bookmarksObservers enumerateObjectsUsingBlock:^(id<BookmarksObserver>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj onBookmarkUpdate:item bookmark:bookmark];
    }];
}

- (void)addObserverBookmarks:(nonnull id<BookmarksObserver>)observer {
    if ([self.bookmarksObservers containsObject:observer]) {
        return;
    }
    [self.bookmarksObservers addObject:observer];
}

- (void)removeObserverBookmarks:(nonnull id<BookmarksObserver>)observer {
    if ([self.bookmarksObservers containsObject:observer]) {
        return;
    }
    [self.bookmarksObservers removeObject:observer];
}



@end

