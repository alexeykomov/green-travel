//
//  BookmarksViewController.m
//  GreenTravel
//
//  Created by Alex K on 8/15/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import "BookmarksViewController.h"
#import "Colors.h"
#import "StyleUtils.h"
#import "BookmarkCell.h"
#import "PlacesItem.h"
#import "PlacesViewController.h"

@interface BookmarksViewController ()

@property(strong, nonatomic) NSMutableArray<PlacesItem *> *dataSource;

@end

static NSString * const kBookmarkCellId = @"bookmarkCellId";
static const CGFloat kCellAspectRatio = 166.0 / 104.0;

@implementation BookmarksViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        self = [self initWithCollectionViewLayout:layout];
    }
    return self;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [Colors get].white;
    
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    configureNavigationBar(navigationBar);
    
    
    [self.collectionView registerClass:BookmarkCell.class forCellWithReuseIdentifier:kBookmarkCellId];
    self.collectionView.backgroundColor = [Colors get].white;
    self.collectionView.alwaysBounceVertical = YES;
    
#pragma mark - Places
    self.dataSource = [[NSMutableArray alloc] init];
    
    PlacesItem *territory = [[PlacesItem alloc] init];
    territory.header = @"Заповедные территории";
    territory.items = @[];
    
    PlacesItem *paths = [[PlacesItem alloc] init];
    paths.header = @"Маршруты";
    
    PlacesItem *historicalPlaces = [[PlacesItem alloc] init];
    historicalPlaces.header = @"Исторические места";
    
    PlacesItem *excursions = [[PlacesItem alloc] init];
    excursions.header = @"Экскурсии";   
    
    [self.dataSource addObjectsFromArray:@[territory, paths, historicalPlaces, excursions]];
    
    [self.collectionView reloadData];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return ceil((float)[self.dataSource count] / 2.0);
;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 2;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"cellForItemAtIndexPath method, index path: %@", indexPath);
    BookmarkCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kBookmarkCellId forIndexPath:indexPath];
    [cell update:self.dataSource[indexPath.row]];
    return cell;
}

#pragma mark <UICollectionViewDelegateFlowLayout>

static const CGFloat INSET = 12.0;
static const CGFloat SPACING = 12.0;

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat baseWidth = self.collectionView.bounds.size.width;
    
    long index = indexPath.row + indexPath.section * 2;
    if (index >= [self.dataSource count]) {
        return CGSizeZero;
    }
    
    return CGSizeMake((baseWidth - INSET * 2 - SPACING * 2) / 2,
                      (baseWidth / kCellAspectRatio - INSET * 2 - SPACING * 2) / 2);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return SPACING;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (section > 0) {
        return UIEdgeInsetsMake(0, INSET, INSET, INSET);
    }
    return UIEdgeInsetsMake(INSET, INSET, INSET, INSET);
}

#pragma mark <UICollectionViewDelegate>


// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}



// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Selected cell at index path: %@", indexPath);
    PlacesViewController *placesViewController = [[PlacesViewController alloc] init];
    placesViewController.item = self.dataSource[indexPath.row];
    [self.navigationController pushViewController:placesViewController animated:YES];
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
