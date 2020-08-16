//
//  IndexViewController.m
//  GreenTravel
//
//  Created by Alex K on 8/15/20

#import "Colors.h"
#import "TextUtils.h"
#import "IndexViewController.h"
#import "PlacesTableViewCell.h"

@interface IndexViewController ()

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIView *contentView;

@end

static NSString * const kCollectionCellId = @"collectionCellId";
static CGFloat kTableRowHeight = 100.0;

@implementation IndexViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [Colors get].white;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(onSearchPress:)];
    self.navigationItem.rightBarButtonItem.tintColor = [Colors get].white;
    
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    CAGradientLayer *gradient = [[CAGradientLayer alloc] init];
    navigationBar.titleTextAttributes = getTextAttributes([Colors get].white, 16.0, UIFontWeightSemibold);
    navigationBar.barStyle = UIBarStyleBlack;
    CGRect navBarBounds = navigationBar.bounds;
    
    navBarBounds.size.height += UIApplication.sharedApplication.statusBarFrame.size.height;
    
    gradient.frame = navBarBounds;
    gradient.colors = @[(id)[Colors get].green.CGColor, (id)[Colors get].shamrock.CGColor];
    gradient.startPoint = CGPointMake(0, 0);
    gradient.endPoint = CGPointMake(1, 0);
    
    [navigationBar setBackgroundImage:getImageFromGradientLayer(gradient) forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    
#pragma mark - Table view
    [self.tableView registerClass:PlacesTableViewCell.class forCellReuseIdentifier:kCollectionCellId];
}

UIImage* getImageFromGradientLayer(CAGradientLayer* gradient) {
    UIImage* gradientImage;
    UIGraphicsBeginImageContext(gradient.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [gradient renderInContext:context];
    gradientImage = [UIGraphicsGetImageFromCurrentImageContext() resizableImageWithCapInsets:UIEdgeInsetsZero resizingMode:UIImageResizingModeStretch];
    UIGraphicsEndImageContext();
    return gradientImage;
}

- (void) onSearchPress:(id)sender {
    
}

#pragma mark - Table data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PlacesTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kCollectionCellId forIndexPath:indexPath];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kTableRowHeight;
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
