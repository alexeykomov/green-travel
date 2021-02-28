//
//  CategoriesFilterView.m
//  GreenTravel
//
//  Created by Alex K on 2/25/21.
//  Copyright © 2021 Alex K. All rights reserved.
//

#import "CategoriesFilterView.h"
#import "CategoriesFilterCollectionViewCell.h"
#import "FilterOption.h"
#import "CategoriesFilterModel.h"
#import "TextUtils.h"
#import "Colors.h"
#import "IconNameToImageNameMap.h"

static NSString* const kCategoriesFilterCellId = @"categoriesFilterCellId";

@interface CategoriesFilterView()

@property (strong, nonatomic) CategoriesFilterModel *model; 
@property (nonatomic, copy) void(^onFilterUpdate)(NSSet<NSString *>*);

@end

static const CGFloat kInset = 16.0;

@implementation CategoriesFilterView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithIndexModel:(IndexModel *)indexModel
               onFilterUpdate:(void(^)(NSSet<NSString *>*))onFilterUpdate
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    self = [super initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    if (self) {
        [self registerClass:CategoriesFilterCollectionViewCell.class forCellWithReuseIdentifier:kCategoriesFilterCellId];
        self.dataSource = self;
        self.delegate = self;
        self.model = [[CategoriesFilterModel alloc] initWithIndexModel:indexModel];
        self.onFilterUpdate = onFilterUpdate;
        [self.model addObserver:self];
        [self setBackgroundColor:UIColor.clearColor];
        [self setBackgroundColor:[Colors get].blue];
        self.showsHorizontalScrollIndicator = NO;
        self.alwaysBounceHorizontal = YES;
    }
    return self;
}

#pragma mark - Collection view
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.model.filterOptions count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"cellForItemAtIndexPath method, index path: %@", indexPath);
    
    FilterOption *option = self.model.filterOptions[indexPath.row];
    CategoriesFilterCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCategoriesFilterCellId forIndexPath:indexPath];
    [cell update:option];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    FilterOption *option = self.model.filterOptions[indexPath.item];
    CGFloat width = 0;
    CGFloat height = 44.0;
    
    width += 14.0 * 2;
    CGSize textSize = [option.title sizeWithAttributes:
     getTextAttributes(option.on ? [Colors get].white :
                       [Colors get].logCabin, 13.0, UIFontWeightRegular)];
    width += textSize.width;
    
    if (!option.selectAll && [[IconNameToImageNameMap get]
                        hasFilterIconForName:option.iconName]) {
        width += 40.0 + 8.0;
    }
    CGSize size = CGSizeMake(width, height);
    return size;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    FilterOption *option = self.model.filterOptions[indexPath.row];
    [self.model selectOption:option];
}

- (void)onFilterOptionsSelect:(NSUInteger)selectedIndex {
    if (selectedIndex == 0) {
        [self setContentOffset:CGPointMake(0, 0) animated:YES];
        return;
    }
    CategoriesFilterCollectionViewCell *cell = (CategoriesFilterCollectionViewCell *)[self cellForItemAtIndexPath:[NSIndexPath indexPathForItem:selectedIndex inSection:0]];
    [self scrollRectToVisible:cell.frame animated:YES];
}

- (void)onFilterOptionsUpdate:(nonnull NSArray<FilterOption *> *)filterOptions {
    [self reloadData];
    self.onFilterUpdate(self.model.selectedCategoryUUIDs);
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 16.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(16.0,
                            0.0,
                            13.5,
                            kInset);
}

@end
