//
//  BookmarkCell.m
//  GreenTravel
//
//  Created by Alex K on 8/20/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import "BookmarkCell.h"
#import "Colors.h"
#import "TextUtils.h"
#import "Category.h"
#import "StyleUtils.h"

@interface BookmarkCell ()

@property (strong, nonatomic) UILabel *headerLabel;
@property (strong, nonatomic) UILabel *countLabel;

@end

@implementation BookmarkCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;
}

- (void)setUp {
    self.backgroundColor = [Colors get].white;
    
    self.layer.cornerRadius = 15.0;
    
    drawShadow(self);
    
#pragma mark - Header label
    self.headerLabel = [[UILabel alloc] init];
    [self addSubview:self.headerLabel];
    
    self.headerLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.headerLabel setFont:[UIFont fontWithName:@"Montserratt-Regular" size:10.0]];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.headerLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
        [self.headerLabel.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
        [self.headerLabel.widthAnchor constraintLessThanOrEqualToAnchor:self.widthAnchor constant:-20.0],
    ]];
    
    self.countLabel = [[UILabel alloc] init];
    [self addSubview:self.countLabel];
    
    self.countLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.countLabel setFont:[UIFont fontWithName:@"Montserratt-Regular" size:10.0]];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.countLabel.topAnchor constraintEqualToAnchor:self.topAnchor constant:10.0],
        [self.countLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-10.0],
    ]];
#pragma mark - Subscribe to orientation change
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDeviceOrientationChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)update:(Category *)item {
    self.headerLabel.attributedText = getAttributedString([item.title uppercaseString], [Colors get].black, 10.0, UIFontWeightRegular);
    self.countLabel.attributedText = getAttributedString([@([item.items count]) stringValue], [Colors get].black, 10.0, UIFontWeightRegular);
    self.item = item;
}

- (void)onDeviceOrientationChange:(id)sender {
    drawShadow(self);
}


@end
