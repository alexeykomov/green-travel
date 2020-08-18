//
//  PlacesTableViewCell.m
//  GreenTravel
//
//  Created by Alex K on 8/16/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import "PlacesTableViewCell.h"
#import "PhotoCollectionViewCell.h"
#import "Colors.h"
#import "TextUtils.h"
#import "PlacesItem.h"

static NSString * const kPhotoCellId = @"photoCellId";

@interface PlacesTableViewCell ()

@property (strong, nonatomic) UILabel *headerLabel;
@property (strong, nonatomic) UIButton *allButton;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) NSArray<ParticularPlaceItem *> *dataSource;

@end

@implementation PlacesTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setUp];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setUp {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    [self.collectionView registerClass:PhotoCollectionViewCell.class forCellWithReuseIdentifier:kPhotoCellId];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [Colors get].green;
    self.collectionView.alwaysBounceHorizontal = YES;
    
    [self addSubview:self.collectionView];
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.collectionView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:10.0],
        [self.collectionView.topAnchor constraintEqualToAnchor:self.topAnchor constant:10.0],
        [self.collectionView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-10.0],
        [self.collectionView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-10.0],
    ]];
    
    self.headerLabel = [[UILabel alloc] init];
    [self addSubview:self.headerLabel];
    [self.headerLabel setFont:[UIFont fontWithName:@"Montserrat-Bold" size:12.0]];
    
    self.headerLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.headerLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:16.0],
        [self.headerLabel.topAnchor constraintEqualToAnchor:self.topAnchor constant:24.0]
    ]];
    
    self.allButton = [[UIButton alloc] init];
    [self addSubview:self.allButton];
    [self.allButton setAttributedTitle:getAttributedString(@"Все", [Colors get].green, 12.0, UIFontWeightRegular) forState:UIControlStateNormal];
    
    self.allButton.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.allButton.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-16.0],
        [self.allButton.topAnchor constraintEqualToAnchor:self.headerLabel.topAnchor constant:-8.0]
    ]];
}

- (void)update:(PlacesItem *)item {
    self.headerLabel.attributedText = getAttributedString([item.header uppercaseString], [Colors get].black, 12.0, UIFontWeightBold);
    self.dataSource = item.items;
    [self.collectionView reloadData];
}

#pragma mark - Collection view

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.dataSource count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"cellForItemAtIndexPath method, index path: %@", indexPath);
    PhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPhotoCellId forIndexPath:indexPath];
    
    return cell;
}

@end
