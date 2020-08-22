//
//  SearchViewController.m
//  GreenTravel
//
//  Created by Alex K on 8/16/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import "SearchViewController.h"
#import "Colors.h"
#import "ParticularPlaceItem.h"
#import "SearchHeaderCell.h"
#import "SearchCell.h"
#import "DetailsViewController.h"
#import "SearchItem.h"
#import "WeRecommendCell.h"    

@interface SearchViewController ()

@property (strong, nonatomic) NSMutableArray<SearchItem *> *dataSourceRecommendations;
@property (strong, nonatomic) NSMutableArray<SearchItem *> *dataSourceOrig;
@property (strong, nonatomic) NSMutableArray<SearchItem *> *dataSourceFiltered;
@property (strong, nonatomic) UISearchController *searchController;

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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.dataSourceRecommendations = [[NSMutableArray alloc] init];
    self.dataSourceOrig = [[NSMutableArray alloc] init];
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
    
    SearchItem *itemA = [[SearchItem alloc] init];
    itemA.header = @"Беловежская пуща";
    itemA.distance = 56.5;
    SearchItem *itemB = [[SearchItem alloc] init];
    itemB.header = @"Нарочанские озера";
    itemB.distance = 100.0;
    SearchItem *itemС = [[SearchItem alloc] init];
    itemС.header = @"Ольшанские болота";
    itemС.distance = 56.0;
    SearchItem *itemD = [[SearchItem alloc] init];
    itemD.header = @"Беловежская пуща";
    itemD.distance = 56.5;
    SearchItem *itemE = [[SearchItem alloc] init];
    itemE.header = @"Нарочанские озера";
    itemE.distance = 100.0;
    
    [self.dataSourceRecommendations addObjectsFromArray:@[itemA, itemB, itemС, itemD, itemE]];
    [self.dataSourceOrig addObjectsFromArray:@[itemA, itemB, itemС, itemD, itemE]];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self isSearching]) {
        return [self.dataSourceFiltered count];
    }
    return [self.dataSourceRecommendations count] + kDataSourceOrigOffset;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0 && ![self isSearching]) {
        SearchHeaderCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kSearchHeaderCellId];
        return cell;
    }
    if (indexPath.row == 1 && ![self isSearching]) {
        WeRecommendCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kWeRecommendCellId];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.userInteractionEnabled = NO;
        return cell;
    }
    SearchCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kSearchCellId];
    SearchItem *item;
    if ([self isSearching]) {
        item = self.dataSourceFiltered[indexPath.row];
    } else {
        item = self.dataSourceRecommendations[indexPath.row - kDataSourceOrigOffset];
    }
    [cell update:item];
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
    DetailsViewController *detailsController = [[DetailsViewController alloc] init];
    if ([self isSearching]) {
        detailsController.item = self.dataSourceFiltered[indexPath.row];
    } else {
        detailsController.item = self.dataSourceRecommendations[indexPath.row - kDataSourceOrigOffset];
    }
    [self.navigationController pushViewController:detailsController animated:YES];
}

#pragma mark - Search

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *search = searchController.searchBar.text;
    [self.dataSourceFiltered removeAllObjects];
    for (SearchItem *item in self.dataSourceOrig) {
        if ([[item searchableText] containsString:search]) {
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
 
