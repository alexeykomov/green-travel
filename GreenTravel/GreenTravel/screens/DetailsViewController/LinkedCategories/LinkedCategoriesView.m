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
#import "Colors.h"
#import "Typography.h"

@interface LinkedCategoriesView()

@property (strong, nonatomic) NSArray<NSArray *> *linkIds;
@property (strong, nonatomic) IndexModel *indexModel;
@property (strong, nonatomic) ApiService *apiService;
@property (strong, nonatomic) MapModel *mapModel;
@property (strong, nonatomic) LocationModel *locationModel;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray<Category *> *categories;
@property (strong, nonatomic) NSArray<CategoryUUIDToRelatedItemUUIDs *> *categoryIdToItems;
@property (copy, nonatomic) void(^pushToNavigationController)(PlacesViewController *);
@property (strong, nonatomic) NSLayoutConstraint *heightConstraint;

@end

static NSString * const kCategoryLinkCellId = @"categoryLinkCellId";

@implementation LinkedCategoriesView

- (instancetype)initWithIndexModel:(IndexModel *)indexModel
                     apiService:(nonnull ApiService *)apiService
                       mapModel:(nonnull MapModel *)mapModel
                  locationModel:(nonnull LocationModel *)locationModel
     pushToNavigationController:(nonnull void (^)(PlacesViewController * _Nonnull))pushToNavigationController
{
    self = [super init];
    if (self) {
        self.categories = [[NSMutableArray alloc] init];
        self.apiService = apiService;
        self.indexModel = indexModel;
        self.mapModel = mapModel;
        self.locationModel = locationModel;
        self.pushToNavigationController = pushToNavigationController;
        self.tableView = [[UITableView alloc] init];
        [self.tableView registerClass:CategoryLinkCell.class forCellReuseIdentifier:kCategoryLinkCellId];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.scrollEnabled = NO;
        self.tableView.alwaysBounceVertical = NO;
        [self setUp];
    }
    return self;
}

- (void)setUp {
    UILabel *interestingLabel = [[UILabel alloc] init];

    interestingLabel.numberOfLines = 2;
    [interestingLabel setFont:[UIFont fontWithName:@"Montserrat-Bold" size:20.0]];
    interestingLabel.translatesAutoresizingMaskIntoConstraints = NO;
    interestingLabel.attributedText = [[Typography get] makeTitle1Bold:@"Будет интересно"];

    [self addSubview:interestingLabel];

    [NSLayoutConstraint activateConstraints:@[
        [interestingLabel.topAnchor constraintEqualToAnchor:self.topAnchor constant:32.0],
        [interestingLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:16.0],
        [interestingLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-25.0],
    ]];
    
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.tableView];

    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.topAnchor constraintEqualToAnchor:interestingLabel.bottomAnchor constant:18],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:0.0],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:0.0],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-32.0],
    ]];
    self.tableView.backgroundColor = [Colors get].apple;

}

- (void)update:(NSArray<CategoryUUIDToRelatedItemUUIDs *>*)categoryIdToItems {
    self.categoryIdToItems = categoryIdToItems;
    [self.categories removeAllObjects];
    
    NSMutableDictionary<NSString *, Category *> *categoryUUIDToCategoryMap =  flattenCategoriesTreeIntoCategoriesMap(self.indexModel.categories);
    __weak typeof(self) weakSelf = self;
    [categoryIdToItems enumerateObjectsUsingBlock:^(CategoryUUIDToRelatedItemUUIDs * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        Category *category = categoryUUIDToCategoryMap[obj.categoryUUID];
        [weakSelf.categories addObject:category];
    }];
    [self.tableView reloadData];
    
    if (self.heightConstraint) {
        [NSLayoutConstraint deactivateConstraints:@[self.heightConstraint]];
    }
    self.heightConstraint = [self.tableView.heightAnchor constraintEqualToConstant:[self.categories count] * 46.0];
    [NSLayoutConstraint activateConstraints:@[
        self.heightConstraint
    ]];
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    Category *category = self.categories[indexPath.row];
    CategoryLinkCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kCategoryLinkCellId];
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
                                            mapModel:self.mapModel
                                       locationModel:self.locationModel
                                          bookmarked:NO
                                    allowedItemUUIDs:linkedItems];
    placesViewController.category = category;
    self.pushToNavigationController(placesViewController);
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)numberOfSections {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 46.0;
}

@end
