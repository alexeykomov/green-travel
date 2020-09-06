//
//  BookmarksObserver.h
//  GreenTravel
//
//  Created by Alex K on 9/6/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class PlaceItem;

@protocol BookmarksObserver <NSObject>

- (void)onBookmarksUpdate:(NSDictionary<NSString*, PlaceItem *>*)bookmarkItems;

@end

NS_ASSUME_NONNULL_END
