//
//  CategoriesFilterObservervable.h
//  GreenTravel
//
//  Created by Alex K on 2/26/21.
//  Copyright © 2021 Alex K. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CategoriesFilterObserver;

@protocol CategoriesFilterObservable <NSObject>

@property (strong, nonatomic) NSMutableArray<id<CategoriesFilterObserver>> *categoriesFilterObservers;
@property (strong, nonatomic) NSMutableArray<id<CategoriesFilterObserver>> *categoriesFilterSelectObservers;
- (void)addObserver:(id<CategoriesFilterObserver>)observer;
- (void)removeObserver:(id<CategoriesFilterObserver>)observer;
- (void)notifyObservers;
- (void)notifyObserversFiterSelect;

@end

NS_ASSUME_NONNULL_END
