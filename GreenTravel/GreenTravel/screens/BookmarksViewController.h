//
//  BookmarksViewController.h
//  GreenTravel
//
//  Created by Alex K on 8/15/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookmarksObserver.h"

NS_ASSUME_NONNULL_BEGIN

@class BookmarksModel;

@interface BookmarksViewController : UICollectionViewController<UICollectionViewDelegateFlowLayout, BookmarksObserver>

- (instancetype)initWithModel:(BookmarksModel *)model;

@end

NS_ASSUME_NONNULL_END
