//
//  IndexViewController.m
//  GreenTravel
//
//  Created by Alex K on 8/15/20

#import "Colors.h"
#import "TextUtils.h"
#import "IndexViewController.h"
#import "PlacesTableViewCell.h"
#import "PlacesItem.h"
#import "ParticularPlaceItem.h"
#import "DetailsViewController.h"
#import "SearchViewController.h"
#import "PlacesViewController.h"
#import "StyleUtils.h"

@interface IndexViewController ()

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) NSMutableArray<PlacesItem *> *dataSouce;

@end

static NSString * const kCollectionCellId = @"collectionCellId";
static CGFloat kTableRowHeight = 210.0;

@implementation IndexViewController

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
    navigationBar.titleTextAttributes = getTextAttributes([Colors get].white, 16.0, UIFontWeightSemibold);
    navigationBar.barStyle = UIBarStyleBlack;
#pragma mark - Navigation item gradient
    CGRect navBarBounds = navigationBar.bounds;
    
    navBarBounds.size.height += UIApplication.sharedApplication.statusBarFrame.size.height;
    
    [navigationBar setBackgroundImage:getGradientImageToFillRect(navBarBounds) forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    
#pragma mark - Table view
    [self.tableView registerClass:PlacesTableViewCell.class forCellReuseIdentifier:kCollectionCellId];
    self.dataSouce = [[NSMutableArray alloc] init];
    self.tableView.allowsSelection = NO;
    PlacesItem *territory = [[PlacesItem alloc] init];
    territory.header = @"Заповедные территории";
    NSMutableArray *territoryItems = [[NSMutableArray alloc] init];
    ParticularPlaceItem *itemA = [[ParticularPlaceItem alloc] init];
    __weak typeof(self) weakSelf = self;
    __weak typeof(itemA) weakItemA = itemA;
    itemA.onPlaceCellPress = ^void (ParticularPlaceItem *item) {
        DetailsViewController *detailsController = [[DetailsViewController alloc] init];
        detailsController.item = weakItemA;
        [weakSelf.navigationController pushViewController:detailsController animated:YES];
    };
    itemA.name = @"Беловежская пуща";
    ParticularPlaceItem *itemB = [[ParticularPlaceItem alloc] init];
    itemB.name = @"Березинский биосферный заповедник";
    __weak typeof(itemB) weakItemB = itemB;
    itemB.onPlaceCellPress = ^void (ParticularPlaceItem *item) {
        DetailsViewController *detailsController = [[DetailsViewController alloc] init];
        
        detailsController.item = weakItemB;
        [weakSelf.navigationController pushViewController:detailsController animated:YES];
    };
    [territoryItems addObjectsFromArray:@[itemA, itemB]];
    territory.items = territoryItems;
    territory.onAllButtonPress = ^void (PlacesItem *item) {
        PlacesViewController *placesController = [[PlacesViewController alloc] init];
        placesController.item = item;
        [weakSelf.navigationController pushViewController:placesController animated:YES];
    };
    
    PlacesItem *paths = [[PlacesItem alloc] init];
    paths.header = @"Маршруты";
    
    PlacesItem *historicalPlaces = [[PlacesItem alloc] init];
    historicalPlaces.header = @"Исторические места";
    
    PlacesItem *excursions = [[PlacesItem alloc] init];
    excursions.header = @"Экскурсии";
        
    [self.dataSouce addObjectsFromArray:@[territory, paths, historicalPlaces, excursions]];
}


- (void) onSearchPress:(id)sender {
    [self.navigationController pushViewController:[[SearchViewController alloc] init] animated:NO];
}

#pragma mark - Table data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSouce count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PlacesTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kCollectionCellId forIndexPath:indexPath];
    
    [cell update:self.dataSouce[indexPath.row]];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return kTableRowHeight;
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
