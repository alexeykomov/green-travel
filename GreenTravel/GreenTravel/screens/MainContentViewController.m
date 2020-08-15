//
//  MainContentViewController.m
//  GreenTravel
//
//  Created by Alex K on 8/15/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import "MainContentViewController.h"
#import "IndexViewController.h"
#import "MapViewController.h"
#import "BookmarksViewController.h"
#import "Colors.h"
#import "TextUtils.h"

@interface MainContentViewController ()

@end

@implementation MainContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tabBar.tintColor = [Colors get].grey;
    self.tabBar.barTintColor = [Colors get].darkGrey;
    if (@available(iOS 13.0, *)) {
    } else {
        self.tabBar.tintColor = [Colors get].white;
    }

#pragma mark - IndexViewController
    
    IndexViewController *indexController = [[IndexViewController alloc] init];
    indexController.title = @"";
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
    UITabBarItem *indexTabBarItem = [[UITabBarItem alloc] initWithTitle:@"" image:indexImage tag:0];
    indexTabBarItem.selectedImage = indexImageSelected;
    
    indexViewControllerWithNavigation.tabBarItem = indexTabBarItem;
    
    indexViewControllerWithNavigation.navigationBar.barTintColor = [Colors get].black;
    indexViewControllerWithNavigation.navigationBar.titleTextAttributes =
    getTextAttributes([Colors get].black, 18.0, UIFontWeightSemibold);
    
#pragma mark - MapViewController
    
    MapViewController *mapController = [[MapViewController alloc] init];
    mapController.title = @"";
    UINavigationController *mapControllerWithNavigation = [[UINavigationController alloc ] initWithRootViewController:mapController];
    UIImage *mapImage;
    UIImage *mapImageSelected;
    if (@available(iOS 13.0, *)) {
        mapImage = [UIImage systemImageNamed:@"star"];
        mapImageSelected = [UIImage systemImageNamed:@"star.fill"];
    } else {
        mapImage = [UIImage imageNamed:@"noun_Star_1730824"];
        mapImageSelected = [UIImage imageNamed:@"noun_Star_1730824"];
    }
    UITabBarItem *mapTabBarItem = [[UITabBarItem alloc] initWithTitle:@"" image:mapImage tag:0];
    mapTabBarItem.selectedImage = mapImageSelected;
    
    mapControllerWithNavigation.tabBarItem = mapTabBarItem;
    mapControllerWithNavigation.navigationBar.barTintColor = [Colors get].black;
    mapControllerWithNavigation.navigationBar.titleTextAttributes =
    getTextAttributes([Colors get].black, 18.0, UIFontWeightSemibold);
    
#pragma mark - BookmarksViewController
    
    BookmarksViewController *bookmarksController = [[BookmarksViewController alloc] init];
    bookmarksController.title = @"";
    UINavigationController *bookmarksControllerWithNavigation = [[UINavigationController alloc ] initWithRootViewController:bookmarksController];
    UIImage *bookmarksImage;
    UIImage *bookmarksImageSelected;
    if (@available(iOS 13.0, *)) {
        mapImage = [UIImage systemImageNamed:@"star"];
        mapImageSelected = [UIImage systemImageNamed:@"star.fill"];
    } else {
        mapImage = [UIImage imageNamed:@"noun_Star_1730824"];
        mapImageSelected = [UIImage imageNamed:@"noun_Star_1730824"];
    }
    UITabBarItem *bookmarksTabBarItem = [[UITabBarItem alloc] initWithTitle:@"" image:bookmarksImage tag:0];
    mapTabBarItem.selectedImage = bookmarksImageSelected;
    
    mapControllerWithNavigation.tabBarItem = bookmarksTabBarItem;
    mapControllerWithNavigation.navigationBar.barTintColor = [Colors get].black;
    mapControllerWithNavigation.navigationBar.titleTextAttributes =
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
