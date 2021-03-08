//
//  DescriptionView.m
//  GreenTravel
//
//  Created by Alex K on 3/8/21.
//  Copyright © 2021 Alex K. All rights reserved.
//

#import "DetailsView.h"
#import "LinkedCategoriesView.h"
#import "BannerView.h"
#import "GalleryView.h"
#import "CategoryUtils.h"
#import "Typography.h"
#import "CommonButton.h"
#import "Colors.h"
#import "PlaceItem.h"
#import "PlaceDetails.h"
#import "PlacesViewController.h"
#import "DescriptionView.h"
#import "Category.h"


@interface DetailsView()

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *addressLabel;
@property (strong, nonatomic) UIButton *bookmarkButton;
@property (strong, nonatomic) UIButton *locationButton;
@property (strong, nonatomic) GalleryView *imageGalleryView;
@property (strong, nonatomic) UIButton *mapButtonTop;
@property (strong, nonatomic) UIButton *mapButtonBottom;
@property (strong, nonatomic) DescriptionView *descriptionTextView;
@property (strong, nonatomic) UIStackView *descriptionPlaceholderView;
@property (strong, nonatomic) UILabel *interestingLabel;
@property (strong, nonatomic) LinkedCategoriesView *linkedCategoriesView;
@property (strong, nonatomic) NSLayoutConstraint *linkedCategoriesViewHeightConstraint;
@property (strong, nonatomic) UIView *activityIndicatorContainerView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;

@property (strong, nonatomic) PlaceItem *item;
@property (copy, nonatomic) void(^onBookmarkButtonPress)(void);
@property (copy, nonatomic) void(^onLocationButtonPress)(void);
@property (copy, nonatomic) void(^onMapButtonPress)(void);
@property (copy, nonatomic) void(^onCategoriesLinkPress)(NSOrderedSet<NSString *> *, Category *);

@end

@implementation DetailsView

- (instancetype)initWithItem:(PlaceItem *)item
       onBookmarkButtonPress:(void(^)(void))onBookmarkButtonPress
       onLocationButtonPress:(void(^)(void))onLocationButtonPress
            onMapButtonPress:(void(^)(void))onMapButtonPress
       onCategoriesLinkPress:(void(^)(NSOrderedSet<NSString *> *, Category *))onCategoriesLinkPress
{
    self = [super init];
    if (self) {
        self.onBookmarkButtonPress = onBookmarkButtonPress;
        self.onLocationButtonPress = onLocationButtonPress;
        self.onMapButtonPress = onMapButtonPress;
        self.onCategoriesLinkPress = onCategoriesLinkPress;
        [self setUp];
    }
    return self;
}

