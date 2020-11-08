//
//  LinkedCategoriesView.m
//  GreenTravel
//
//  Created by Alex K on 11/6/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import "LinkedCategoriesView.h"
#import "IndexModel.h"
#import "ApiService.h"
#import "DetailsModel.h"
#import "MapModel.h"
#import "LocationModel.h"
#import "CategoryUtils.h"
#import "PlaceItem.h"
#import "Category.h"
#import "PlacesViewController.h"
#import "CategoryUUIDToRelatedItemUUIDs.h"
#import "CategoryLinkCell.h"

@interface LinkedCategoriesView()

@property (strong, nonatomic) NSArray<NSArray *> *linkIds;
@property (strong, nonatomic) IndexModel *indexModel;
@property (strong, nonatomic) ApiService *apiService;
@property (strong, nonatomic) DetailsModel *detailsModel;
@property (strong, nonatomic) MapModel *mapModel;
@property (strong, nonatomic) LocationModel *locationModel;
@property (strong, nonatomic) NSMutableArray<Category *> *categories;
@property (strong, nonatomic) NSArray<CategoryUUIDToRelatedItemUUIDs *> *categoryIdToItems;
@property (copy, nonatomic) void(^pushToNavigationController)(PlacesViewController *);

@end

static NSString * const kCategoryLinkCellId = @"categoryLinkCellId";

@implementation LinkedCategoriesView

- (instancetype)initWithIndexModel:(IndexModel *)indexModel
                     apiService:(nonnull ApiService *)apiService
                   detailsModel:(nonnull DetailsModel *)detailsModel
                       mapModel:(nonnull MapModel *)mapModel
                  locationModel:(nonnull LocationModel *)locationModel
     pushToNavigationController:(nonnull void (^)(PlacesViewController * _Nonnull))pushToNavigationController
{
    self = [super init];
    if (self) {
        self.categories = [[NSMutableArray alloc] init];
        self.apiService = apiService;
        self.indexModel = indexModel;
        self.detailsModel = detailsModel;
        self.mapModel = mapModel;
        self.locationModel = locationModel;
        self.pushToNavigationController = pushToNavigationController;
        
        [self registerClass:CategoryLinkCell.class forCellReuseIdentifier:kCategoryLinkCellId];
        self.delegate = self;
        self.dataSource = self;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return self;
}

- (void)update:(NSArray<CategoryUUIDToRelatedItemUUIDs *>*)categoryIdToItems {
    self.categoryIdToItems = categoryIdToItems;
    [self.categories removeAllObjects];
    
    NSMutableDictionary<NSString *, Category *> *categoryUUIDToCategoryMap =  flattenCategoriesTreeIntoCategoriesMap(self.indexModel.categories);
    [categoryIdToItems enumerateObjectsUsingBlock:^(CategoryUUIDToRelatedItemUUIDs * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        Category *category = categoryUUIDToCategoryMap[obj.categoryUUID];
        [self.categories addObject:category];
    }];
    [self reloadData];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    Category *category = self.categories[indexPath.row];
    CategoryLinkCell *cell = [self dequeueReusableCellWithIdentifier:kCategoryLinkCellId];
    [cell update:category];
    return cell;
}
 
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.categories count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSOrderedSet<NSString *> *linkedItems = [self.categoryIdToItems[indexPath.row].relatedItemUUIDs copy];
    Category *category = self.categories[indexPath.row];
    
    PlacesViewController *placesViewController =
    [[PlacesViewController alloc] initWithIndexModel:self.indexModel
                                          apiService:self.apiService
                                        detailsModel:self.detailsModel
                                            mapModel:self.mapModel
                                       locationModel:self.locationModel
                                          bookmarked:NO
                                    allowedItemUUIDs:linkedItems];
    placesViewController.category = category;
    self.pushToNavigationController(placesViewController);
    [self deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)numberOfSections {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 46.0;
}

@end
