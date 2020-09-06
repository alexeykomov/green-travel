//
//  IndexModel.h
//  GreenTravel
//
//  Created by Alex K on 8/27/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CategoriesObservable.h"
#import "CategoriesObserver.h"

NS_ASSUME_NONNULL_BEGIN

@class Category;
@class PlaceItem;
@class PathItem;
@class PlaceDetails;
@class PathDetails;
@class CategoriesObserver;
@class BookmarksModel;

@interface IndexModel : NSObject<CategoriesObservable>

@property (strong, nonatomic) NSMutableArray<id<CategoriesObserver>> *categoriesObservers; 
@property (strong, nonatomic) NSArray<Category *> *categories;
@property (strong, nonatomic) NSArray<PlaceItem *> *searchItems;
@property (strong, nonatomic) NSDictionary<NSString *, Category *> *categoryByUUID;
@property (strong, nonatomic) NSDictionary<NSString *, PlaceDetails *> *placesByUUID;
@property (strong, nonatomic) NSDictionary<NSString *, PathDetails *> *pathsByUUID;
- (instancetype)initWithBookmarksModel:(BookmarksModel *)bookmarksModel;
- (void)updateCategories:(NSArray<Category *> *)categories;

@end

NS_ASSUME_NONNULL_END
