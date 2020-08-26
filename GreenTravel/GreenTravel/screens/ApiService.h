//
//  ApiService.h
//  GreenTravel
//
//  Created by Alex K on 8/27/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class Category;

@interface ApiService : NSObject

@property (strong, nonatomic) NSURLSession *session;
- (NSArray<Category *>*)getCategories; 

@end

NS_ASSUME_NONNULL_END
