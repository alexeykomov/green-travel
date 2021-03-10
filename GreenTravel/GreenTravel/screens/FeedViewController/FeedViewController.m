//
//  DiscoveryViewController.m
//  GreenTravel
//
//  Created by Alex K on 3/7/21.
//  Copyright © 2021 Alex K. All rights reserved.
//

#import "FeedViewController.h"
#import "FeedItemCell.h"
#import "FeedModel.h"

@interface FeedViewController ()

@property (strong, nonatomic) NSMutableArray<NSString *> *dataSourceHistory;
@property (strong, nonatomic) NSMutableArray<SearchItem *> *dataSourceFiltered;
@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) FeedModel *model;
@property (strong, nonatomic) SearchModel *model;
@property (strong, nonatomic) IndexModel *indexModel;
@property (strong, nonatomic) LocationModel *locationModel;
@property (strong, nonatomic) MapModel *mapModel;
@property (strong, nonatomic) CLLocation *lastLocation;
@property (assign, nonatomic) BOOL locationIsEnabled;
@property (strong, nonatomic) ApiService *apiService;
@property (strong, nonatomic) CoreDataService *coreDataService;
@property (strong, nonatomic) SearchItem *itemToSaveToHistory;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) NSLayoutConstraint *bottomConstraint;
@property (assign, nonatomic) BOOL searchActive;
@property (assign, nonatomic) UIEdgeInsets scrollInsets;
@property (strong, nonatomic) NSLayoutConstraint *scrollViewHeightConstraint;

@end

static NSString * const kFeedCellId = @"feedCellId";
static const int kDataSourceOrigOffset = 1;
static const CGFloat kWeRecommendRowHeight = 72.0;
static const CGFloat kSearchRowHeight = 58.0;

@implementation FeedViewController

- (instancetype)initWithModel:(FeedModel *)model
                indexModel:(IndexModel *)indexModel
                locationModel:(LocationModel *)locationModel
                     mapModel:(MapModel *)mapModel
                   apiService:(ApiService *)apiService
              coreDataService:(CoreDataService *)coreDataService
{
    self = [super init];
    if (self) {
        _model = model;
        _indexModel = indexModel;
        _locationModel = locationModel;
        _mapModel = mapModel;
        _apiService = apiService;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.dataSourceHistory = [[NSMutableArray alloc] init];
    self.dataSourceFiltered = [[NSMutableArray alloc] init];
    
    self.scrollInsets = UIEdgeInsetsZero;
    [self setUpWithTable];
}

- (void)updateViews {
    if ([self isSearching]) {
        if ([self.dataSourceFiltered count] > 0) {
            [self setUpWithTable];
            return;
        }
        [self setUpWithNoDataPlaceholder];
        return;
    }
    [self setUpWithTable];
}


- (void)setUpWithTable {
    [self.scrollView removeFromSuperview];
    self.scrollView = nil;
    if (self.tableView != nil) {
        [self.tableView reloadData];
        return;
    }
    
    self.tableView = [[UITableView alloc] init];
    [self.view addSubview:self.tableView];
    self.tableView.backgroundColor = [Colors get].white;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.alwaysBounceVertical = YES;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.tableView registerClass:FeedItemCell.class forCellReuseIdentifier:kFeedCellId];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.bottomConstraint = [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor];
    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
        self.bottomConstraint,
    ]];
    [self.tableView reloadData];
}

- (void)setUpWithNoDataPlaceholder {
    [self.tableView removeFromSuperview];
    self.tableView = nil;
    if (self.scrollView != nil) {
        return;
    }
    
    self.scrollView = [[UIScrollView alloc] init];
    [self.view addSubview:self.scrollView];
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.scrollView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.scrollView.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
        [self.scrollView.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
        [self.scrollView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor]
    ]];
    
    UIView *contentView = [[UIView alloc] init];
    [self.scrollView addSubview:contentView];
    contentView.translatesAutoresizingMaskIntoConstraints = NO;
    self.scrollViewHeightConstraint = [contentView.heightAnchor constraintEqualToAnchor:self.scrollView.heightAnchor];
    [NSLayoutConstraint activateConstraints:@[
        [contentView.topAnchor constraintEqualToAnchor:self.scrollView.topAnchor],
        [contentView.bottomAnchor constraintEqualToAnchor:self.scrollView.bottomAnchor],
        [contentView.widthAnchor constraintEqualToAnchor:self.scrollView.widthAnchor],
        self.scrollViewHeightConstraint,
    ]];
    
    UIStackView *stackView = [[UIStackView alloc] init];
    [contentView addSubview:stackView];
    stackView.translatesAutoresizingMaskIntoConstraints = NO;
    stackView.distribution = UIStackViewDistributionFill;
    stackView.alignment = UIStackViewAlignmentCenter;
    stackView.axis = UILayoutConstraintAxisVertical;
    stackView.spacing = 14.0;
    stackView.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search"]];
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [imageView.widthAnchor constraintEqualToConstant:48.0],
        [imageView.heightAnchor constraintEqualToConstant:48.0],
    ]];
    UILabel *label = [[UILabel alloc] init];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [label setAttributedText:[[Typography get] makeBody:@"К сожалению, по вашему запросу ничего не найдено"]];
    [label setTextAlignment:NSTextAlignmentCenter];
    label.numberOfLines = 2;
    
    [stackView addArrangedSubview:imageView];
    [stackView addArrangedSubview:label];
    [NSLayoutConstraint activateConstraints:@[
        [stackView.centerYAnchor constraintEqualToAnchor:contentView.centerYAnchor],
        [stackView.heightAnchor constraintLessThanOrEqualToConstant:100.0],
        [stackView.widthAnchor constraintLessThanOrEqualToConstant:262.0],
        [stackView.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor],
        [stackView.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor],
    ]];
    [self updateInsets:self.scrollInsets];
}

