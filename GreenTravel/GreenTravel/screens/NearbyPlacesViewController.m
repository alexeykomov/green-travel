//
//  NearbyPlacesViewController.m
//  GreenTravel
//
//  Created by Alex K on 8/21/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import "NearbyPlacesViewController.h"
@import Mapbox;
#import "StyleUtils.h"
#import "Colors.h"
#import "MapModel.h"
#import "MapItemsObserver.h"
#import "MapItem.h"
#import "MapPinView.h"

@interface NearbyPlacesViewController ()

@property (strong, nonatomic) MapModel *mapModel;
@property (strong, nonatomic) UIButton *locationButton;
@property (strong, nonatomic) MGLMapView *mapView;
@property (assign, nonatomic) BOOL showClosestPoints;

@end

@implementation NearbyPlacesViewController

- (instancetype)initWithMapModel:(MapModel *)mapModel
                 showClosestPoints:(BOOL)showClosestPoints{
    self = [super init];
    if (self) {
        _mapModel = mapModel;
        _showClosestPoints = showClosestPoints; 
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Рядом";
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
    
    self.locationButton = [[UIButton alloc] init];
    [self.view addSubview:self.locationButton];
    
    self.locationButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    [NSLayoutConstraint activateConstraints:@[
        [self.locationButton.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-100.0],
        [self.locationButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-8.0],
        [self.locationButton.widthAnchor constraintEqualToConstant:44.0],
        [self.locationButton.heightAnchor constraintEqualToConstant:44.0],
    ]];

    
    self.locationButton.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.7];
    
    self.locationButton.layer.masksToBounds = YES;
    self.locationButton.layer.cornerRadius = 20.0;
    
    UIImage *image = [UIImage imageNamed:@"noun_Location_403482_2"];
    UIImageView *locationImageView = [[UIImageView alloc] initWithImage:[image imageWithTintColor:UIColor.systemBlueColor]];
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
    NSArray<MapItem *> *closeItems = self.mapModel.closeMapItems;
    [closeItems enumerateObjectsUsingBlock:^(MapItem * _Nonnull mapItem, NSUInteger idx, BOOL * _Nonnull stop) {
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
        //mappin.backgroundColor = [Colors get].black;
        
    }
    return mappin;
}

- (BOOL)mapView:(MGLMapView *)mapView annotationCanShowCallout:(id<MGLAnnotation>)annotation {
    return YES;
}

- (void)onLocateMePress:(id)sender {
    [self.mapView setCenterCoordinate:self.mapModel.lastLocation.coordinate animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
