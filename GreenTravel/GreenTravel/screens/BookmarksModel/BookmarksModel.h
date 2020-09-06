//
//  BookmarksModel.h
//  GreenTravel
//
//  Created by Alex K on 9/6/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BookmarksObservable.h"

NS_ASSUME_NONNULL_BEGIN

@class PlaceItem;

@class IndexModel;
@protocol BookmarksGroupObserver;

@interface BookmarksModel : NSObject<BookmarksObservable>

- (instancetype)init;
@property (strong, nonatomic) NSMutableDictionary<NSString *, PlaceItem *> *bookmarkItems;
@property (strong, nonatomic) NSMutableArray<id<BookmarksObserver>> *bookmarksObservers;
- (void)fillItemsFromList:(NSArray<PlaceItem *> *)items;
- (void)updateBookmark:(PlaceItem *)placeItem bookmark:(BOOL)bookmark;

@end

NS_ASSUME_NONNULL_END
