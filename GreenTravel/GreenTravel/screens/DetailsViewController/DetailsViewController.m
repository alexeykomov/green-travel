//
//  DetailsViewController.m
//  GreenTravel
//
//  Created by Alex K on 8/19/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import "DetailsViewController.h"
#import "Colors.h"
#import "PlaceItem.h"
#import "PlaceDetails.h"
#import "ApiService.h"
#import "DetailsModel.h"
#import "LocationModel.h"
#import "MapModel.h"
#import "IndexModel.h"
#import "MapItem.h"
#import "ImageUtils.h"
#import "TextUtils.h"
#import "MapViewController.h"
#import "LinkedCategoriesView.h"
#import "BannerView.h"
#import "GalleryView.h"
#import "CategoryUtils.h"
#import "Typography.h"
#import "CommonButton.h"
#import "DescriptionView.h"
#import "DetailsView.h"
#import "PlacesViewController.h"

@interface DetailsViewController ()

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) BannerView *copiedBannerView;
@property (strong, nonatomic) NSLayoutConstraint *copiedBannerViewTopConstraint;
@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) DetailsView *detailsView;
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
@property (strong, nonatomic) ApiService *apiService;
@property (strong, nonatomic) NSTimer *bannerHideTimer;
@property (strong, nonatomic) UIViewPropertyAnimator *bannerShowAnimator;
@property (strong, nonatomic) UIViewPropertyAnimator *bannerHideAnimator;

@property (assign, nonatomic) BOOL ready;
@property (strong, nonatomic) LocationModel *locationModel;
@property (strong, nonatomic) MapModel *mapModel;
@property (strong, nonatomic) IndexModel *indexModel;
@property (assign, nonatomic) BOOL resized;
@property (assign, nonatomic) CGSize screenSize;

@end

@implementation DetailsViewController

- (instancetype)initWithApiService:(ApiService *)apiService
                      indexModel:(IndexModel *)indexModel
                          mapModel:(MapModel *)mapModel
                     locationModel:(LocationModel *)locationModel
{
    self = [super init];
    if (self) {
        _apiService = apiService;
        _mapModel = mapModel;
        _indexModel = indexModel;
        _locationModel = locationModel;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [Colors get].white;
    self.title = self.item.title;
        
    #pragma mark - Scroll view
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.scrollView.alwaysBounceVertical = YES;
    [self.view addSubview:self.scrollView];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.scrollView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.scrollView.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
        [self.scrollView.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
        [self.scrollView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor]
    ]];
    
    self.contentView = [[UIView alloc] init];
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView addSubview:self.contentView];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.contentView.topAnchor constraintEqualToAnchor:self.scrollView.topAnchor],
        [self.contentView.leadingAnchor constraintEqualToAnchor:self.scrollView.leadingAnchor],
        [self.contentView.trailingAnchor constraintEqualToAnchor:self.scrollView.trailingAnchor],
        [self.contentView.bottomAnchor constraintEqualToAnchor:self.scrollView.bottomAnchor],
        [self.contentView.widthAnchor constraintEqualToAnchor:self.scrollView.widthAnchor]
    ]];
        
    __weak typeof(self) weakSelf = self;
    self.detailsView = [[DetailsView alloc] initWithItem:self.item onBookmarkButtonPress:^{
        [weakSelf onBookmarkButtonPress:nil];
    } onLocationButtonPress:^{
        [weakSelf onLocationButtonPress:nil];
    } onMapButtonPress:^{
        [weakSelf onMapButtonPress:nil];
    } onCategoriesLinkPress:^(NSOrderedSet<NSString *>* _Nonnull linkedItems, Category *category){
        __strong typeof(weakSelf) strongSelf = weakSelf;
        PlacesViewController *placesViewController =
        [[PlacesViewController alloc] initWithIndexModel:strongSelf.indexModel
                                              apiService:strongSelf.apiService
                                                mapModel:strongSelf.mapModel
                                           locationModel:strongSelf.locationModel
                                              bookmarked:NO
                                        allowedItemUUIDs:linkedItems];
        placesViewController.category = category;
        [strongSelf.navigationController pushViewController:placesViewController animated:YES];
    }];
    [self.contentView addSubview:self.detailsView];
    self.detailsView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.detailsView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor],
        [self.detailsView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor],
        [self.detailsView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor],
        [self.detailsView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor],
    ]];
    
#pragma mark - "Copied" banner
    self.copiedBannerView = [[BannerView alloc] init];
    self.copiedBannerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.copiedBannerView];
    
    self.copiedBannerViewTopConstraint = [self.copiedBannerView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:-56.0];
    [NSLayoutConstraint activateConstraints:@[
        self.copiedBannerViewTopConstraint,
        [self.copiedBannerView.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
        [self.copiedBannerView.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
        [self.copiedBannerView.heightAnchor constraintEqualToConstant:56.0]
    ]];
    
#pragma mark - Add observers
    [self.indexModel addObserver:self];
    [self.indexModel addObserverBookmarks:self];
    
#pragma mark - Load data
    [self updateMainContent:self.item.details];
    if (!self.ready) {
        [self.activityIndicatorView startAnimating];
        [self.activityIndicatorView setHidden:NO];
    }
}

- (void)updateMainContent:(PlaceDetails *)details {
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{
        NSAttributedString *html = getAttributedStringFromHTML(details.descriptionHTML);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!self.ready) {
                self.ready = YES;
                [self.activityIndicatorContainerView setHidden:YES];
                [self.activityIndicatorView stopAnimating];
            }
            self.titleLabel.attributedText = [[Typography get] makeTitle1Semibold:self.item.title];
            if (details.address) {
                self.addressLabel.attributedText = [[Typography get] makeSubtitle3Regular:self.item.title];
            }
            [self.locationButton setAttributedTitle:
             [[Typography get] makeSubtitle3Regular:[NSString stringWithFormat:@"%f° N, %f° E", self.item.coords.latitude, self.item.coords.longitude] color:[Colors get].royalBlue]
             forState:UIControlStateNormal];
            [self.descriptionTextView update:html showPlaceholder:[details.descriptionHTML length] == 0];
            if (details.categoryIdToItems) {
                [self.linkedCategoriesView update:details.categoryIdToItems];
            } else {
                [self.linkedCategoriesView setHidden:YES];
            }
        });
    });
}

