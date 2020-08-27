//
//  ApiService.h
//  GreenTravel
//
//  Created by Alex K on 8/27/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class IndexModel;
@class Category;

@interface ApiService : NSObject

- (instancetype)initWithSession:(NSURLSession *)session model:(IndexModel *)model;
- (void)loadCategories;
- (void)loadDetailsByUUID:(NSString *)uuid;

@end

NS_ASSUME_NONNULL_END
