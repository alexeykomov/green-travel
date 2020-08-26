//
//  IndexViewController.h
//  GreenTravel
//
//  Created by Alex K on 8/15/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CategoriesRetriever;

@interface IndexViewController : UITableViewController

@property (strong, nonatomic) CategoriesRetriever *categoriesRetriever;
- (instancetype) initWithCategoriesRetriever:(CategoriesRetriever *)categoriesRetriever;

@end

NS_ASSUME_NONNULL_END
