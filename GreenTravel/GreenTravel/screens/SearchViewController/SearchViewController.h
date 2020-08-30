//
//  SearchViewController.h
//  GreenTravel
//
//  Created by Alex K on 8/16/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchItemsObserver.h"

NS_ASSUME_NONNULL_BEGIN

@class SearchModel;


@interface SearchViewController : UITableViewController<UISearchResultsUpdating, SearchItemsObserver>

- (instancetype)initWithModel:(SearchModel *)model;

@end

NS_ASSUME_NONNULL_END
