//
//  ApiService.m
//  GreenTravel
//
//  Created by Alex K on 8/27/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import "ApiService.h"
#import "CategoriesRetriever.h"
#import "Category.h"
#import "IndexModel.h"

static NSString * const kGetCategoriesURL = @"http://localhost:3000/categories";

@implementation ApiService

- (void)getCategories {
    
    NSURLSessionDataTask *task = [self.session dataTaskWithURL:kGetCategoriesURL    completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSArray *imagesFromAPI = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        NSMutableArray<Category *> *parsedCategories = [[NSMutableArray alloc] init];
        [imagesFromAPI enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSLog(@"Object from JSON: %@", obj);
            Category *category = [[Category alloc] init];
            //[parsedCategories addObject:category];
        }];
        [IndexModel get].categories = parsedCategories;
    }];
}

- (void)getDatailsByUUID:(NSString *)uuid {
    NSURLSessionDataTask *task = [self.session dataTaskWithURL:kGetCategoriesURL    completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSArray *imagesFromAPI = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        NSArray<Category *> *parsedItems = [[NSMutableArray alloc] init];
        [imagesFromAPI enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSLog(@"Object from JSON: %@", obj);
            Category *category = [[Category alloc] init];
            //[parsedItems addObject:];
        }];
    }];
}

@end
