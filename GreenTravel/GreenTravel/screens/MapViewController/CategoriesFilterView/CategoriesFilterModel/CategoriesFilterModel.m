//
//  CategoriesFilterModel.m
//  GreenTravel
//
//  Created by Alex K on 2/26/21.
//  Copyright © 2021 Alex K. All rights reserved.
//

#import "CategoriesFilterModel.h"
#import "FilterOption.h"
#import "Category.h"
#import "IndexModel.h"

@interface CategoriesFilterModel()

@property (strong, nonatomic) IndexModel *indexModel;

@end

@implementation CategoriesFilterModel

- (instancetype)initWithIndexModel:(IndexModel *)indexModel
{
    self = [super init];
    if (self) {
        _indexModel = indexModel;
        [_indexModel addObserver:self];
    }
    return self;
}

- (void)onCategoriesLoading:(BOOL)loading {
}

- (void)onCategoriesNewDataAvailable {
}

- (void)onCategoriesUpdate:(nonnull NSArray<Category *> *)categories {
    NSMutableArray<FilterOption *> *filterOptions = [[NSMutableArray alloc] init];
    [categories enumerateObjectsUsingBlock:^(Category * _Nonnull category, NSUInteger idx, BOOL * _Nonnull stop) {
        FilterOption *filterOption = [[FilterOption alloc] init];
        filterOption.categoryId = category.uuid;
        filterOption.on = NO;
        filterOption.all = NO;
        [filterOptions addObject:filterOption];
    }];
    
    FilterOption *filterOptionAll = [[FilterOption alloc] init];
    filterOptionAll.categoryId = nil;
    filterOptionAll.on = YES;
    filterOptionAll.all = YES;
    
    [filterOptions addObject:filterOptionAll];
    self.filterOptions = filterOptions;
    
    [self notifyObservers:self.filterOptions];
}

- (void)addObserver:(nonnull id<CategoriesFilterObserver>)observer {
    if ([self.observers containsObject:observer]) {
        return;
    }
    [self.observers addObject:observer];
}

- (void)notifyObservers {
    [self.observers enumerateObjectsUsingBlock:^(CategoriesFilterObserver * _Nonnull obsever, NSUInteger idx, BOOL * _Nonnull stop) {
        [observer onFilterOptionsUpdate:self.filterOptions];
    }];
}

- (void)removeObserver:(nonnull id<CategoriesFilterObserver>)observer {
    [self.observers removeObject:observer];
}

- (void)selectOption:(FilterOption *)selectedOption {
    [self.filterOptions enumerateObjectsUsingBlock:^(FilterOption * _Nonnull option, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([option.categoryId isEqualToString:selectedOption.categoryId]) {
            option.on = !option.on;
            if (selectedOption.on) {
                [self.selectedCategoryUUIDs addObject:selectedOption.categoryId];
                return;
            }
            [self.selectedCategoryUUIDs removeObject:selectedOption.categoryId];
        }
    }];
    [self notifyObserversFilterSelect:selectedOption];
}

- (void)notifyObserversFilterSelect:(FilterOptions *)selectedOption {
    [self.categoriesFilterSelectObservers enumerateObjectsUsingBlock:^(CategoriesFilterObserver * _Nonnull obsever, NSUInteger idx, BOOL * _Nonnull stop) {
        [observer onFilterOptionsSelect:selectedOption];
    }];
}


@end
