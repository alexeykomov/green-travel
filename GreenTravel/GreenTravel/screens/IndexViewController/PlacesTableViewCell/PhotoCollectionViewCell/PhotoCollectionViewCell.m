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
#import "GradientOverlayView.h"
#import "Colors.h"
#import "TextUtils.h"
#import "ImageUtils.h"
#import "Typography.h"

@interface PhotoCollectionViewCell ()

@property (strong, nonatomic) Category *category;
@property (strong, nonatomic) PlaceItem *item;
@property (strong, nonatomic) UILabel *headerLabel;
@property (strong, nonatomic) UIButton *favoritesButton;
@property (strong, nonatomic) UIView *overlayView;
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
    self.overlayView = [[GradientOverlayView alloc] initWithFrame:CGRectZero];
    
    [self addSubview:self.placeholder];
    
    self.placeholder.contentMode = UIViewContentModeScaleAspectFill;
    self.placeholder.translatesAutoresizingMaskIntoConstraints = NO;
    self.placeholder.backgroundColor = [Colors get].blue;
    
    self.placeholder.layer.cornerRadius = 4.0;
    self.placeholder.layer.masksToBounds = YES;
    
    [NSLayoutConstraint activateConstraints:@[
        [self.placeholder.topAnchor constraintEqualToAnchor:self.topAnchor],
        [self.placeholder.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [self.placeholder.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [self.placeholder.bottomAnchor constraintEqualToAnchor:self.bottomAnchor]
    ]];
    [self.placeholder addSubview:self.overlayView];
    self.overlayView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.overlayView.topAnchor constraintEqualToAnchor:self.placeholder.topAnchor],
        [self.overlayView.leadingAnchor constraintEqualToAnchor:self.placeholder.leadingAnchor],
        [self.overlayView.trailingAnchor constraintEqualToAnchor:self.placeholder.trailingAnchor],
        [self.overlayView.bottomAnchor constraintEqualToAnchor:self.placeholder.bottomAnchor]
    ]];
    
#pragma mark - Header label
    self.headerLabel = [[UILabel alloc] init];
    [self addSubview:self.headerLabel];
    
    self.headerLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.headerLabel setFont:[UIFont fontWithName:@"Montserrat-Bold" size:15.0]];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.headerLabel.topAnchor constraintEqualToAnchor:self.topAnchor constant:16.0],
        [self.headerLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:16.0],
        [self.headerLabel.heightAnchor constraintEqualToConstant:20.0]
    ]];
#pragma mark - Favorites button
    self.favoritesButton = [[UIButton alloc] init];
    UIImage *imageNotSelected = [[UIImage imageNamed:@"bookmark-index"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImage *imageSelected = [[UIImage imageNamed:@"bookmark-index-selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.favoritesButton setImage:imageNotSelected forState:UIControlStateNormal];
    [self.favoritesButton setImage:imageSelected forState:UIControlStateSelected];
    [self.favoritesButton addTarget:self action:@selector(onFavoritePress:) forControlEvents:UIControlEventTouchUpInside];
    
    self.favoritesButton.tintColor = [Colors get].white;
    [self addSubview:self.favoritesButton];
    
    self.favoritesButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    [NSLayoutConstraint activateConstraints:@[
        [self.favoritesButton.topAnchor constraintEqualToAnchor:self.headerLabel.topAnchor],
        [self.favoritesButton.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.headerLabel.trailingAnchor constant:16.0],
        [self.favoritesButton.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-16.0],
        //[self.favoritesButton.widthAnchor constraintEqualToConstant:21.0]
    ]];
}

- (void)onFavoritePress:(id)sender {
    NSLog(@"Favorites button pressed.");
    NSLog(@"item: %@", self.item);
    self.item.onFavoriteButtonPress();
}

- (void)onPlaceButtonPress:(id)sender {
    
}

- (void)updateItem:(PlaceItem *)item {
    self.item = item;
    self.headerLabel.attributedText = [[Typography get] makeCardsTitle2Bold:item.title];
    [self.favoritesButton setHidden:NO];
    [self.favoritesButton setSelected:item.bookmarked];
    if (item.cover != nil && item.cover != [NSNull null] &&
        [item.cover length] > 0) {
        __weak typeof (self) weakSelf = self;
        self.loadImageOperation = loadImage(item.cover, ^(UIImage *image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.placeholder setImage:image];
            });
        });
    } else {
        [self.placeholder setImage:nil];
    }
    
    [self updateOverlayAndShadow];
}

- (void)updateBookmark:(BOOL)bookmark {
    NSLog(@"updateBookmark");
    [self.favoritesButton setSelected:bookmark];
}

- (void)updateCategory:(Category *)category {
     self.headerLabel.attributedText = [[Typography get] makeCardsTitle2Bold:category.title];
    [self.favoritesButton setHidden:YES];
    if (category.cover != nil && category.cover != [NSNull null] &&
        [category.cover length] > 0) {
        __weak typeof (self) weakSelf = self;
        self.loadImageOperation = loadImage(category.cover, ^(UIImage *image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.placeholder setImage:image];
            });
        });
    } else {
        [self.placeholder setImage:nil];
    }
    [self updateOverlayAndShadow];
}

- (void)updateOverlayAndShadow {
    drawShadow(self);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateOverlayAndShadow];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.loadImageOperation cancel];
    [self.placeholder setImage:nil];
    self.layer.shadowPath = nil;
}

@end
