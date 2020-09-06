//
//  BookmarksViewController.h
//  GreenTravel
//
//  Created by Alex K on 8/15/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookmarksGroupObserver.h"

NS_ASSUME_NONNULL_BEGIN

@class BookmarksGroupModel;

@interface BookmarksViewController : UICollectionViewController<UICollectionViewDelegateFlowLayout, BookmarksGroupObserver>

- (instancetype)initWithModel:(BookmarksGroupModel *)model;

@end

NS_ASSUME_NONNULL_END
