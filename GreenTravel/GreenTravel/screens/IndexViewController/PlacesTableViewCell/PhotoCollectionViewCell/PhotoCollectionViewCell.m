//
//  PhotoCollectionViewCell.m
//  GreenTravel
//
//  Created by Alex K on 8/16/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import "PlaceItem.h"
#import "Category.h"
#import "PhotoCollectionViewCell.h"
#import "StyleUtils.h"
#import "Colors.h"
#import "TextUtils.h"
#import "ImageUtils.h"

@interface PhotoCollectionViewCell ()

@property (strong, nonatomic) Category *category;
@property (strong, nonatomic) PlaceItem *item;
@property (strong, nonatomic) UILabel *headerLabel;
@property (strong, nonatomic) UIButton *favoritesButton;
@property (strong, nonatomic) UIImageView *placeholder;
@property (strong, nonatomic) SDWebImageCombinedOperation *loadImageOperation;



@end

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
    self.placeholder = [[UIImageView alloc] init];
    [self addSubview:self.placeholder];
    
    self.placeholder.contentMode = UIViewContentModeScaleAspectFill;
    self.placeholder.translatesAutoresizingMaskIntoConstraints = NO;
    self.placeholder.backgroundColor = [Colors get].blue;
    
    self.placeholder.layer.cornerRadius = 15.0;
    self.placeholder.layer.masksToBounds = YES;
    
    [NSLayoutConstraint activateConstraints:@[
        [self.placeholder.topAnchor constraintEqualToAnchor:self.topAnchor],
        [self.placeholder.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [self.placeholder.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [self.placeholder.bottomAnchor constraintEqualToAnchor:self.bottomAnchor]
    ]];
    
#pragma mark - Header label
    self.headerLabel = [[UILabel alloc] init];
    [self addSubview:self.headerLabel];
    
    self.headerLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.headerLabel setFont:[UIFont fontWithName:@"OpenSans-Bold" size:16.0]];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.headerLabel.topAnchor constraintEqualToAnchor:self.topAnchor constant:16.0],
        [self.headerLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:16.0],
        [self.headerLabel.heightAnchor constraintEqualToConstant:20.0]
    ]];
    
    self.favoritesButton = [UIButton systemButtonWithImage:[UIImage systemImageNamed:@"bookmark"] target:self action:@selector(onFavoritePress:)];
    self.favoritesButton.tintColor = [Colors get].white;
    [self addSubview:self.favoritesButton];
    
    self.favoritesButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    [NSLayoutConstraint activateConstraints:@[
        [self.favoritesButton.topAnchor constraintEqualToAnchor:self.headerLabel.topAnchor],
        [self.favoritesButton.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.headerLabel.trailingAnchor constant:16.0],
        [self.favoritesButton.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-16.0],
        [self.favoritesButton.widthAnchor constraintEqualToConstant:21.0]
    ]];
#pragma mark - Subscribe to device orientation change
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(onDeviceOrientationChange:)
     name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)onFavoritePress:(id)sender {
    NSLog(@"Favorites button pressed.");
    NSLog(@"item: %@", self.item);
    self.item.onFavoriteButtonPress();
    //[self.favoritesButton setSelected:self.item.bookmarked];
}

- (void)onPlaceButtonPress:(id)sender {
    
}

- (void)updateItem:(PlaceItem *)item {
    self.item = item;
    self.headerLabel.attributedText = getAttributedString(item.title, [Colors get].white, 16.0, UIFontWeightBold);
    [self.favoritesButton setSelected:item.bookmarked];
    loadImage(item.cover, ^(UIImage *image) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.placeholder setImage:image];
        });
    });
    drawShadow(self);
}

- (void)updateBookmark:(BOOL)bookmark {
    NSLog(@"updateBookmark");
    [self.favoritesButton setSelected:bookmark];
}

- (void)updateCategory:(Category *)category {
     self.headerLabel.attributedText = getAttributedString(category.title, [Colors get].white, 16.0, UIFontWeightBold);
    [self.favoritesButton setHidden:YES];
    self.loadImageOperation = loadImage(category.cover, ^(UIImage *image) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.placeholder setImage:image];
        });
    });
    drawShadow(self);
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.loadImageOperation cancel];
    self.layer.shadowPath = nil;
}

- (void)onDeviceOrientationChange:(id)sender {
    drawShadow(self);
}

@end