#pragma mark - SearchModel
- (void)onSearchHistoryItemsUpdate:(NSArray<SearchItem *> *)searchHistoryItems {
    if (![self isSearching]) {
        [self updateViews];
    }
}

- (void)onSearchItemsUpdate:(nonnull NSArray<SearchItem *> *)searchItems {
    [self updateViews];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self isSearching]) {
        return [self.dataSourceFiltered count];
    }
    NSUInteger searchHistoryItemsCount = [self.model.searchHistoryItems count];
    if (searchHistoryItemsCount > 0) {
        return searchHistoryItemsCount + kDataSourceOrigOffset;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0 && ![self isSearching] && [self.model.searchHistoryItems count] > 0) {
        WeRecommendCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kWeRecommendCellId];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.userInteractionEnabled = NO;
        return cell;
    }
    FeedItemCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kSearchCellId];
    FeedItem *item = self.model.feedItems[indexPath.row];
    [cell update:item onBookmarkButtonPress:^{
        
    } onLocationButtonPress:^{
        
    } onMapButtonPress:^{
        
    } onCategoriesLinkPress:^(NSOrderedSet<NSString *> * _Nonnull, Category * _Nonnull) {
        
    }];
    
    return cell;
}

- (SearchCellConfiguration *)mapSearchCellConfigurationFromSearchItem:(SearchItem *)item {
    SearchCellConfiguration *cellConfiguration = [[SearchCellConfiguration alloc] init];
    PlaceItem *correspondingItem = self.indexModel.flatItems[item.correspondingPlaceItemUUID];
    cellConfiguration.title = correspondingItem.title;
    cellConfiguration.categoryTitle = correspondingItem.category.title;
    cellConfiguration.iconName = correspondingItem.category.icon;
    return cellConfiguration;
}

- (CGFloat)tableView:(UITableView *)tableView
estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0 && ![self isSearching]) {
        return kWeRecommendRowHeight;
    }
    return kSearchRowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    DetailsViewController *detailsController = [[DetailsViewController alloc] initWithApiService:self.apiService indexModel:self.indexModel mapModel:self.mapModel locationModel:self.locationModel];
    if ([self isSearching]) {
        SearchItem *searchItem = self.dataSourceFiltered[indexPath.row];
        detailsController.item = self.indexModel.flatItems[searchItem.correspondingPlaceItemUUID];
        self.itemToSaveToHistory = searchItem;
        self.searchController.searchBar.text = @"";
    } else {
        SearchItem *searchItem =
        self.model.searchHistoryItems[indexPath.row - kDataSourceOrigOffset];
        self.itemToSaveToHistory = searchItem;
        detailsController.item = self.indexModel.flatItems[searchItem.correspondingPlaceItemUUID];
    }
    [self.navigationController pushViewController:detailsController animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![self isSearching] && indexPath.row >= kDataSourceOrigOffset) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (![self isSearching] && indexPath.row >= kDataSourceOrigOffset) {
            SearchItem *searchItem = self.model.searchHistoryItems[indexPath.row -kDataSourceOrigOffset];
            [self.model removeSearchHistoryItem:searchItem];
            if ([self.model.searchHistoryItems count] > 0) {
                [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
                return;
            }
            [self.tableView deleteRowsAtIndexPaths:@[
                [NSIndexPath indexPathForRow:0 inSection:0], indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
}

#pragma mark - Search
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *search = searchController.searchBar.text;
    [self.dataSourceFiltered removeAllObjects];
    self.searchActive = searchController.isActive;
    if (!searchController.isActive) {
        [self updateViews];
        return;
    }
    for (SearchItem *item in self.model.searchItems) {
        if ([[item searchableText] localizedCaseInsensitiveContainsString:search]) {
            [self.dataSourceFiltered addObject:item];
            continue;
        }
    }
    [self updateViews];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searchActive = NO;
    [self updateViews];
}

- (BOOL)isSearchBarEmpty {
    NSString *search = self.searchController.searchBar.text;
    return [search length] == 0;
}

- (BOOL)isSearching {
    return self.searchActive && self.searchController.isActive &&
    ![self isSearchBarEmpty];
}

@end
