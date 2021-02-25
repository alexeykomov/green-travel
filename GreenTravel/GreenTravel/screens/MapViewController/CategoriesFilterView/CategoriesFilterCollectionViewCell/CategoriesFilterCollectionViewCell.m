//
//  CategoriesFilterCollectionViewCell.m
//  GreenTravel
//
//  Created by Alex K on 2/25/21.
//  Copyright © 2021 Alex K. All rights reserved.
//

#import "CategoriesFilterCollectionViewCell.h"
#import "IconNameToImageNameMap.h"
#import "FilterOption.h"
#import "Typography.h"
#import "Colors.h"

@implementation CategoriesFilterCollectionViewCell

@interface CategoriesFilterCollectionViewCell ()

@property (strong, nonatomic) Category *category;
@property (strong, nonatomic) PlaceItem *item;
@property (strong, nonatomic) UILabel *label;

@property (strong, nonatomic) UIView *overlayView;
@property (strong, nonatomic) UIImageView *iconView;
@property (strong, nonatomic) SDWebImageCombinedOperation *loadImageOperation;

@end

@implementation CategoriesFilterCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;
}

- (void)setUp {
#pragma mark - Icon
    self.iconView = [[UIImageView alloc] init];
    [self.contentView addSubview:self.iconView];
    self.label.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activate:@[
        [self.iconView.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
        [self.iconView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:14.0],
        [self.label.topAnchor constraintEqualToAnchor:self.label.topAnchor],
        [self.label.topAnchor constraintEqualToAnchor:self.label.topAnchor],
    ]];
    
    
    self.label = [[UILabel alloc] init];
    [self.contentView addSubview:self.label];
    self.label.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activate:@[
        [self.label.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
        [self.label.leadingAnchor constraintEqualToAnchor:self.label.topAnchor],
        [self.label.topAnchor constraintEqualToAnchor:self.label.topAnchor],
        [self.label.topAnchor constraintEqualToAnchor:self.label.topAnchor],
    ]];
}

- (void)update:(FilterOption *)option {
    if (option.iconName) {
        [self.iconView setImage:[[IconNameToImageNameMap get] iconForName:option.iconName]];
    } else {
        [self.iconView removeFromSuperview];
    }
    if (option.on) {
        [self.label setAttributedText:[[Typography get] makeSubtitle2Regular:option.categoryTitle color:[Colors get].logCabin]];
        [self.iconView setTintColor:[Colors get].logCabin]];
        return;
    }
    [self.label setAttributedText:[[Typography get] makeSubtitle2Regular:option.categoryTitle color:[Colors get].logCabin]];
    [self.iconView setTintColor:[Colors get].logCabin]];
}

@end
