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
#import "SearchHeaderCell.h"
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
@property (strong, nonatomic) LocationModel *locationModel;
@property (strong, nonatomic) MapModel *mapModel;
@property (strong, nonatomic) CLLocation *lastLocation;
@property (assign, nonatomic) BOOL locationIsEnabled;
@property (assign, nonatomic) BOOL intentionToGoToNearbyPlaces;
@property (strong, nonatomic) DetailsModel *detailsModel;
@property (strong, nonatomic) ApiService *apiService;
@property (strong, nonatomic) CoreDataService *coreDataService;
@property (assign, nonatomic) SearchItem *itemToSaveToHistory;

@end

static NSString * const kPlaceholderSearch = @"";

static NSString * const kSearchHeaderCellId = @"searchHeaderCellId";
static NSString * const kWeRecommendCellId = @"weRecommendCellId";
static NSString * const kSearchCellId = @"searchCellId";
static const int kDataSourceOrigOffset = 2;
static const CGFloat kSearchHeaderRowHeight = 95.0;
static const CGFloat kWeRecommendRowHeight = 30.0;
static const CGFloat kSearchRowHeight = 40.0;

@implementation SearchViewController

- (instancetype)initWithModel:(SearchModel *)model
                locationModel:(LocationModel *)locationModel
                     mapModel:(MapModel *)mapModel
                   apiService:(ApiService *)apiService
              coreDataService:(CoreDataService *)coreDataService
                 detailsModel:(DetailsModel *)detailsModel
{
    self = [super init];
    if (self) {
        _model = model;
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
    
    self.tableView.backgroundColor = [Colors get].white;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.alwaysBounceVertical = YES;
    [self.tableView registerClass:[SearchHeaderCell class] forCellReuseIdentifier:kSearchHeaderCellId];
    [self.tableView registerClass:[WeRecommendCell class] forCellReuseIdentifier:kWeRecommendCellId];
    [self.tableView registerClass:[SearchCell class] forCellReuseIdentifier:kSearchCellId];
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.obscuresBackgroundDuringPresentation = NO;
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    self.searchController.searchBar.placeholder = kPlaceholderSearch;
    self.navigationItem.titleView = self.searchController.searchBar;
    self.definesPresentationContext = YES;
    
    [self.locationModel addObserver:self];
    [self.model addObserver:self];
    [self.model loadSearchItems];
}

#pragma mark - Location model

- (void)onAuthorizationStatusChange:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        if (self.locationModel.locationEnabled) {
            [self.locationModel startMonitoring];
            if (self.intentionToGoToNearbyPlaces) {
                MapViewController *nearbyPlacesViewController = [[MapViewController alloc] initWithMapModel:self.mapModel locationModel:self.locationModel showClosestPoints:YES mapItem:nil];
                [self.navigationController pushViewController:nearbyPlacesViewController animated:YES];
                self.intentionToGoToNearbyPlaces = NO;
            }
        }
    }
}

- (void)onLocationUpdate:(CLLocation *)lastLocation {
    if (self.intentionToGoToNearbyPlaces) {
        MapViewController *nearbyPlacesViewController = [[MapViewController alloc] init];
        [self.navigationController pushViewController:nearbyPlacesViewController animated:YES];
        self.intentionToGoToNearbyPlaces = NO;
    }
}

#pragma mark - SearchModel
- (void)onSearchHistoryItemsUpdate:(NSArray<SearchItem *> *)searchHistoryItems {
    if (![self isSearching]) {
        [self.tableView reloadData];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self isSearching]) {
        return [self.dataSourceFiltered count];
    }
    return [self.model.searchHistoryItems count] + kDataSourceOrigOffset;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0 && ![self isSearching]) {
        SearchHeaderCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kSearchHeaderCellId];
        return cell;
    }
    if (indexPath.row == 1 && ![self isSearching] && [self.model.searchHistoryItems count] > 0) {
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0 && ![self isSearching]) {
        return kSearchHeaderRowHeight;
    }
    if (indexPath.row == 1 && ![self isSearching]) {
        return kWeRecommendRowHeight;
    }
    return kSearchRowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    DetailsViewController *detailsController = [[DetailsViewController alloc] initWithApiService:self.apiService detailsModel:self.detailsModel mapModel:self.mapModel locationModel:self.locationModel];
    if (indexPath.row == 0 && ![self isSearching]) {
        self.intentionToGoToNearbyPlaces = YES;
        [self.locationModel authorize];
        if (self.locationModel.locationEnabled) {
            [self.locationModel startMonitoring];
            MapViewController *nearbyPlacesViewController = [[MapViewController alloc] initWithMapModel:self.mapModel locationModel:self.locationModel showClosestPoints:YES mapItem:nil];
            [self.navigationController pushViewController:nearbyPlacesViewController animated:YES];
            self.intentionToGoToNearbyPlaces = NO;
        }
        return;
    }
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

#pragma mark - Lifecycle
- (void)viewDidDisappear:(BOOL)animated {
    [self.locationModel removeObserver:self];
    [self.model removeObserver:self];
    if (self.itemToSaveToHistory) {
        [self.model addSearchHistoryItem:self.itemToSaveToHistory];
        self.itemToSaveToHistory = nil;
    }
}

#pragma mark - Search

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *search = searchController.searchBar.text;
    [self.dataSourceFiltered removeAllObjects];
    for (SearchItem *item in self.model.searchItems) {
        if ([[item searchableText] localizedCaseInsensitiveContainsString:search]) {
            [self.dataSourceFiltered addObject:item];
            continue;
        }
    }
    [self.tableView reloadData];
}

- (BOOL)isSearchBarEmpty {
    NSString *search = self.searchController.searchBar.text;
    return [search length] == 0;
}

- (BOOL)isSearching {
    return self.searchController.isActive && ![self isSearchBarEmpty];
}

#pragma mark - Lifecycle
// This fixes situation when view underlying in the stack doesn't adapt to
// navigation bar of variable height. https://stackoverflow.com/a/47976999
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController.view setNeedsLayout];
    [self.navigationController.view layoutIfNeeded];
}

- (void)onSearchItemsUpdate:(nonnull NSArray<SearchItem *> *)searchItems {
    [self.tableView reloadData];
}

@end
 
