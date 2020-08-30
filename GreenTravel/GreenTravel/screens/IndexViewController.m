//
//  IndexViewController.m
//  GreenTravel
//
//  Created by Alex K on 8/15/20

#import "Colors.h"
#import "TextUtils.h"
#import "IndexViewController.h"
#import "PlacesTableViewCell.h"
#import "PlaceItem.h"
#import "Category.h"
#import "DetailsViewController.h"
#import "SearchViewController.h"
#import "PlacesViewController.h"
#import "StyleUtils.h"
#import "SizeUtils.h"
#import "PlacesTableViewCellConstants.h"
#import "CategoriesRetriever.h"
#import "IndexModel.h"
#import "SearchModel.h" 
#import "ApiService.h"

@interface IndexViewController ()

@property (strong, nonatomic) ApiService *apiService;
@property (strong, nonatomic) IndexModel *model;
@property (strong, nonatomic) SearchModel *searchModel;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UIBarButtonItem *originalBackButtonItem;

@end

static NSString * const kCollectionCellId = @"collectionCellId";
static CGFloat kTableRowHeight = 210.0;

@implementation IndexViewController

- (instancetype) initWithApiService:(ApiService *)apiService
                              model:(nonnull IndexModel *)model
                        searchModel:(SearchModel *)searchModel{
    self = [super init];
    _apiService = apiService;
    _model = model;
    _searchModel = searchModel;
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
    [self.apiService loadCategories];
}

#pragma mark - Lifecycle

- (void)viewDidAppear:(BOOL)animated {
    [self.navigationItem setBackBarButtonItem:self.originalBackButtonItem];
}

- (void) onSearchPress:(id)sender {
    [self.navigationItem setBackBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil]];
    [self.navigationController pushViewController:[[SearchViewController alloc] initWithModel:self.searchModel] animated:NO];
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

- (void)fillNavigationListeners:(NSArray<Category *> *)categories {
    __weak typeof(self) weakSelf = self;
    [categories enumerateObjectsUsingBlock:^(Category * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        __weak typeof(obj) weakCategory = obj;
        obj.onAllButtonPress = ^void() {
            PlacesViewController *placesViewController = [[PlacesViewController alloc] init];
            placesViewController.category = weakCategory;
            [weakSelf.navigationController pushViewController:placesViewController animated:YES];
        };
        [weakSelf fillNavigationListeners:obj.categories];
        
        [obj.categories enumerateObjectsUsingBlock:^(Category * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            __weak typeof(obj) weakCategory = obj;
            obj.onPlaceCellPress = ^void() {
                PlacesViewController *placesViewController = [[PlacesViewController alloc] init];
                placesViewController.category = weakCategory;
                [weakSelf.navigationController pushViewController:placesViewController animated:YES];
            };
        }];

        [obj.items enumerateObjectsUsingBlock:^(PlaceItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            __weak typeof(obj) weakItem = obj;
            obj.onPlaceCellPress = ^void() {
                DetailsViewController *detailsViewController = [[DetailsViewController alloc] init];
                detailsViewController.item = weakItem;
                [weakSelf.navigationController pushViewController:detailsViewController animated:YES];
            };
        }];
    }];
}

@end