- (void)setUp {
    #pragma mark - Gallery
    self.imageGalleryView = [[GalleryView alloc] initWithFrame:CGRectZero
                                                     imageURLs:self.item.details.images];
    self.imageGalleryView.translatesAutoresizingMaskIntoConstraints = NO;
    self.imageGalleryView.layer.masksToBounds = YES;

    [self addSubview:self.imageGalleryView];

    [NSLayoutConstraint activateConstraints:@[
        [self.imageGalleryView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [self.imageGalleryView.topAnchor constraintEqualToAnchor:self.topAnchor],
        [self.imageGalleryView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
    ]];

    #pragma mark - Bookmark button
    self.bookmarkButton = [[UIButton alloc] init];

    self.bookmarkButton.backgroundColor = [Colors get].white;
    self.bookmarkButton.contentMode = UIViewContentModeScaleAspectFill;
    self.bookmarkButton.layer.cornerRadius = 22.0;
    self.bookmarkButton.layer.borderWidth = 1.0;
    self.bookmarkButton.layer.borderColor = [[Colors get].heavyMetal35 CGColor];
    self.bookmarkButton.layer.masksToBounds = YES;
    UIImage *imageNotSelected = [[UIImage imageNamed:@"bookmark-index"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImage *imageSelected = [[UIImage imageNamed:@"bookmark-index-selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

    [self.bookmarkButton setImage:imageNotSelected forState:UIControlStateNormal];
    [self.bookmarkButton setImage:imageSelected forState:UIControlStateSelected];

    self.bookmarkButton.tintColor = [Colors get].logCabin;
    [self.bookmarkButton setSelected:self.item.bookmarked];

    [self.bookmarkButton addTarget:self action:@selector(onBookmarkButtonPress:) forControlEvents:UIControlEventTouchUpInside];

    self.bookmarkButton.translatesAutoresizingMaskIntoConstraints = NO;

    [self addSubview:self.bookmarkButton];

    [NSLayoutConstraint activateConstraints:@[
        [self.bookmarkButton.topAnchor constraintEqualToAnchor:self.topAnchor constant:32.0],
        [self.bookmarkButton.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-16.0],
        [self.bookmarkButton.widthAnchor constraintEqualToConstant:44.0],
        [self.bookmarkButton.heightAnchor constraintEqualToConstant:44.0],
    ]];
        
    #pragma mark - Title label
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.numberOfLines = 4;
    [self.titleLabel setFont:[UIFont fontWithName:@"Montserrat-Semibold" size:20.0]];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;

    [self addSubview:self.titleLabel];

    [NSLayoutConstraint activateConstraints:@[
        [self.titleLabel.topAnchor constraintEqualToAnchor:self.imageGalleryView.bottomAnchor],
        [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:16.0],
        [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-16.0],

    ]];

    #pragma mark - Address label
    self.addressLabel = [[UILabel alloc] init];
    self.addressLabel.numberOfLines = 4;
    [self.addressLabel setFont:[UIFont fontWithName:@"OpenSans-Regular" size:14.0]];
    self.addressLabel.translatesAutoresizingMaskIntoConstraints = NO;

    [self addSubview:self.addressLabel];

    [NSLayoutConstraint activateConstraints:@[
        [self.addressLabel.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:8.0],
        [self.addressLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:16.0],
        [self.addressLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-16.0],

    ]];

    #pragma mark - Location button
    self.locationButton = [[UIButton alloc] init];
    [self.locationButton.titleLabel setFont:[UIFont fontWithName:@"OpenSans-Regular" size:14.0]];

    [self.locationButton addTarget:self action:@selector(onLocationButtonPress:) forControlEvents:UIControlEventTouchUpInside];

    self.locationButton.translatesAutoresizingMaskIntoConstraints = NO;

    [self addSubview:self.locationButton];

    [NSLayoutConstraint activateConstraints:@[
        [self.locationButton.topAnchor constraintEqualToAnchor:self.addressLabel.bottomAnchor constant:3.0],
        [self.locationButton.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:16.0],
    ]];

    #pragma mark - Map button top
    self.mapButtonTop = [[CommonButton alloc] initWithTarget:self action:@selector(onMapButtonPress:) label:@"Посмотреть на карте"];

    [self addSubview:self.mapButtonTop];

    NSLayoutConstraint *mapButtonTopLeading = [self.mapButtonTop.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:16.0];
    NSLayoutConstraint *mapButtonTopTrailing = [self.mapButtonTop.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-16.0];
    mapButtonTopLeading.priority = UILayoutPriorityDefaultHigh - 1;
    mapButtonTopTrailing.priority = UILayoutPriorityDefaultHigh - 1;
    [NSLayoutConstraint activateConstraints:@[
        [self.mapButtonTop.topAnchor constraintEqualToAnchor:self.locationButton.bottomAnchor constant:20.0],
        [self.mapButtonTop.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
        mapButtonTopLeading,
        mapButtonTopTrailing,
    ]];

    #pragma mark - Description text
    self.descriptionTextView = [[DescriptionView alloc] init];

    self.descriptionTextView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.descriptionTextView];

    [NSLayoutConstraint activateConstraints:@[
        [self.descriptionTextView.topAnchor constraintEqualToAnchor:self.mapButtonTop.bottomAnchor constant:26.0],
        [self.descriptionTextView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [self.descriptionTextView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
    ]];
    
    #pragma mark - Linked items
    __weak typeof(self) weakSelf = self;
    self.linkedCategoriesView =
    [[LinkedCategoriesView alloc] initWithIndexModel:nil
                                          apiService:nil
                                            mapModel:nil
                                       locationModel:nil
                          pushToNavigationController:^(PlacesViewController * _Nonnull placesViewController){}
                               onCategoriesLinkPress:self.onCategoriesLinkPress];

    self.linkedCategoriesView.translatesAutoresizingMaskIntoConstraints = NO;

    [self addSubview:self.linkedCategoriesView];

    [NSLayoutConstraint activateConstraints:@[
        [self.linkedCategoriesView.topAnchor constraintEqualToAnchor:self.descriptionTextView.bottomAnchor constant:32.0],
        [self.linkedCategoriesView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:0],
        [self.linkedCategoriesView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:0],
        [self.linkedCategoriesView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-10.5],
    ]];

    #pragma mark - Activity indicator
    self.activityIndicatorContainerView = [[UIView alloc] init];
    self.activityIndicatorContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.activityIndicatorContainerView.backgroundColor = [Colors get].white;
    [self addSubview:self.activityIndicatorContainerView];
    [NSLayoutConstraint activateConstraints:@[
        [self.activityIndicatorContainerView.topAnchor constraintEqualToAnchor:self.topAnchor],
        [self.activityIndicatorContainerView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [self.activityIndicatorContainerView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [self.activityIndicatorContainerView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
    ]];

    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicatorView.hidesWhenStopped = YES;
    self.activityIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.activityIndicatorContainerView addSubview:self.activityIndicatorView];
    [NSLayoutConstraint activateConstraints:@[
        [self.activityIndicatorView.centerXAnchor constraintEqualToAnchor:self.activityIndicatorContainerView.centerXAnchor],
        [self.activityIndicatorView.centerYAnchor constraintEqualToAnchor:self.activityIndicatorContainerView.centerYAnchor]
    ]];
}

- (void)onBookmarkButtonPress:(id)sender {
    self.onBookmarkButtonPress();
}

- (void)onLocationButtonPress:(id)sender {
    self.onLocationButtonPress();
}

- (void)onMapButtonPress:(id)sender {
    self.onMapButtonPress();
}


@end
