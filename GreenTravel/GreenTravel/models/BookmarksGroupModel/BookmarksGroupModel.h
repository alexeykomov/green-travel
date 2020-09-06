//
//  BookmarksModel.h
//  GreenTravel
//
//  Created by Alex K on 8/30/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CategoriesObserver.h"
#import "BookmarksGroupObservable.h"
#import "BookmarksObserver.h"

NS_ASSUME_NONNULL_BEGIN

@class BookmarkItem;

@class IndexModel;
@class BookmarksModel;
@protocol BookmarksGroupObserver;

@interface BookmarksGroupModel : NSObject<CategoriesObserver, BookmarksGroupObservable, BookmarksObserver>

- (instancetype)initWithIndexModel:(IndexModel *)model
                    bookmarksModel:(BookmarksModel *)bookmarksModel;
@property (strong, nonatomic) NSMutableArray<BookmarkItem *> *bookmarkItems;
@property (strong, nonatomic) NSMutableArray<id<BookmarksGroupObserver>> *bookmarksGroupObservers;

@end

NS_ASSUME_NONNULL_END
