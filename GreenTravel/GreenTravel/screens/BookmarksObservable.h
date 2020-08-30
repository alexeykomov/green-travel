//
//  SearchItemsObservable.h
//  GreenTravel
//
//  Created by Alex K on 8/29/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol BookmarksObserver;

@protocol BookmarksObservable <NSObject>

@property (strong, nonatomic) NSMutableArray<id<BookmarksObserver>> *bookmarksObservers;
- (void)addObserver:(id<BookmarksObserver>)observer;
- (void)removeObserver:(id<BookmarksObserver>)observer;
- (void)notifyObservers;

@end

NS_ASSUME_NONNULL_END

