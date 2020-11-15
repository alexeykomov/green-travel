//
//  MainContentViewController.m
//  GreenTravel
//
//  Created by Alex K on 8/15/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import "MainViewController.h"
#import "IndexViewController.h"
#import "MapViewController.h"
#import "BookmarksViewController.h"
#import "Colors.h"
#import "TextUtils.h"
#import "ApiService.h"
#import "IndexModel.h"
#import "DetailsModel.h"
#import "SearchModel.h"
#import "MapModel.h"
#import "BookmarksGroupModel.h"
#import "LocationModel.h"
#import "CoreDataService.h"

@interface MainViewController ()

@property (strong, nonatomic) ApiService *apiService;
@property (strong, nonatomic) CoreDataService *coreDataService;
@property (strong, nonatomic) IndexModel *indexModel;
@property (strong, nonatomic) NSURLSession *session;


@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tabBar.tintColor = [Colors get].green;
    self.tabBar.barTintColor = [Colors get].white;
    if (@available(iOS 13.0, *)) {
    } else {
        self.tabBar.tintColor = [Colors get].white;
    }

    self.view.backgroundColor = [Colors get].white;
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.session = [NSURLSession sessionWithConfiguration:configuration];
    self.apiService = [[ApiService alloc] initWithSession:self.session];
    self.coreDataService = [[CoreDataService alloc] init];
    self.indexModel = [[IndexModel alloc] initWithApiService:self.apiService coreDataService:self.coreDataService];
    DetailsModel *detailsModel = [[DetailsModel alloc] initWithIndexModel:self.indexModel apiService:self.apiService coreDataService:self.coreDataService];
    
    LocationModel *locationModel = [[LocationModel alloc] init];
    SearchModel *searchModel = [[SearchModel alloc]
                                initWithIndexModel:self.indexModel
                                locationModel:locationModel
                                coreDataService:self.coreDataService];
    MapModel *mapModel = [[MapModel alloc] initWithIndexModel:self.indexModel locationModel:locationModel];
    BookmarksGroupModel *bookmarksGroupsModel = [[BookmarksGroupModel alloc] initWithIndexModel:self.indexModel];

#pragma mark - IndexViewController
    
    IndexViewController *indexController = [[IndexViewController alloc]   initWithApiService:self.apiService model:self.indexModel searchModel:searchModel locationModel:locationModel mapModel:mapModel detailsModel:detailsModel coreDataService:self.coreDataService];
    indexController.title = @"Главная";
    UINavigationController *indexViewControllerWithNavigation = [[UINavigationController alloc ] initWithRootViewController:indexController];
    UIImage *indexImage;
    UIImage *indexImageSelected;
    if (@available(iOS 13.0, *)) {
        indexImage = [UIImage systemImageNamed:@"house"];
        indexImageSelected = [UIImage systemImageNamed:@"house.fill"];
    } else {
        indexImage = [UIImage imageNamed:@"noun_Home_1072151"];
        indexImageSelected = [UIImage imageNamed:@"noun_Home_1072151"];
    }
    UITabBarItem *indexTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Главная" image:indexImage tag:0];
    indexTabBarItem.selectedImage = indexImageSelected;
    
    indexViewControllerWithNavigation.tabBarItem = indexTabBarItem;
    
    indexViewControllerWithNavigation.navigationBar.barTintColor = [Colors get].green;
    indexViewControllerWithNavigation.navigationBar.titleTextAttributes =
    getTextAttributes([Colors get].black, 18.0, UIFontWeightSemibold);
    
#pragma mark - MapViewController
    
    MapViewController *mapController = [[MapViewController alloc] initWithMapModel:mapModel locationModel:locationModel mapItem:nil];
    mapController.title = @"Карта";
    UINavigationController *mapControllerWithNavigation = [[UINavigationController alloc ] initWithRootViewController:mapController];
    UIImage *mapImage;
    UIImage *mapImageSelected;
    if (@available(iOS 13.0, *)) {
        mapImage = [UIImage systemImageNamed:@"map"];
        mapImageSelected = [UIImage systemImageNamed:@"map.fill"];
    } else {
        mapImage = [UIImage imageNamed:@"noun_Star_1730824"];
        mapImageSelected = [UIImage imageNamed:@"noun_Star_1730824"];
    }
    UITabBarItem *mapTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Карта" image:mapImage tag:0];
    mapTabBarItem.selectedImage = mapImageSelected;
    
    mapControllerWithNavigation.tabBarItem = mapTabBarItem;
    mapControllerWithNavigation.navigationBar.barTintColor = [Colors get].green;
    mapControllerWithNavigation.navigationBar.titleTextAttributes =
    getTextAttributes([Colors get].black, 18.0, UIFontWeightSemibold);
    
#pragma mark - BookmarksViewController
    
    BookmarksViewController *bookmarksController =
    [[BookmarksViewController alloc] initWithModel:bookmarksGroupsModel
                                        indexModel:self.indexModel
                                        apiService:self.apiService
                                      detailsModel:detailsModel
                                          mapModel:mapModel
                                     locationModel:locationModel];
    bookmarksController.title = @"Закладки";
    UINavigationController *bookmarksControllerWithNavigation = [[UINavigationController alloc ] initWithRootViewController:bookmarksController];
    UIImage *bookmarksImage;
    UIImage *bookmarksImageSelected;
    if (@available(iOS 13.0, *)) {
        bookmarksImage = [UIImage systemImageNamed:@"bookmark"];
        bookmarksImageSelected = [UIImage systemImageNamed:@"bookmark.fill"];
    } else {
        bookmarksImage = [UIImage imageNamed:@"noun_Star_1730824"];
        bookmarksImageSelected = [UIImage imageNamed:@"noun_Star_1730824"];
    }
    UITabBarItem *bookmarksTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Закладки" image:bookmarksImage tag:0];
    bookmarksTabBarItem.selectedImage = bookmarksImageSelected;
    
    bookmarksControllerWithNavigation.tabBarItem = bookmarksTabBarItem;
    bookmarksControllerWithNavigation.navigationBar.barTintColor = [Colors get].green;
    bookmarksControllerWithNavigation.navigationBar.titleTextAttributes =
    getTextAttributes([Colors get].black, 18.0, UIFontWeightSemibold);
    
    self.viewControllers = @[indexViewControllerWithNavigation, mapControllerWithNavigation, bookmarksControllerWithNavigation];
    
    self.selectedIndex = 0;
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
