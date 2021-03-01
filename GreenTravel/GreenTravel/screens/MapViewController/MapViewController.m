//
//  NearbyPlacesViewController.m
//  GreenTravel
//
//  Created by Alex K on 8/21/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import "MapViewController.h"
@import Mapbox;
#import "StyleUtils.h"
#import "Colors.h"
#import "MapModel.h"
#import "MapItemsObserver.h"
#import "LocationObserver.h"
#import "MapItem.h"
#import "MapPinView.h"
#import "LocationModel.h"
#import "CategoriesFilterView.h"
#import "IndexModel.h"

@interface MapViewController ()

@property (strong, nonatomic) MapModel *mapModel;
@property (strong, nonatomic) LocationModel *locationModel;
@property (strong, nonatomic) IndexModel *indexModel;
@property (strong, nonatomic) UIButton *locationButton;
@property (strong, nonatomic) MGLMapView *mapView;
@property (assign, nonatomic) BOOL intentionToFocusOnUserLocation;
@property (strong, nonatomic) MapItem *mapItem;
@property (strong, nonatomic) CategoriesFilterView *filterView;

@end

@implementation MapViewController

- (instancetype)initWithMapModel:(MapModel *)mapModel
                   locationModel:(LocationModel *)locationModel
                   indexModel:(IndexModel *)indexModel
                        mapItem:(nullable MapItem *)mapItem {
    self = [super init];
    if (self) {
        _mapModel = mapModel;
        _locationModel = locationModel;
        _mapItem = mapItem;
        _indexModel = indexModel;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = self.mapItem ? self.mapItem.title : @"Карта";
    self.view.backgroundColor = [Colors get].white;
    
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    configureNavigationBar(navigationBar);
    
    NSURL *url = [NSURL URLWithString:@"mapbox://styles/mapbox/streets-v11"];
    self.mapView = [[MGLMapView alloc] initWithFrame:CGRectZero styleURL:url];
    [self.view addSubview:self.mapView];
    
    self.mapView.delegate = self;
    
    self.mapView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.mapView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.mapView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.mapView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.mapView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
    
    [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(53.893, 27.567)
                       zoomLevel:9.0 animated:NO];
    [self.mapModel addObserver:self];
    [self.locationModel addObserver:self];
    
#pragma mark - Categories filter view
    __weak typeof(self) weakSelf = self;
    self.filterView =
    [[CategoriesFilterView alloc] initWithIndexModel:self.indexModel
                                      onFilterUpdate:^(NSSet<NSString *>  * _Nonnull categoryUUIDs) {
        [weakSelf onFilterUpdate:categoryUUIDs];
    }];
    [self.view addSubview:self.filterView];
    self.filterView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [NSLayoutConstraint activateConstraints:@[
        [self.filterView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
        [self.filterView.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
        [self.filterView.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
        [self.filterView.heightAnchor constraintEqualToConstant:73.5],
    ]];
#pragma mark - Location button
    self.locationButton = [[UIButton alloc] init];
    [self.view addSubview:self.locationButton];
    
    self.locationButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    [NSLayoutConstraint activateConstraints:@[
        [self.locationButton.bottomAnchor constraintEqualToAnchor:self.filterView.topAnchor],
        [self.locationButton.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor constant:-8.0],
        [self.locationButton.widthAnchor constraintEqualToConstant:44.0],
        [self.locationButton.heightAnchor constraintEqualToConstant:44.0],
    ]];

    self.locationButton.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.7];
    
    self.locationButton.layer.masksToBounds = YES;
    self.locationButton.layer.cornerRadius = 8.0;
    self.locationButton.layer.borderColor = [[Colors get].alto CGColor];
    self.locationButton.layer.borderWidth = 1.0;
    
    UIImageView *locationImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"location-arrow"]];
    [self.locationButton addSubview:locationImageView];
    
    locationImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [NSLayoutConstraint activateConstraints:@[
        [locationImageView.centerXAnchor constraintEqualToAnchor:self.locationButton.centerXAnchor constant:-2.0],
        [locationImageView.centerYAnchor constraintEqualToAnchor:self.locationButton.centerYAnchor constant:2.0],
        [locationImageView.widthAnchor constraintEqualToConstant:26.0],
        [locationImageView.heightAnchor constraintEqualToConstant:26.0],
    ]];
    
    [self.locationButton addTarget:self action:@selector(onLocateMePress:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)mapViewDidFinishLoadingMap:(MGLMapView *)mapView {
    
    NSMutableArray *mapAnnotations = [[NSMutableArray alloc] init];
    NSArray<MapItem *> *mapItems = self.mapItem ? @[self.mapItem] :
        self.mapModel.mapItemsOriginal;
    [mapItems enumerateObjectsUsingBlock:^(MapItem * _Nonnull mapItem, NSUInteger idx, BOOL * _Nonnull stop) {
        MGLPointAnnotation *point = [[MGLPointAnnotation alloc] init];
        point.coordinate = mapItem.coords;
        point.title = mapItem.title;
        [mapAnnotations addObject:point];
    }];
    
    [mapView addAnnotations:mapAnnotations];
    [mapView showAnnotations:mapAnnotations animated:YES];
}

- (void)onMapItemsUpdate:(NSArray<MapItem *> *)mapItems {
    NSLog(@"Map items: %@", mapItems);
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSMutableArray *mapAnnotations = [[NSMutableArray alloc] init];
        [strongSelf.mapView removeAnnotations:strongSelf.mapView.annotations];
        [mapItems enumerateObjectsUsingBlock:^(MapItem * _Nonnull mapItem, NSUInteger idx, BOOL * _Nonnull stop) {
            MGLPointAnnotation *point = [[MGLPointAnnotation alloc] init];
            point.coordinate = mapItem.coords;
            point.title = mapItem.title;
            [mapAnnotations addObject:point];
        }];
        [strongSelf.mapView addAnnotations:mapAnnotations];
        [strongSelf.mapView showAnnotations:mapAnnotations animated:YES];
    });
    
}

- (MGLAnnotationView *)mapView:(MGLMapView *)mapView viewForAnnotation:(id<MGLAnnotation>)annotation {
    if (![annotation isKindOfClass:[MGLPointAnnotation class]]) {
        return nil;
    }
    NSString *reuseIdentifier = [NSString stringWithFormat:@"%f", annotation.coordinate.longitude];
    
    MapPinView *mappin = [mapView dequeueReusableAnnotationViewWithIdentifier:reuseIdentifier];
    
    if (!mappin) {
        mappin = [[MapPinView alloc] initWithReuseIdentifier:reuseIdentifier];
        mappin.bounds = CGRectMake(0, 0, 28, 35);        
    }
    return mappin;
}

- (BOOL)mapView:(MGLMapView *)mapView annotationCanShowCallout:(id<MGLAnnotation>)annotation {
    return YES;
}

- (void)onAuthorizationStatusChange:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        if (self.locationModel.locationEnabled) {
            [self.locationModel startMonitoring];
        }
    }
}

#pragma mark - Location model

- (void)onLocationUpdate:(CLLocation *)lastLocation {
    if (self.intentionToFocusOnUserLocation) {
        [self.mapView setCenterCoordinate:self.mapModel.lastLocation.coordinate animated:YES];
        self.intentionToFocusOnUserLocation = NO;
    }
}

#pragma mark - Event listeners

- (void)onLocateMePress:(id)sender {
    self.intentionToFocusOnUserLocation = YES;
    [self.locationModel authorize];
    [self.locationModel startMonitoring];
    
    if (self.locationModel.locationEnabled && self.locationModel.lastLocation) {
        [self.mapView setCenterCoordinate:self.mapModel.lastLocation.coordinate animated:YES];
    }
}

- (void)onFilterUpdate:(NSSet<NSString *>*)categoryUUIDs {
    [self.mapModel applyCategoryFilters:categoryUUIDs];
}

@end
