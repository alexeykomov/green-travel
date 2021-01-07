//
//  IndexViewController.m
//  GreenTravel
//
//  Created by Alex K on 8/15/20

#import "Colors.h"
#import "TextUtils.h"
#import "IndexViewController.h"
#import "PlacesTableViewCell.h"
#import "PhotoCollectionViewCell.h"
#import "PlaceItem.h"
#import "Category.h"
#import "DetailsViewController.h"
#import "SearchViewController.h"
#import "PlacesViewController.h"
#import "StyleUtils.h"
#import "SizeUtils.h"
#import "PlacesTableViewCellConstants.h"
#import "IndexModel.h"
#import "DetailsModel.h"
#import "SearchModel.h"
#import "ApiService.h"
#import "LocationModel.h"
#import "CoreDataService.h"

@interface IndexViewController ()

@property (strong, nonatomic) ApiService *apiService;
@property (strong, nonatomic) IndexModel *model;
@property (strong, nonatomic) DetailsModel *detailsModel;
@property (strong, nonatomic) SearchModel *searchModel;
@property (strong, nonatomic) LocationModel *locationModel;
@property (strong, nonatomic) MapModel *mapModel;
@property (strong, nonatomic) CoreDataService *coreDataService;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UIBarButtonItem *originalBackButtonItem;

@end

static NSString * const kCollectionCellId = @"collectionCellId";
static CGFloat kTableRowHeight = 210.0;

@implementation IndexViewController 

- (instancetype) initWithApiService:(ApiService *)apiService
                              model:(nonnull IndexModel *)model
                        searchModel:(SearchModel *)searchModel
                      locationModel:(LocationModel *)locationModel
                           mapModel:(MapModel *)mapModel
                       detailsModel:(DetailsModel *)detailsModel
                    coreDataService:(CoreDataService *)coreDataService
{
    self = [super init];
    _apiService = apiService;
    _model = model;
    _searchModel = searchModel;
    _locationModel = locationModel;
    _mapModel = mapModel;
    _detailsModel = detailsModel;
    _coreDataService = coreDataService;
    return self;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [Colors get].white;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(onSearchPress:)];
    self.navigationItem.rightBarButtonItem.tintColor = [Colors get].white;
    
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    configureNavigationBar(navigationBar);
    
    self.originalBackButtonItem = self.navigationItem.backBarButtonItem;
    
#pragma mark - Table view
    [self.tableView registerClass:PlacesTableViewCell.class forCellReuseIdentifier:kCollectionCellId];
    self.tableView.allowsSelection = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.alwaysBounceVertical = YES;

    [self.model addObserver:self];
    [self.model addObserverBookmarks:self];
    [self.model loadCategories];
}

#pragma mark - Lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [self fillNavigationListeners:self.model.categories];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.navigationItem setBackBarButtonItem:self.originalBackButtonItem];
}

- (void) onSearchPress:(id)sender {
    [self.navigationItem setBackBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil]];
    [self.navigationController pushViewController:
     [[SearchViewController alloc] initWithModel:self.searchModel
                                      indexModel:self.model
                                   locationModel:self.locationModel
                                        mapModel:self.mapModel
                                      apiService:self.apiService
                                 coreDataService:self.coreDataService
                                    detailsModel:self.detailsModel] animated:NO];
}

#pragma mark - Table data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.model.categories count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PlacesTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kCollectionCellId forIndexPath:indexPath];
    
    [cell update:self.model.categories[indexPath.row]];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGSize adaptedSize = CGSizeMake(self.view.bounds.size.width - 50, self.view.bounds.size.height);
    return getCellSize(adaptedSize).height + 2 * 16.0 + 50.0;
}

#pragma mark - Categories update

- (void)onCategoriesUpdate:(nonnull NSArray<Category *> *)categories {
    __weak typeof(self) weakSelf = self;
    
    [self fillNavigationListeners:self.model.categories];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.tableView reloadData];
    });
}

