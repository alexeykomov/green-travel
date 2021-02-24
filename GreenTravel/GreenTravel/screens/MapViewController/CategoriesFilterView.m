//
//  CategoriesFilterView.m
//  GreenTravel
//
//  Created by Alex K on 2/25/21.
//  Copyright © 2021 Alex K. All rights reserved.
//

#import "CategoriesFilterView.h"
#import "CategoriesFilterCollectionViewCell.h"

static NSString* const kCategoriesFilterCellId = @"categoriesFilterCellId";

@implementation CategoriesFilterView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)init
{
    self = [super init];
    if (self) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        [self setCollectionViewLayout:flowLayout];
        [self registerClass:CategoriesFilterCollectionViewCell.class forCellWithReuseIdentifier:kCategoriesFilterCellId];
        self.dataSource = self;
    }
    return self;
}

#pragma mark - Collection view

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSUInteger howManyCategories = [self.dataSourceCategories count];
    if (howManyCategories > 0) {
        return howManyCategories;
    }
    return [self.dataSourceItems count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"cellForItemAtIndexPath method, index path: %@", indexPath);
    
    PhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPhotoCellId forIndexPath:indexPath];
    if ([self.dataSourceCategories count] > 0) {
        [cell updateCategory:self.dataSourceCategories[indexPath.row]];
        return cell;
    }
    [cell updateItem:self.dataSourceItems[indexPath.row]];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize adaptedSize = CGSizeMake(self.bounds.size.width - 50, self.bounds.size.height);
    return getCoverSize(adaptedSize);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Did select item at index path: %@", indexPath);
    if ([self.dataSourceCategories count] > 0) {
        Category *category = self.dataSourceCategories[indexPath.row];
        category.onAllButtonPress();
        return;
    }
    
    PlaceItem *item = self.dataSourceItems[indexPath.row];
    item.onPlaceCellPress();
}

@end
