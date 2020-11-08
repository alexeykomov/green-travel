//
//  PlacesViewController.m
//  GreenTravel
//
//  Created by Alex K on 8/19/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import "PlacesViewController.h"
#import "Category.h"
#import "PhotoCollectionViewCell.h"
#import "Colors.h"
#import "PlaceItem.h"
#import "DetailsViewController.h"
#import "IndexModel.h"
#import "DetailsModel.h"
#import "MapModel.h"
#import "LocationModel.h"
#import "CategoryUtils.h"

@interface PlacesViewController ()

@property (assign, nonatomic) BOOL bookmarked;
@property (strong, nonatomic) NSMutableArray<PlaceItem *> *bookmarkedItems;
@property (strong, nonatomic) ApiService *apiService;
@property (strong, nonatomic) DetailsModel *detailsModel;
@property (strong, nonatomic) MapModel *mapModel;
@property (strong, nonatomic) LocationModel *locationModel;
@property (strong, nonatomic) IndexModel *indexModel;

@end

@implementation PlacesViewController

static NSString * const kPhotoCellId = @"photoCellId";
static const CGFloat kCellAspectRatio = 324.0 / 144.0;

- (instancetype)initWithIndexModel:(IndexModel *)indexModel
                        apiService:(ApiService *)apiService
                      detailsModel:(DetailsModel *)detailsModel
                          mapModel:(MapModel *)mapModel
                     locationModel:(LocationModel *)locationModel
                        bookmarked:(BOOL)bookmarked
                  allowedItemUUIDs:(NSOrderedSet<NSString *> *)allowedItemUUIDs;
{
    self = [super init];
    if (self) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        self = [self initWithCollectionViewLayout:flowLayout];
        _bookmarked = bookmarked;
        _indexModel = indexModel;
        _apiService = apiService;
        _detailsModel = detailsModel;
        _mapModel = mapModel;
        _locationModel = locationModel;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    self.collectionView.backgroundColor = [Colors get].white;
    // Register cell classes
    [self.collectionView registerClass:[PhotoCollectionViewCell class] forCellWithReuseIdentifier:kPhotoCellId];
    self.collectionView.alwaysBounceVertical = YES;
    
    self.title = self.category.title;
    
    if (!self.bookmarked) {
        [self.collectionView reloadData];
    }
    [self.indexModel addObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    if (self.bookmarked) {
        self.bookmarkedItems = [[NSMutableArray alloc] initWithArray:[self.category.items
        filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"bookmarked == YES"]]];
        [self.collectionView reloadData];
        if ([self.bookmarkedItems count] == 0) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    
    traverseCategories(@[self.category], ^(Category *category, PlaceItem *item) {
        category.onPlaceCellPress = ^{};
        item.onPlaceCellPress = ^{};
    });
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [self.collectionView.collectionViewLayout invalidateLayout];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSUInteger howManyCategories = [self.category.categories count];
    if (howManyCategories > 0) {
        return howManyCategories;
    }
    if (self.bookmarked) {
        return [self.bookmarkedItems count];
    }
    return [self.category.items count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPhotoCellId forIndexPath:indexPath];
    
    if ([self.category.categories count] > 0) {
        [cell updateCategory:self.category.categories[indexPath.row]];
    } else if (self.bookmarked) {
        [cell updateItem:self.bookmarkedItems[indexPath.row]];
    } else {
        [cell updateItem:self.category.items[indexPath.row]];
    }
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

static const CGFloat kInset = 12.0;
static const CGFloat kSpacing = 12.0;

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat baseWidth = self.view.bounds.size.width;
    
    return CGSizeMake((baseWidth - kInset * 2),
                      ((baseWidth - kInset * 2) / kCellAspectRatio));
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Did select item at index path: %@", indexPath);
    if ([self.category.categories count] > 0) {
        Category *category = self.category.categories[indexPath.row];
        
        PlacesViewController *placesViewController =
        [[PlacesViewController alloc] initWithIndexModel:self.indexModel
                                              apiService:self.apiService
                                            detailsModel:self.detailsModel
                                                mapModel:self.mapModel
                                           locationModel:self.locationModel
                                              bookmarked:NO
                                        allowedItemUUIDs:nil];
        placesViewController.category = category;
        [self.navigationController pushViewController:placesViewController animated:YES];
        
        return;
    }
    PlaceItem *item;
    if (self.bookmarked) {
        item = self.bookmarkedItems[indexPath.row];
    } else {
        item = self.category.items[indexPath.row];
    }
    DetailsViewController *detailsViewController = [[DetailsViewController alloc] initWithApiService:self.apiService detailsModel:self.detailsModel indexModel:self.indexModel mapModel:self.mapModel locationModel:self.locationModel];
    detailsViewController.item = item;
    [self.navigationController pushViewController:detailsViewController animated:YES];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return kSpacing;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (section > 0) {
        return UIEdgeInsetsMake(0, kInset, kInset, kInset);
    }
    return UIEdgeInsetsMake(kInset, kInset, kInset, kInset);
}

- (void)onBookmarkUpdate:(nonnull PlaceItem *)item bookmark:(BOOL)bookmark {
    NSUInteger foundIndex = NSNotFound;
    BOOL(^indexOfObjectPassingTest)(PlaceItem *, NSUInteger , BOOL*) = ^BOOL(PlaceItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return [obj.uuid isEqualToString:item.uuid];
    };
    if (self.bookmarked) {
        foundIndex = [self.bookmarkedItems indexOfObjectPassingTest:indexOfObjectPassingTest];
    } else {
        foundIndex = [self.category.items indexOfObjectPassingTest:indexOfObjectPassingTest];
    }
    
    if (foundIndex == NSNotFound) {
        return;
    }
    NSIndexPath *indexPathOfFoundIndex =  [NSIndexPath indexPathForItem:foundIndex inSection:0];
    PhotoCollectionViewCell *cell = (PhotoCollectionViewCell *) [self.collectionView cellForItemAtIndexPath:indexPathOfFoundIndex];
    [cell updateBookmark:bookmark];
    if (!self.bookmarked) {
        return;
    }
    if (!bookmark) {
        __weak typeof(self) weakSelf = self;
        [self.collectionView performBatchUpdates:^{
            [weakSelf.bookmarkedItems removeObjectAtIndex:indexPathOfFoundIndex.item];
            [weakSelf.collectionView deleteItemsAtIndexPaths:@[indexPathOfFoundIndex]];
        } completion:^(BOOL finished) {
        }];
    }
    
    if ([self.bookmarkedItems count] == 0) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)onCategoriesUpdate:(nonnull NSArray<Category *> *)categories {
    
}

@end
