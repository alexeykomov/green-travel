//
//  SearchViewController.m
//  GreenTravel
//
//  Created by Alex K on 8/16/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import "SearchViewController.h"
#import "Colors.h"
#import "PlaceItem.h"
#import "SearchCell.h"
#import "DetailsViewController.h"
#import "SearchItem.h"
#import "WeRecommendCell.h"
#import "MapViewController.h"
#import "SearchModel.h"
#import "LocationModel.h"
#import "DetailsModel.h"
#import "ApiService.h"
#import "CoreDataService.h"
#import <CoreLocation/CoreLocation.h>

@interface SearchViewController ()

@property (strong, nonatomic) NSMutableArray<NSString *> *dataSourceHistory;
@property (strong, nonatomic) NSMutableArray<SearchItem *> *dataSourceFiltered;
@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) SearchModel *model;
@property (strong, nonatomic) IndexModel *indexModel;
@property (strong, nonatomic) LocationModel *locationModel;
@property (strong, nonatomic) MapModel *mapModel;
@property (strong, nonatomic) CLLocation *lastLocation;
@property (assign, nonatomic) BOOL locationIsEnabled;
@property (strong, nonatomic) DetailsModel *detailsModel;
@property (strong, nonatomic) ApiService *apiService;
@property (strong, nonatomic) CoreDataService *coreDataService;
@property (strong, nonatomic) SearchItem *itemToSaveToHistory;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) NSLayoutConstraint *bottomConstraint;
@property (assign, nonatomic) BOOL searchActive;

@end

static NSString * const kPlaceholderSearch = @"";

static NSString * const kWeRecommendCellId = @"weRecommendCellId";
static NSString * const kSearchCellId = @"searchCellId";
static const int kDataSourceOrigOffset = 1;
static const CGFloat kWeRecommendRowHeight = 72.0;
static const CGFloat kSearchRowHeight = 58.0;

@implementation SearchViewController

- (instancetype)initWithModel:(SearchModel *)model
                indexModel:(IndexModel *)indexModel
                locationModel:(LocationModel *)locationModel
                     mapModel:(MapModel *)mapModel
                   apiService:(ApiService *)apiService
              coreDataService:(CoreDataService *)coreDataService
                 detailsModel:(DetailsModel *)detailsModel
{
    self = [super init];
    if (self) {
        _model = model;
        _indexModel = indexModel;
        _locationModel = locationModel;
        _mapModel = mapModel;
        _detailsModel = detailsModel;
        _apiService = apiService;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.dataSourceHistory = [[NSMutableArray alloc] init];
    self.dataSourceFiltered = [[NSMutableArray alloc] init];
    
    self.tableView = [[UITableView alloc] init];
    [self.view addSubview:self.tableView];
    self.tableView.backgroundColor = [Colors get].white;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.alwaysBounceVertical = YES;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.tableView registerClass:[WeRecommendCell class] forCellReuseIdentifier:kWeRecommendCellId];
    [self.tableView registerClass:[SearchCell class] forCellReuseIdentifier:kSearchCellId];
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
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.obscuresBackgroundDuringPresentation = NO;
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    self.searchController.searchBar.placeholder = kPlaceholderSearch;
    self.searchController.searchBar.delegate = self;
    self.navigationItem.titleView = self.searchController.searchBar;
    self.definesPresentationContext = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboadAppear:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboadDisappear:) name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - Lifecycle
- (void)viewWillAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.model addObserver:self];
    [self.model loadSearchItems];
    
    [self.navigationController.view setNeedsLayout];
    [self.navigationController.view layoutIfNeeded];
}

// This fixes situation when next view in the navigation stack doesn't adapt to
// navigation bar of variable height. https://stackoverflow.com/a/47976999
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController.view setNeedsLayout];
    [self.navigationController.view layoutIfNeeded];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.searchController setActive:NO];
    [self.model removeObserver:self];
    if (self.itemToSaveToHistory) {
        [self.model addSearchHistoryItem:self.itemToSaveToHistory];
        self.itemToSaveToHistory = nil;
    }
    [NSNotificationCenter.defaultCenter removeObserver:self name:UIKeyboardDidShowNotification object:self];
    [NSNotificationCenter.defaultCenter removeObserver:self name:UIKeyboardWillHideNotification object:self];
}

- (void)onKeyboadAppear:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    CGSize size = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, size.height - self.tabBarController.tabBar.frame.size.height, 0);
    self.tableView.contentInset = insets;
    self.tableView.scrollIndicatorInsets = insets;
}

- (void)onKeyboadDisappear:(NSNotification *)notification {
    UIEdgeInsets insets = UIEdgeInsetsZero;
    self.tableView.contentInset = insets;
    self.tableView.scrollIndicatorInsets = insets;
}

#pragma mark - SearchModel
- (void)onSearchHistoryItemsUpdate:(NSArray<SearchItem *> *)searchHistoryItems {
    if (![self isSearching]) {
        [self.tableView reloadData];
    }
}

- (void)onSearchItemsUpdate:(nonnull NSArray<SearchItem *> *)searchItems {
    [self.tableView reloadData];
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
    SearchCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kSearchCellId];
    SearchItem *item;
    if ([self isSearching]) {
        item = self.dataSourceFiltered[indexPath.row];
        [cell update:item];
        return cell;
    }
    if ([self.model.searchHistoryItems count]) {
        item = self.model.searchHistoryItems[indexPath.row - kDataSourceOrigOffset];
        [cell update:item];
        return cell;
    }
    return cell;
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
        detailsController.item = searchItem.correspondingPlaceItem;
        self.itemToSaveToHistory = searchItem;
        self.searchController.searchBar.text = @"";
    } else {
        SearchItem *searchItem = self.model.searchHistoryItems[indexPath.row -
                                                               kDataSourceOrigOffset];
        detailsController.item = searchItem.correspondingPlaceItem;
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
            [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
}

#pragma mark - Search

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *search = searchController.searchBar.text;
    [self.dataSourceFiltered removeAllObjects];
    self.searchActive = searchController.isActive;
    if (!searchController.isActive) {
        [self.tableView reloadData];
        return;
    }
    for (SearchItem *item in self.model.searchItems) {
        if ([[item searchableText] localizedCaseInsensitiveContainsString:search]) {
            [self.dataSourceFiltered addObject:item];
            continue;
        }
    }
    [self.tableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searchActive = NO;
    [self.tableView reloadData];
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
 
