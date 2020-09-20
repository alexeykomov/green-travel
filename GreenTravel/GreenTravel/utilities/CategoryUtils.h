//
//  CategoryUtils.h
//  GreenTravel
//
//  Created by Alex K on 9/20/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Category;
@class PlaceItem;

void traverseCategories(NSArray<Category *> *categories, void(^onCategoryAndItem)(Category*, PlaceItem*));
BOOL isCategoriesEqual(NSArray<Category *> *categoriesA, NSArray<Category *> *categoriesB);
