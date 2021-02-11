//
//  SearchCell.m
//  GreenTravel
//
//  Created by Alex K on 8/22/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import "SearchCell.h"
#import "Colors.h"
#import "TextUtils.h"
#import "SearchItem.h"
#import "Typography.h"

@interface SearchCell ()

@property (strong, nonatomic) UIStackView *titleStack;
@property (strong, nonatomic) UILabel *title;
@property (strong, nonatomic) UILabel *titleCategory;
@property (strong, nonatomic) UIImageView *iconView;

@end

@implementation SearchCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setUp];
    }
    return self;
}

- (void)setUp {
    self.titleStack = [[UIStackView alloc] init];
    [self addSubview:self.titleStack];
    self.title.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.title.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
        [self.title.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:16.0],
        [self.title.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
    ]];
    [self.title setFont:[UIFont fontWithName:@"Montserrat-Bold" size:15.0]];
#pragma mark - Title
    self.title = [[UILabel alloc] init];
    [self addSubview:self.title];
    self.title.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.title.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
        [self.title.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:16.0],
        [self.title.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
    ]];
    [self.title setFont:[UIFont fontWithName:@"Montserrat-Bold" size:15.0]];
    
    self.titleCategory = [[UILabel alloc] init];
    [self addSubview:self.titleCategory];
    self.titleCategory.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.titleCategory.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
        [self.titleCategory.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:16.0],
        [self.titleCategory.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
    ]];
    [self.titleCategory setFont:[UIFont fontWithName:@"Montserrat-Bold" size:15.0]];
}

- (void)update:(SearchItem *)item {
    self.title.attributedText =
    [[Typography get] makeTitle2:[item searchableText] color:[Colors get].black];
}

@end
