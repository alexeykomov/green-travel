//
//  CategoriesObservable.h
//  GreenTravel
//
//  Created by Alex K on 8/28/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CategoriesObserver;

@protocol CategoriesObservable <NSObject>

@property (strong, nonatomic) NSMutableArray<id<CategoriesObserver>> *categoriesObservers;
- (void)addObserver:(id<CategoriesObserver>)observer;
- (void)removeObserver:(id<CategoriesObserver>)observer;
- (void)notifyObservers;

@end

NS_ASSUME_NONNULL_END
