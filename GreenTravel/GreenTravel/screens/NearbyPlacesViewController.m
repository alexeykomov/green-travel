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

@interface NearbyPlacesViewController ()

@property (strong, nonatomic) MapModel *mapModel;

@end

@implementation NearbyPlacesViewController

- (instancetype)initWithMapModel:(MapModel *)mapModel {
    self = [super init];
    if (self) {
        _mapModel = mapModel;
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
    MGLMapView *mapView = [[MGLMapView alloc] initWithFrame:CGRectZero styleURL:url];
    [self.view addSubview:mapView];
    
    mapView.delegate = self;
    
    mapView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [mapView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [mapView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [mapView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [mapView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
    
    [mapView setCenterCoordinate:CLLocationCoordinate2DMake(53.893, 27.567)
                       zoomLevel:9.0 animated:NO];
    [self.mapModel addObserver:self];  
}

- (void)onMapItemsUpdate:(NSArray<MapItem *> *)mapItems {
    
}

- (void)mapView:(MGLMapView *)mapView didFinishLoadingStyle:(MGLStyle *)style {
    [self.mapModel.mapItems enumerateObjectsUsingBlock:^(MapItem * _Nonnull mapItem, NSUInteger idx, BOOL * _Nonnull stop) {
        MGLPointAnnotation *point = [[MGLPointAnnotation alloc] init];
        point.coordinate = mapItem.coords;
        
        MGLShapeSource *shapeSource = [[MGLShapeSource alloc] initWithIdentifier:@"marker-source" shape:point options:nil];
        MGLSymbolStyleLayer *shapeLayer = [[MGLSymbolStyleLayer alloc] initWithIdentifier:@"marker-style" source:shapeSource];
        
        [style setImage:[UIImage imageNamed:@"mappin"] forName:@"place-symbol"];
        shapeLayer.iconImageName = [NSExpression expressionForConstantValue:@"place-symbol"];
        
        [style addSource:shapeSource];
        [style addLayer:shapeLayer];
    }];
    
    
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
