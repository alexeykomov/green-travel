//
//  IndexModel.m
//  GreenTravel
//
//  Created by Alex K on 8/27/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import "IndexModel.h"
#import "CategoriesObserver.h"

@implementation IndexModel 
 
static IndexModel *instance;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _categoriesObservers = [[NSMutableArray alloc] init];
    }
    return self;
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