- (void)onBookmarkUpdate:(nonnull PlaceItem *)item bookmark:(BOOL)bookmark {
    NSIndexSet *indexes = [self.model.categories indexesOfObjectsPassingTest:^BOOL(Category * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return [obj.uuid isEqualToString:item.category.uuid];
    }];
    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        NSIndexPath *indexPathOfFoundCategory =  [NSIndexPath indexPathForRow:idx inSection:0];
        PlacesTableViewCell *cell = (PlacesTableViewCell *) [self.tableView cellForRowAtIndexPath:indexPathOfFoundCategory];
        NSIndexSet *indexes = [self.model.categories[idx].items indexesOfObjectsPassingTest:^BOOL(PlaceItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            return [obj.uuid isEqualToString:item.uuid];
        }];
        [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
            NSIndexPath *indexPathOfFoundItem =  [NSIndexPath indexPathForRow:idx inSection:0];
            PhotoCollectionViewCell *photoCollectionViewCell = (PhotoCollectionViewCell *) [cell.collectionView cellForItemAtIndexPath:indexPathOfFoundItem];
            [photoCollectionViewCell updateBookmark:bookmark];
        }];
    }];
}


- (void)fillNavigationListeners:(NSArray<Category *> *)categories {
    __weak typeof(self) weakSelf = self;
    [categories enumerateObjectsUsingBlock:^(Category * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        __weak typeof(obj) weakCategory = obj;
        obj.onAllButtonPress = ^void() {
            PlacesViewController *placesViewController =
            [[PlacesViewController alloc] initWithIndexModel:weakSelf.model
                                                  apiService:weakSelf.apiService
                                                    mapModel:weakSelf.mapModel
                                               locationModel:weakSelf.locationModel bookmarked:NO
                                            allowedItemUUIDs:nil];
            placesViewController.category = weakCategory;
            [weakSelf.navigationController pushViewController:placesViewController animated:YES];
        };
        [weakSelf fillNavigationListeners:obj.categories];
        
        [obj.categories enumerateObjectsUsingBlock:^(Category * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            __weak typeof(obj) weakCategory = obj;
            obj.onPlaceCellPress = ^void() {
                PlacesViewController *placesViewController =
                [[PlacesViewController alloc] initWithIndexModel:weakSelf.model 
                                                      apiService:weakSelf.apiService
                                                        mapModel:weakSelf.mapModel
                                                   locationModel:weakSelf.locationModel
                                                      bookmarked:NO
                                                allowedItemUUIDs:nil];
                placesViewController.category = weakCategory;
                [weakSelf.navigationController pushViewController:placesViewController animated:YES];
            };
        }];
        
        [obj.items enumerateObjectsUsingBlock:^(PlaceItem * _Nonnull placeItem, NSUInteger idx, BOOL * _Nonnull stop) {
            __weak typeof(placeItem) weakPlaceItem = placeItem;
            placeItem.onPlaceCellPress = ^void() {
                DetailsViewController *detailsViewController = [[DetailsViewController alloc] initWithApiService:weakSelf.apiService  indexModel:weakSelf.model mapModel:weakSelf.mapModel locationModel:weakSelf.locationModel];
                detailsViewController.item = weakPlaceItem;
                [weakSelf.navigationController pushViewController:detailsViewController animated:YES];
            };
            placeItem.onFavoriteButtonPress = ^void() {
                [weakSelf.model bookmarkItem:weakPlaceItem
                                    bookmark:!weakPlaceItem.bookmarked];
            };
        }];
    }];
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    for (NSUInteger sectionCounter = 0; sectionCounter < self.tableView.numberOfSections; sectionCounter++) {
        for (NSUInteger rowCounter = 0; rowCounter < [self.tableView numberOfRowsInSection:sectionCounter]; rowCounter++) {
            PlacesTableViewCell *cell =
            [self.tableView cellForRowAtIndexPath:
             [NSIndexPath indexPathForRow:rowCounter inSection:sectionCounter]];
            [cell.collectionView setContentOffset:CGPointMake(0, 0) animated:YES];
        }
    }
}

@end
