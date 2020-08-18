//
//  PhotoCollectionViewCell.m
//  GreenTravel
//
//  Created by Alex K on 8/16/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import "PhotoCollectionViewCell.h"
#import "Colors.h"
#import "TextUtils.h"
#import "DetailsViewController.h"

@implementation PhotoCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;
}

- (void)setUp {
#pragma mark - Image
    
    UIImageView *placeholder = [[UIImageView alloc] init];
    [self addSubview:placeholder];
    
    placeholder.translatesAutoresizingMaskIntoConstraints = NO;
    placeholder.backgroundColor = [Colors get].blue;
    
    placeholder.layer.cornerRadius = 15.0;
    placeholder.layer.masksToBounds = YES;
    
    [NSLayoutConstraint activateConstraints:@[
        [placeholder.topAnchor constraintEqualToAnchor:self.topAnchor],
        [placeholder.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [placeholder.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [placeholder.bottomAnchor constraintEqualToAnchor:self.bottomAnchor]
    ]];
    
#pragma mark - Header label
    UILabel *headerLabel = [[UILabel alloc] init];
    [self addSubview:headerLabel];
    
    headerLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [headerLabel setFont:[UIFont fontWithName:@"OpenSans-Bold" size:16.0]];
    headerLabel.attributedText = getAttributedString(@"Беловежская пуща", [Colors get].white, 16.0, UIFontWeightBold);
    
    [NSLayoutConstraint activateConstraints:@[
        [headerLabel.topAnchor constraintEqualToAnchor:self.topAnchor constant:16.0],
        [headerLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:16.0],
        [headerLabel.heightAnchor constraintEqualToConstant:20.0]
    ]];
    
    UILabel *favoritesButton = [UIButton systemButtonWithImage:[UIImage systemImageNamed:@"bookmark"] target:self action:@selector(onFavoritePress:)];
    favoritesButton.tintColor = [Colors get].white;
    [self addSubview:favoritesButton];
    
    favoritesButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    [NSLayoutConstraint activateConstraints:@[
        [favoritesButton.topAnchor constraintEqualToAnchor:headerLabel.topAnchor],
        [favoritesButton.leadingAnchor constraintEqualToAnchor:headerLabel.trailingAnchor constant:16.0],
        [favoritesButton.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-16.0]
    ]];
}

- (void)onFavoritePress:(id)sender {
    NSLog(@"Favorites button pressed.");
}

- (void)onPlaceButtonPress:(id)sender {
    
}

@end
