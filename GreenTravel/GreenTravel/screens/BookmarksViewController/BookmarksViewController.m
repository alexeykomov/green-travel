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
#import "Category.h"
#import "PlacesViewController.h"
#import "BookmarksGroupModel.h"
#import "BookmarkItem.h"

@interface BookmarksViewController ()

@property (strong, nonatomic) BookmarksGroupModel *model;

@end

static NSString * const kBookmarkCellId = @"bookmarkCellId";
static const CGFloat kCellAspectRatio = 166.0 / 104.0;

@implementation BookmarksViewController

- (instancetype)initWithModel:(BookmarksGroupModel *)model
{
    self = [super init];
    if (self) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        self = [self initWithCollectionViewLayout:layout];
        _model = model;
    }
    return self;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.collectionView.backgroundColor = [Colors get].green;
    
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    configureNavigationBar(navigationBar);
    
    
    [self.collectionView registerClass:BookmarkCell.class forCellWithReuseIdentifier:kBookmarkCellId];
    self.collectionView.backgroundColor = [Colors get].white;
    self.collectionView.alwaysBounceVertical = YES;
    
    [self.model addObserver:self];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return ceil((float)[self.model.bookmarkItems count] / 2.0);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 2;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"cellForItemAtIndexPath method, index path: %@", indexPath);
    BookmarkCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kBookmarkCellId forIndexPath:indexPath];
    
    long index = indexPath.row + indexPath.section * 2;

    if (index >= [self.model.bookmarkItems count]) {
        return cell;
    }
    
    [cell update:self.model.bookmarkItems[index]];
    return cell;
}

#pragma mark <UICollectionViewDelegateFlowLayout>

static const CGFloat kInset = 12.0;
static const CGFloat kSpacing = 12.0;

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [self.collectionView.collectionViewLayout invalidateLayout];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize layoutGuide = [self.view.safeAreaLayoutGuide layoutFrame].size;
    CGFloat baseWidth = self.collectionView.bounds.size.width;
    NSLog(@"Base width: %f", self.collectionView.bounds.size.width);
    NSLog(@"Bounds: %@", @(self.collectionView.bounds));
    NSLog(@"Safe are layout guide size: %@", @([self.view.safeAreaLayoutGuide layoutFrame].size));
    //CGFloat baseWidth = layoutGuide.width;
    
    long index = indexPath.row + indexPath.section * 2;
    if (index >= [self.model.bookmarkItems count]) {
        return CGSizeZero;
    }
    
    CGSize cellSize = CGSizeMake((baseWidth - 3 * kInset) / 2,
                                 ((baseWidth - 3 * kInset) / kCellAspectRatio ) / 2);
    
    return cellSize;
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
    
    long index = indexPath.row + indexPath.section * 2;
    
    if (index >= [self.model.bookmarkItems count]) {
        return;
    }
    BookmarkItem *bookmarkItem = self.model.bookmarkItems[index];
    if (bookmarkItem.howMany == 0) {
        return;
    }
    
    PlacesViewController *placesViewController = [[PlacesViewController alloc] init];
    placesViewController.category = bookmarkItem.correspondingCategory;
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

- (void)onBookmarksUpdate:(nonnull NSArray<BookmarkItem *> *)bookmarkItems {
    [self.collectionView reloadData];
}

@end
