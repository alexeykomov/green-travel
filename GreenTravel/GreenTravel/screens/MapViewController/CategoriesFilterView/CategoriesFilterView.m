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

static NSString* const kCategoriesFilterCellId = @"categoriesFilterCellId";

@interface CategoriesFilterView()

@property (strong, nonatomic) CategoriesFilterModel *model; 
@property (nonatomic, copy) void(^onFilterUpdate)(NSSet<NSString *>*);

@end

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
    self = [super init];
    if (self) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        [self setCollectionViewLayout:flowLayout];
        [self registerClass:CategoriesFilterCollectionViewCell.class forCellWithReuseIdentifier:kCategoriesFilterCellId];
        self.dataSource = self;
        self.model = [[CategoriesFilterModel alloc] initWithIndexModel:indexModel];
        self.onFilterUpdate = onFilterUpdate;
        [self.model addObserver:self];
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
    FilterOption *option = self.model.filterOptions[indexPath.row];
    CGFloat width = 0;
    CGFloat height = 44.0;
    
    width += 14.0 * 2;
    CGSize textSize = [option.categoryTitle sizeWithAttributes:
     getTextAttributes(option.on ? [Colors get].white :
                       [Colors get].logCabin, 13.0, UIFontWeightRegular)];
    width += textSize.width;
    
    if (!option.all) {
        width += 40.0 + 8.0;
    }
    CGSize size = CGSizeMake(width, height);
    return size;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    FilterOption *option = self.model.filterOptions[indexPath.row];
    [self.model selectOption:option];
}

- (void)onFilterOptionsSelect:(nonnull FilterOption *)selectedFilterOption {
    NSUInteger indexOfSelectedOption = [self.model.filterOptions indexOfObjectPassingTest:^BOOL(FilterOption * _Nonnull filterOption, NSUInteger idx, BOOL * _Nonnull stop) {
        return [filterOption.categoryId isEqualToString:selectedFilterOption.categoryId];
    }];
    CategoriesFilterCollectionViewCell *cell = (CategoriesFilterCollectionViewCell *)[self cellForItemAtIndexPath:[NSIndexPath indexPathForItem:indexOfSelectedOption inSection:0]];
    [cell update:selectedFilterOption];
    self.onFilterUpdate(self.model.selectedCategoryUUIDs);
}

- (void)onFilterOptionsUpdate:(nonnull NSArray<FilterOption *> *)filterOptions {
    [self reloadData];
    self.onFilterUpdate(self.model.selectedCategoryUUIDs);
}

@end
