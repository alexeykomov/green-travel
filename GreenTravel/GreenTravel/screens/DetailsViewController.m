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
#import "ApiService.h"
#import "DetailsModel.h"

@interface DetailsViewController ()

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *locationLabel;
@property (strong, nonatomic) UIImageView *previewImageView;
@property (strong, nonatomic) UIButton *mapButton;
@property (strong, nonatomic) UITextView *descriptionTextView;
@property (strong, nonatomic) ApiService *apiService;
@property (strong, nonatomic) DetailsModel *detailsModel;
@property (strong, nonatomic) PlaceDetails *details;

@end

@implementation DetailsViewController

- (instancetype)initWithApiService:(ApiService *)apiService
                      detailsModel:(DetailsModel *)detailsModel
{
    self = [super init];
    if (self) {
        _apiService = apiService;
        _detailsModel = detailsModel;
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
    
    [NSLayoutConstraint activateConstraints:@[
        [self.previewImageView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:0.0],
        [self.previewImageView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:0.0],
        [self.previewImageView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:0.0],
        [self.previewImageView.widthAnchor constraintEqualToConstant:50.0],
        [self.previewImageView.heightAnchor constraintEqualToAnchor:self.view.widthAnchor]
    ]];
        
    #pragma mark - Title label
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.numberOfLines = 4;
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;

    [self.contentView addSubview:self.titleLabel];

    [NSLayoutConstraint activateConstraints:@[
        [self.titleLabel.topAnchor constraintEqualToAnchor:self.previewImageView.bottomAnchor constant:10.0],
        [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:10.0],
        [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-10.0],

    ]];
    
    [self.apiService loadDetailsByUUID:self.item.uuid];
    [self.detailsModel addObserver:self];
} 

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)onDetailsUpdate:(NSMutableDictionary<NSString *,PlaceDetails *> *)itemUUIDToDetails items:(NSMutableDictionary<NSString *,PlaceItem *> *)itemUUIDToItem {
    if (!self.details && [itemUUIDToDetails valueForKey:self.item.uuid]) {
        
    }
}

@end
