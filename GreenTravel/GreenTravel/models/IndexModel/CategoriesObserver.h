//
//  CategoriesObserver.h
//  GreenTravel
//
//  Created by Alex K on 8/28/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class Category;
@class PlaceItem;

@protocol CategoriesObserver <NSObject>

- (void)onCategoriesUpdate:(NSArray<Category *>*)categories;

@end

NS_ASSUME_NONNULL_END
