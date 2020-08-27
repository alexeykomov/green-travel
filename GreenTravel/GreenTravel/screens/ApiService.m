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
#import "PlaceItem.h"
#import <CoreLocation/CoreLocation.h>

static NSString * const kGetCategoriesURL = @"http://localhost:3000/categories";

@interface ApiService ()

@property (strong, nonatomic) NSURLSession *session;
@property (strong, nonatomic) IndexModel *model;

@end

@implementation ApiService

- (instancetype) initWithSession:(NSURLSession *)session
                           model:(IndexModel *)model {
    self = [super init];
    if (self) {
        _session = session;
        _model = model;
        
    }
    return self;
}

- (void)loadCategories {
    
    NSURL *url = [NSURL URLWithString:kGetCategoriesURL];
    NSURLSessionDataTask *task = [self.session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSArray *categories = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        NSLog(@"Error when loading categories: %@", error);
        NSArray<Category *> *mappedCategories = [[self mapCategoriesFromJSON:categories] copy];
        [self.model updateCategories:mappedCategories];
    }];
    
    [task resume];
}

- (NSArray<Category *>*)mapCategoriesFromJSON:(NSArray *)categories {
    NSMutableArray<Category *> *mappedCategories = [[NSMutableArray alloc] init];
    [categories enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"Object from JSON: %@", obj);
        Category *category = [[Category alloc] init];
        category.title = obj[@"title"];
        category.categories = [self mapCategoriesFromJSON:obj[@"categories"]];
        category.items = [self mapItemsFromJSON:obj[@"items"]];
        category.cover = obj[@"cover"];
        category.uuid = obj[@"uuid"];
        [mappedCategories addObject:category];
    }];
    return mappedCategories;
}

- (NSArray<PlaceItem *>*)mapItemsFromJSON:(NSArray *)items {
    NSMutableArray<PlaceItem *> *mappedItems = [[NSMutableArray alloc] init];
    [items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"Object from JSON: %@", obj);
        PlaceItem *placeItem = [[PlaceItem alloc] init];
        placeItem.title = obj[@"title"];
        placeItem.cover = obj[@"cover"];
        placeItem.bokmarked = obj[@"bokmarked"];
        placeItem.coords = CLLocationCoordinate2DMake([obj[@"coords"][0] doubleValue], [obj[@"coords"][1] doubleValue]);
        placeItem.uuid = obj[@"uuid"];
        [mappedItems addObject:placeItem];
    }];
    return mappedItems;
}

- (void)loadDetailsByUUID:(NSString *)uuid {
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
