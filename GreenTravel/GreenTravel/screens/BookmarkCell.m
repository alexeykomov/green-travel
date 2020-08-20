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
#import "PlacesItem.h"

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
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.bounds];
    self.layer.masksToBounds = NO;
    self.layer.shadowColor = [[Colors get].pineTree CGColor];
    self.layer.shadowOpacity = 0.2;
    self.layer.shadowOffset = CGSizeMake(0.0, 5.0);
    self.layer.shadowPath = [shadowPath CGPath];
    
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
}

- (void)update:(PlacesItem *)item {
    self.headerLabel.attributedText = getAttributedString([item.header uppercaseString], [Colors get].black, 10.0, UIFontWeightRegular);
    self.countLabel.attributedText = getAttributedString([@([item.items count]) stringValue], [Colors get].black, 10.0, UIFontWeightRegular);
    self.item = item;
}


@end