- (void)updateDetails {
    PlaceDetails *details = self.item.details;
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.imageGalleryView setUpWithPictureURLs:details.images];
    });
    [self updateMainContent:details];
}

#pragma mark - Observers

- (void)onBookmarkUpdate:(PlaceItem *)item bookmark:(BOOL)bookmark {
    if ([self.item.uuid isEqualToString:item.uuid]) {
        [self.bookmarkButton setSelected:bookmark];
    }
}

- (void)onCategoriesUpdate:(nonnull NSArray<Category *> *)categories {
    NSString *itemUUID = self.item.uuid;
    __weak typeof(self) weakSelf = self;
    traverseCategories(categories, ^(Category *newCategory, PlaceItem *newItem) {
        if ([newItem.uuid isEqualToString:itemUUID]) {
            weakSelf.item = newItem;
        }
    });
    [self updateDetails];
}

- (void)onCategoriesLoading:(BOOL)loading {}

- (void)onCategoriesNewDataAvailable {}

- (void)onMapButtonPress:(id)sender {
    MapItem *mapItem = [[MapItem alloc] init];
    mapItem.title = self.item.title;
    mapItem.uuid = self.item.uuid;
    mapItem.correspondingPlaceItem = self.item;
    mapItem.coords = self.item.coords;
    MapViewController *mapViewController = [[MapViewController alloc] initWithMapModel:self.mapModel locationModel:self.locationModel indexModel:self.indexModel mapItem:mapItem];
    [self.navigationController pushViewController:mapViewController animated:YES]; 
}

- (void)onLocationButtonPress:(id)sender {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = [NSString stringWithFormat:@"%f,%f", self.item.coords.latitude, self.item.coords.longitude];
    
    [self cancelBanner];
    
    __weak typeof(self) weakSelf = self;
    self.bannerShowAnimator = [[UIViewPropertyAnimator alloc] initWithDuration:0.4 curve:UIViewAnimationCurveEaseIn animations:^{
        weakSelf.copiedBannerViewTopConstraint.constant = 0;
        [weakSelf.view layoutIfNeeded];
    }];
    [self.bannerShowAnimator startAnimation];
    self.bannerHideTimer =
    [NSTimer scheduledTimerWithTimeInterval:5.4
                                     target:self
                                   selector:@selector(onBannerTimerFire:)
                                   userInfo:nil
                                    repeats:NO];
}

- (void)cancelBanner {
    [self.bannerShowAnimator stopAnimation:YES];
    self.bannerShowAnimator = nil;
    //[self.bannerHideAnimator stopAnimation:YES];
    //self.bannerHideAnimator = nil;
    [self.bannerHideTimer invalidate];
    self.bannerHideTimer = nil;
    self.copiedBannerViewTopConstraint.constant = -44.0;
    [self.view layoutIfNeeded];
}

- (void)onBannerTimerFire:(id)sender {
    NSLog(@"Timer fired.");
    [self.bannerHideTimer invalidate];
    self.bannerHideTimer = nil;
    //self.copiedBannerViewTopConstraint.constant = -44.0;
    [self.view layoutIfNeeded];
    
    __weak typeof(self) weakSelf = self;
    self.bannerHideAnimator = [[UIViewPropertyAnimator alloc] initWithDuration:0.4 curve:UIViewAnimationCurveEaseIn animations:^{
        weakSelf.copiedBannerViewTopConstraint.constant = -56.0;
        [weakSelf.view layoutIfNeeded];
    }];
    [self.bannerHideAnimator startAnimation];
}

- (void)onBookmarkButtonPress:(id)sender {
    [self.indexModel bookmarkItem:self.item bookmark:!self.item.bookmarked];
}

#pragma mark - Resize
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [self.imageGalleryView setNeedsLayout];
    [self.imageGalleryView layoutIfNeeded];
    [self.imageGalleryView.collectionView reloadData];
    CGPoint pointToScrollTo = CGPointMake(self.imageGalleryView.indexOfScrolledItem * size.width, 0);
    [self.imageGalleryView.collectionView setContentOffset:pointToScrollTo animated:YES];
    [self.imageGalleryView toggleSkipAnimation]; 
//    if (!CGSizeEqualToSize(self.screenSize, size)) {
//        self.screenSize = size;
//        self.resized = YES;
//    }
    
}

//- (void)viewDidLayoutSubviews {
//    [super viewDidLayoutSubviews];
//    if (self.resized) {
//        [self.imageGalleryView setNeedsLayout];
//        [self.imageGalleryView layoutIfNeeded];
//        CGPoint pointToScrollTo = CGPointMake(self.imageGalleryView.indexOfScrolledItem * self.screenSize.width, 0);
//        [self.imageGalleryView.collectionView setContentOffset:pointToScrollTo];
//        self.resized = NO;
//    }
//}

@end
