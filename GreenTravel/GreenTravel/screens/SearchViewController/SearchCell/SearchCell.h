//
//  SearchCell.h
//  GreenTravel
//
//  Created by Alex K on 8/22/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class SearchItem;

@interface SearchCell : UITableViewCell

- (void)update:(SearchItem *)item;

@end

NS_ASSUME_NONNULL_END
