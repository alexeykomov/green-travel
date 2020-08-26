//
//  CategoriesParser.m
//  GreenTravel
//
//  Created by Alex K on 8/26/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import "CategoriesRetriever.h"
#import "Category.h"

static NSString * const kGetCategoriesURL = @"http://localhost:3000/categories";

@implementation CategoriesRetriever

- (instancetype)initWithSession:(NSURLSession *)session
{
    self = [super init];
    if (self) {
        _session = session;
    }
    return self;
}

- (NSArray<Category *>*)getCategories {
    
    NSURLSessionDataTask *task = [self.session dataTaskWithURL:kGetCategoriesURL    completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSArray *imagesFromAPI = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        NSArray<Category *> *parsedItems = [[NSMutableArray alloc] init];
        [imagesFromAPI enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSLog(@"Object from JSON: %@", obj);
            Category *category = [[Category alloc] init];
            [parsedItems addObject:];
        }];
    
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf updateFavoriteProperty];
            [weakSelf.tableView reloadData];
        });
    }];
    
       
    
    return @[];
}

@end
