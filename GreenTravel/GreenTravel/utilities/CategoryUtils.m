//
//  CategoryUtils.m
//  GreenTravel
//
//  Created by Alex K on 9/20/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import "CategoryUtils.h"
#import "Category.h"
#import "PlaceItem.h"

void traverseCategories(NSArray<Category *> *categories, void(^onCategoryAndItem)(Category*, PlaceItem*)) {
    [categories enumerateObjectsUsingBlock:^(Category * _Nonnull category, NSUInteger idx, BOOL * _Nonnull stop) {
        onCategoryAndItem(category, nil);
        [category.items enumerateObjectsUsingBlock:^(PlaceItem * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
            onCategoryAndItem(category, item);
        }];
        traverseCategories(category.categories, onCategoryAndItem);
    }];
    
}

BOOL isItemsEqual(NSArray<PlaceItem *> *itemsA, NSArray<PlaceItem *> *itemsB) {
    if ([itemsA count] != [itemsB count]) {
        return NO;
    }
    __block BOOL equal = YES;
    [itemsA enumerateObjectsUsingBlock:^(PlaceItem * _Nonnull itemA, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![itemA.uuid isEqualToString:itemsB[idx].uuid]) {
            equal = NO;
            *stop = YES;
        }
    }];
    return equal;
}

BOOL isCategoriesEqual(NSArray<Category *> *categoriesA, NSArray<Category *> *categoriesB) {
    if ([categoriesA count] != [categoriesB count]) {
        return NO;
    }
    __block BOOL equal = YES;
    [categoriesA enumerateObjectsUsingBlock:^(Category * _Nonnull category, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!isItemsEqual(category.items, categoriesB[idx].items)) {
            *stop = YES;
            equal = NO;
        }
        if (!isCategoriesEqual(category.categories, categoriesB[idx].categories)) {
            *stop = YES;
            equal = NO;
        }
    }];
    return equal;
}

