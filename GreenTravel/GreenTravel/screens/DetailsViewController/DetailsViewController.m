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
#import "MapItem.h"
#import "ImageUtils.h"
#import "TextUtils.h"
#import "MapViewController.h"

@interface DetailsViewController ()

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *addressLabel;
@property (strong, nonatomic) UILabel *locationLabel;
@property (strong, nonatomic) UIImageView *previewImageView;
@property (strong, nonatomic) UIButton *mapButtonTop;
@property (strong, nonatomic) UIButton *mapButtonBottom;
@property (strong, nonatomic) UITextView *descriptionTextView;
@property (strong, nonatomic) UILabel *interestingLabel;
@property (strong, nonatomic) UIView *activityIndicatorContainerView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;
@property (strong, nonatomic) ApiService *apiService;

@property (assign, nonatomic) BOOL ready;
@property (strong, nonatomic) LocationModel *locationModel;
@property (strong, nonatomic) MapModel *mapModel;
@property (strong, nonatomic) DetailsModel *detailsModel;
@property (strong, nonatomic) PlaceDetails *details;
@property (strong, nonatomic) NSLayoutConstraint *aspectRatioConstraint;

@end

@implementation DetailsViewController

- (instancetype)initWithApiService:(ApiService *)apiService
                      detailsModel:(DetailsModel *)detailsModel
                          mapModel:(MapModel *)mapModel
                     locationModel:(LocationModel *)locationModel
{
    self = [super init];
    if (self) {
        _apiService = apiService;
        _detailsModel = detailsModel;
        _mapModel = mapModel;
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
        
    #pragma mark - Preview image
    self.previewImageView = [[UIImageView alloc] init];
    self.previewImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.previewImageView.backgroundColor = [Colors get].black;
    self.previewImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.previewImageView.layer.masksToBounds = YES;
    
    [self.contentView addSubview:self.previewImageView];
    
    self.aspectRatioConstraint = [self.previewImageView.heightAnchor constraintEqualToAnchor:self.previewImageView.widthAnchor multiplier:1];
    [NSLayoutConstraint activateConstraints:@[
        [self.previewImageView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:0.0],
        [self.previewImageView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:0.0],
        [self.previewImageView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:0.0],
        self.aspectRatioConstraint,
    ]];
        
    #pragma mark - Title label
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.numberOfLines = 4;
    [self.titleLabel setFont:[UIFont fontWithName:@"Montserrat-Semibold" size:20.0]];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;

    [self.contentView addSubview:self.titleLabel];

    [NSLayoutConstraint activateConstraints:@[
        [self.titleLabel.topAnchor constraintEqualToAnchor:self.previewImageView.bottomAnchor constant:29.0],
        [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:16.0],
        [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-16.0],

    ]];
    
    #pragma mark - Address label
    self.addressLabel = [[UILabel alloc] init];
    self.addressLabel.numberOfLines = 4;
    [self.addressLabel setFont:[UIFont fontWithName:@"OpenSans-Regular" size:14.0]];
    self.addressLabel.translatesAutoresizingMaskIntoConstraints = NO;

    [self.contentView addSubview:self.addressLabel];

    [NSLayoutConstraint activateConstraints:@[
        [self.addressLabel.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:8.0],
        [self.addressLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:16.0],
        [self.addressLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-16.0],

    ]];
    
    #pragma mark - Location label
    self.locationLabel = [[UILabel alloc] init];
    self.locationLabel.numberOfLines = 4;
    [self.locationLabel setFont:[UIFont fontWithName:@"OpenSans-Regular" size:14.0]];
    self.locationLabel.translatesAutoresizingMaskIntoConstraints = NO;

    [self.contentView addSubview:self.locationLabel];

    [NSLayoutConstraint activateConstraints:@[
        [self.locationLabel.topAnchor constraintEqualToAnchor:self.addressLabel.bottomAnchor constant:0.0],
        [self.locationLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:16.0],
        [self.locationLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-16.0],

    ]];
    
    #pragma mark - Map button top
    self.mapButtonTop = [[UIButton alloc] init];
    self.mapButtonTop.translatesAutoresizingMaskIntoConstraints = NO;
    self.mapButtonTop.backgroundColor = [Colors get].apple;
    self.mapButtonTop.layer.cornerRadius = 8.0;
    self.mapButtonTop.layer.masksToBounds = YES;
    [self.mapButtonTop.titleLabel setFont:[UIFont fontWithName:@"OpenSans-Bold" size:14.0]];
    [self.mapButtonTop setAttributedTitle:getAttributedString(@"Как добраться", [Colors get].white, 14.0, UIFontWeightBold) forState:UIControlStateNormal];
    
    [self.mapButtonTop addTarget:self action:@selector(onMapButtonPress:) forControlEvents:UIControlEventTouchUpInside];

    [self.contentView addSubview:self.mapButtonTop];

    [NSLayoutConstraint activateConstraints:@[
        [self.mapButtonTop.topAnchor constraintEqualToAnchor:self.locationLabel.bottomAnchor constant:20.0],
        [self.mapButtonTop.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:16.0],
        [self.mapButtonTop.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-16.0],
        [self.mapButtonTop.widthAnchor constraintLessThanOrEqualToConstant:343.0],
        [self.mapButtonTop.heightAnchor constraintEqualToConstant:48.0],
    ]];
    
    #pragma mark - Description text
    self.descriptionTextView = [[UITextView alloc] init];

    self.descriptionTextView.backgroundColor = [Colors get].apple;

    self.descriptionTextView.translatesAutoresizingMaskIntoConstraints = NO;
    self.descriptionTextView.editable = NO;
    self.descriptionTextView.scrollEnabled = NO;
    [self.contentView addSubview:self.descriptionTextView];

    [NSLayoutConstraint activateConstraints:@[
        [self.descriptionTextView.topAnchor constraintEqualToAnchor:self.mapButtonTop.bottomAnchor constant:26.0],
        [self.descriptionTextView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:16.0],
        [self.descriptionTextView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-16.0],
    ]];
        
    #pragma mark - "Will be interesting" label
    self.interestingLabel = [[UILabel alloc] init];

    self.interestingLabel.numberOfLines = 2;
    [self.interestingLabel setFont:[UIFont fontWithName:@"Montserrat-SemiBold" size:20.0]];
    self.interestingLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.interestingLabel.attributedText =
    getAttributedString(@"Будет интересно", [Colors get].black, 20.0,
                        UIFontWeightSemibold);

    [self.contentView addSubview:self.interestingLabel];

    [NSLayoutConstraint activateConstraints:@[
        [self.interestingLabel.topAnchor constraintEqualToAnchor:self.descriptionTextView.bottomAnchor constant:32.0],
        [self.interestingLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:16.0],
        [self.interestingLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-16.0],

    ]];
        
    #pragma mark - Map button bottom
    self.mapButtonBottom = [[UIButton alloc] init];
    self.mapButtonBottom.translatesAutoresizingMaskIntoConstraints = NO;
    self.mapButtonBottom.backgroundColor = [Colors get].apple;
    self.mapButtonBottom.layer.cornerRadius = 8.0;
    self.mapButtonBottom.layer.masksToBounds = YES;
    [self.mapButtonBottom.titleLabel setFont:[UIFont fontWithName:@"OpenSans-Bold" size:14.0]];
    [self.mapButtonBottom setAttributedTitle:getAttributedString(@"Как добраться", [Colors get].white, 14.0, UIFontWeightBold) forState:UIControlStateNormal];

    [self.mapButtonBottom addTarget:self action:@selector(onMapButtonPress:) forControlEvents:UIControlEventTouchUpInside];

    [self.contentView addSubview:self.mapButtonBottom];

    [NSLayoutConstraint activateConstraints:@[
        [self.mapButtonBottom.topAnchor constraintEqualToAnchor:self.interestingLabel.bottomAnchor constant:32.0],
        [self.mapButtonBottom.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:16.0],
        [self.mapButtonBottom.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-16.0],
        [self.mapButtonBottom.widthAnchor constraintLessThanOrEqualToConstant:343.0],
        [self.mapButtonBottom.heightAnchor constraintEqualToConstant:48.0],
        [self.mapButtonBottom.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-37.5],
    ]];
    
#pragma mark - Activity indicator
    self.activityIndicatorContainerView = [[UIView alloc] init];
    self.activityIndicatorContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.activityIndicatorContainerView.backgroundColor = [Colors get].white;
    [self.view addSubview:self.activityIndicatorContainerView];
    [NSLayoutConstraint activateConstraints:@[
        [self.activityIndicatorContainerView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.activityIndicatorContainerView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.activityIndicatorContainerView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.activityIndicatorContainerView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];
    
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicatorView.hidesWhenStopped = YES;
    self.activityIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.activityIndicatorContainerView addSubview:self.activityIndicatorView];
    [NSLayoutConstraint activateConstraints:@[
        [self.activityIndicatorView.centerXAnchor constraintEqualToAnchor:self.activityIndicatorContainerView.centerXAnchor],
        [self.activityIndicatorView.centerYAnchor constraintEqualToAnchor:self.activityIndicatorContainerView.centerYAnchor]
    ]];
    
    [self.detailsModel addObserver:self];
#pragma mark - Load data
    [self.detailsModel loadDetailsByUUID:self.item.uuid];
    if (!self.ready) {
        [self.activityIndicatorView startAnimating];
        [self.activityIndicatorView setHidden:NO];
    }
}

- (void)onDetailsUpdate:(NSMutableDictionary<NSString *,PlaceDetails *> *)itemUUIDToDetails items:(NSMutableDictionary<NSString *,PlaceItem *> *)itemUUIDToItem {
    PlaceDetails *details = itemUUIDToDetails[self.item.uuid];
    PlaceItem *item = itemUUIDToItem[self.item.uuid];
    __weak typeof(self) weakSelf = self;
    if (!self.details && details) {
        loadImage(details.images[0], ^(UIImage *image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                CGFloat aspectRatio = image.size.height / image.size.width;
                [NSLayoutConstraint deactivateConstraints:@[weakSelf.aspectRatioConstraint]];
                weakSelf.aspectRatioConstraint = [weakSelf.previewImageView.heightAnchor constraintEqualToAnchor:weakSelf.previewImageView.widthAnchor multiplier:aspectRatio];
                [NSLayoutConstraint activateConstraints:@[
                    weakSelf.aspectRatioConstraint
                ]];
                [weakSelf.previewImageView setImage:image];
            });
        });
    }
    NSAttributedString *html = getAttributedStringFromHTML(details.descriptionHTML);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.ready) {
            self.ready = YES;
            [self.activityIndicatorContainerView setHidden:YES];
            [self.activityIndicatorView stopAnimating];
        }
        weakSelf.titleLabel.attributedText = getAttributedString(item.title, [Colors get].black, 20.0, UIFontWeightSemibold);
        weakSelf.addressLabel.attributedText = getAttributedString(details.address, [Colors get].black, 14.0, UIFontWeightRegular);
        weakSelf.locationLabel.attributedText = getAttributedString([NSString stringWithFormat:@"%f° N, %f° E", item.coords.longitude, item.coords.latitude], [Colors get].black, 14.0, UIFontWeightRegular);
        [weakSelf.descriptionTextView setAttributedText:html];
    });
}

- (void)onMapButtonPress:(id)sender {
    MapItem *mapItem = [[MapItem alloc] init];
    mapItem.title = self.item.title;
    mapItem.uuid = self.item.uuid;
    mapItem.correspondingPlaceItem = self.item;
    mapItem.coords = self.item.coords;
    MapViewController *mapViewController = [[MapViewController alloc] initWithMapModel:self.mapModel locationModel:self.locationModel mapItem:mapItem];
    [self.navigationController pushViewController:mapViewController animated:YES]; 
}

@end
