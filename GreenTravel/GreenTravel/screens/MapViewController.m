//
//  MapViewController.m
//  GreenTravel
//
//  Created by Alex K on 8/15/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import "MapViewController.h"
#import "Colors.h"
@import Mapbox;
#import "StyleUtils.h"
#import "MapModel.h"

@interface MapViewController ()

@property (strong, nonatomic) MapModel *model;

@end

@implementation MapViewController

- (instancetype)initWithModel:(MapModel *)model {
    self = [super init];
    if (self) {
        _model = model;
    }
    return self;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //self.view.backgroundColor = [Colors get].white;
    
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    configureNavigationBar(navigationBar);
    
    NSURL *url = [NSURL URLWithString:@"mapbox://styles/mapbox/streets-v11"];
    MGLMapView *mapView = [[MGLMapView alloc] initWithFrame:CGRectZero styleURL:url];
    [self.view addSubview:mapView];
    
    mapView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [mapView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [mapView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [mapView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [mapView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
    
    [mapView setCenterCoordinate:CLLocationCoordinate2DMake(53.893, 27.567)
                       zoomLevel:9.0 animated:NO];
    
    [self.model.mapItems enumerateObjectsUsingBlock:^(MapItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
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
