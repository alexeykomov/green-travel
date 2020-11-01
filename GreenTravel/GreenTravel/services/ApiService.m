//
//  ApiService.m
//  GreenTravel
//
//  Created by Alex K on 8/27/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import "ApiService.h"
#import "Category.h"
#import "IndexModel.h"
#import "DetailsModel.h"
#import "PlaceItem.h"
#import "PlaceDetails.h"
#import <CoreLocation/CoreLocation.h>

static NSString * const kGetCategoriesURL = @"http://localhost:3000/categories";
static NSString * const kGetDetailsBaseURL = @"http://localhost:3000/details/%@";

@interface ApiService ()

@property (strong, nonatomic) NSURLSession *session;

@end

@implementation ApiService

- (instancetype) initWithSession:(NSURLSession *)session {
    self = [super init];
    if (self) {
        _session = session;
    }
    return self;
}

- (void)loadCategoriesWithCompletion:(void(^)(NSArray<Category *>*))completion {
    NSURL *url = [NSURL URLWithString:kGetCategoriesURL];
    __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask *task = [self.session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!data) {
            return;
        }
        
        NSArray *categories = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        NSLog(@"Error when loading categories: %@", error);
        NSArray<Category *> *mappedCategories = [[weakSelf mapCategoriesFromJSON:categories] copy];
        completion(mappedCategories);
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
        category.items = [self mapItemsFromJSON:obj[@"items"] category:category];
        category.cover = obj[@"cover"];
        category.uuid = obj[@"uuid"];
        [mappedCategories addObject:category];
    }];
    return mappedCategories;
}

- (NSArray<PlaceItem *>*)mapItemsFromJSON:(NSArray *)items
                                 category:(Category *)category{
    NSMutableArray<PlaceItem *> *mappedItems = [[NSMutableArray alloc] init];
    [items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"Object from JSON: %@", obj);
        PlaceItem *placeItem = [[PlaceItem alloc] init];
        placeItem.title = obj[@"title"];
        placeItem.cover = obj[@"cover"];
        placeItem.category = category;
        placeItem.bookmarked = obj[@"bokmarked"];
        placeItem.coords = CLLocationCoordinate2DMake([obj[@"coords"][0] doubleValue], [obj[@"coords"][1] doubleValue]);
        placeItem.uuid = obj[@"uuid"];
        [mappedItems addObject:placeItem];
    }];
    return mappedItems;
}

- (void)loadDetailsByUUID:(NSString *)uuid withCompletion:(void(^)(PlaceDetails*))completion{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:kGetDetailsBaseURL, uuid]];
    __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask *task = [self.session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!data) {
            return;
        }
        
        NSDictionary *detailsFromAPI = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        NSLog(@"Details from API: %@", detailsFromAPI);
        PlaceDetails *parsedDetails = [[PlaceDetails alloc] init];
        parsedDetails.images = detailsFromAPI[@"images"];
        parsedDetails.address = detailsFromAPI[@"address"];
        NSArray *sections = detailsFromAPI[@"sections"];
        NSMutableArray *parsedSections = [[NSMutableArray alloc] init];
//        [sections enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger section, BOOL * _Nonnull stop) {
//
//            [parsedSections addObject:section];
//        }]
        parsedDetails.sections = detailsFromAPI[@"sections"];
        //dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            completion(parsedDetails);
        //});
        
    }];
    
    [task resume];
}

@end
