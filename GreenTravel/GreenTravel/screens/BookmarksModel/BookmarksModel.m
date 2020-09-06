//
//  BookmarksModel.m
//  GreenTravel
//
//  Created by Alex K on 9/6/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import "BookmarksModel.h"
#import "Category.h"
#import "IndexModel.h"
#import "BookmarksObserver.h"
#import "PlaceItem.h"
#import "BookmarkItem.h"
#import "BookmarkItem.h"

@interface BookmarksModel()

@property (strong, nonatomic) NSMutableDictionary<NSString*, NSNumber*> *categoryTypeToBookmark;
@property (strong, nonatomic) NSMutableSet<NSString*> *itemUUIDs;

@end

@implementation BookmarksModel

- (instancetype)init {
        self = [super init];
        if (self) {
            self.bookmarkItems = [[NSMutableDictionary alloc] init];
            self.itemUUIDs = [[NSMutableSet alloc] init];
            self.bookmarksObservers = [[NSMutableArray alloc] init];
        }
        return self;
}

- (void)fillItemsFromList:(NSArray<PlaceItem *> *)items {
    __weak typeof(self) weakSelf = self;
    [items enumerateObjectsUsingBlock:^(PlaceItem * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![weakSelf.itemUUIDs containsObject:item.uuid] &&
            item.bookmarked) {
            [weakSelf.itemUUIDs addObject:item.uuid];
            weakSelf.bookmarkItems[item.uuid] = item;
        }
    }];
    [self notifyObservers];
}

- (void)updateBookmark:(PlaceItem *)placeItem bookmark:(BOOL)bookmark {
    self.bookmarkItems[placeItem.uuid] = placeItem;
    [self notifyObservers];
}

- (void)addObserver:(nonnull id<BookmarksObserver>)observer {
    [self.bookmarksObservers addObject:observer];
}

- (void)notifyObservers {
    [self.bookmarksObservers enumerateObjectsUsingBlock:^(id<BookmarksObserver>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj onBookmarksUpdate:self.bookmarkItems];
    }];
}

- (void)removeObserver:(nonnull id<BookmarksObserver>)observer {
    [self.bookmarksObservers removeObject:observer];
}

@end
