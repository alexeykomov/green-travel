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

@interface IndexViewController ()

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) NSMutableArray<Category *> *dataSource;
@property (strong, nonatomic) UIBarButtonItem *originalBackButtonItem;

@end

static NSString * const kCollectionCellId = @"collectionCellId";
static CGFloat kTableRowHeight = 210.0;

@implementation IndexViewController

- (instancetype) initWithCategoriesRetriever:(CategoriesRetriever *)categoriesRetriever {
    self = [super init];
    _categoriesRetriever = categoriesRetriever;
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
    self.dataSource = [[NSMutableArray alloc] init];
    self.tableView.allowsSelection = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.alwaysBounceVertical = YES;
    

    
    Category *territory = [[Category alloc] init];
    territory.title = @"Заповедные территории";
    NSMutableArray *territoryItems = [[NSMutableArray alloc] init];
    PlaceItem *itemA = [[PlaceItem alloc] init];
    __weak typeof(self) weakSelf = self;
    __weak typeof(itemA) weakItemA = itemA;
    itemA.onPlaceCellPress = ^void (PlaceItem *item) {
        DetailsViewController *detailsController = [[DetailsViewController alloc] init];
        detailsController.item = weakItemA;
        [weakSelf.navigationController pushViewController:detailsController animated:YES];
    };
    itemA.title = @"Беловежская пуща";
    PlaceItem *itemB = [[PlaceItem alloc] init];
    itemB.title = @"Березинский биосферный заповедник";
    __weak typeof(itemB) weakItemB = itemB;
    itemB.onPlaceCellPress = ^void (PlaceItem *item) {
        DetailsViewController *detailsController = [[DetailsViewController alloc] init];
        
        detailsController.item = weakItemB;
        [weakSelf.navigationController pushViewController:detailsController animated:YES];
    };
    [territoryItems addObjectsFromArray:@[itemA, itemB]];
    territory.items = territoryItems;
    territory.onAllButtonPress = ^void (Category *item) {
        PlacesViewController *placesController = [[PlacesViewController alloc] init];
        placesController.item = item;
        [weakSelf.navigationController pushViewController:placesController animated:YES];
    };
    
    Category *paths = [[Category alloc] init];
    paths.title = @"Маршруты";
    
    Category *historicalPlaces = [[Category alloc] init];
    historicalPlaces.title = @"Исторические места";
    
    Category *excursions = [[Category alloc] init];
    excursions.title = @"Экскурсии";
        
    [self.dataSource addObjectsFromArray:@[territory, paths, historicalPlaces, excursions]];
}

#pragma mark - Lifecycle

- (void)viewDidAppear:(BOOL)animated {
    [self.navigationItem setBackBarButtonItem:self.originalBackButtonItem];
}

- (void) onSearchPress:(id)sender {
    [self.navigationItem setBackBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil]];
    [self.navigationController pushViewController:[[SearchViewController alloc] init] animated:NO];
}

#pragma mark - Table data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PlacesTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kCollectionCellId forIndexPath:indexPath];
    
    [cell update:self.dataSource[indexPath.row]];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGSize adaptedSize = CGSizeMake(self.view.bounds.size.width - 50, self.view.bounds.size.height);
    return getCellSize(adaptedSize).height + 2 * 16.0 + 50.0;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
