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

static NSString * const kPhotoCellId = @"photoCellId";

@interface PlacesTableViewCell ()

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
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
    [collectionView registerClass:PhotoCollectionViewCell.class forCellWithReuseIdentifier:kPhotoCellId];
    collectionView.delegate = self;
    
    [self addSubview:collectionView];
    self.backgroundColor = [Colors get].green;
    
    self.headerLabel = [[UILabel alloc] init];
    [self addSubview:self.headerLabel];
    [self.headerLabel setFont:[UIFont fontWithName:@"Montserrat-Bold" size:12.0]];
    
    self.headerLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.headerLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [self.headerLabel.topAnchor constraintEqualToAnchor:self.topAnchor]
    ]];
}

#pragma mark - Collection view

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
#warning Incomplete implementation, return the number of sections
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 3;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"cellForItemAtIndexPath method, index path: %@", indexPath);
    long index = indexPath.row + indexPath.section * 3;

    PhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPhotoCellId forIndexPath:indexPath];
    
    
    return cell;
}

@end
