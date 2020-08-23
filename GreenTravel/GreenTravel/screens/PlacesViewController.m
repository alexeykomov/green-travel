//
//  PlacesViewController.m
//  GreenTravel
//
//  Created by Alex K on 8/19/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import "PlacesViewController.h"
#import "PlacesItem.h"
#import "PhotoCollectionViewCell.h"
#import "Colors.h"
#import "ParticularPlaceItem.h"

@interface PlacesViewController ()

@end

@implementation PlacesViewController

static NSString * const kPhotoCellId = @"photoCellId";
static const CGFloat kCellAspectRatio = 324.0 / 144.0;

- (instancetype)init
{
    self = [super init];
    if (self) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        self = [self initWithCollectionViewLayout:flowLayout];
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
    
    self.title = self.item.header;
    [self.collectionView reloadData];
    
    // Do any additional setup after loading the view.
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

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
#warning Incomplete implementation, return the number of sections
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of items
    return [self.item.items count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPhotoCellId forIndexPath:indexPath];
    
    
    
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
    ParticularPlaceItem *item = self.item.items[indexPath.row];
    item.onPlaceCellPress(item);
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

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
