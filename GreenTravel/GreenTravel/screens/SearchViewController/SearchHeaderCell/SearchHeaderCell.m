//
//  SearchHeaderCell.m
//  GreenTravel
//
//  Created by Alex K on 8/22/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import "SearchHeaderCell.h"
#import "Colors.h"
#import "TextUtils.h"

@implementation SearchHeaderCell

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
    UIImageView *placeImage = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"mappin.circle"]];
    [self addSubview:placeImage];
    placeImage.tintColor = [Colors get].heavyMetal;
    
    placeImage.translatesAutoresizingMaskIntoConstraints = NO;
    
    [NSLayoutConstraint activateConstraints:@[
        [placeImage.topAnchor constraintEqualToAnchor:self.topAnchor constant:37.0],
        [placeImage.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:16.0],
        [placeImage.widthAnchor constraintEqualToConstant:32.0],
        [placeImage.heightAnchor constraintEqualToConstant:32.0],
    ]];
    
    UILabel *header = [[UILabel alloc] init];
    [self addSubview:header];
    
    header.translatesAutoresizingMaskIntoConstraints = NO;
    
    [NSLayoutConstraint activateConstraints:@[
        [header.centerYAnchor constraintEqualToAnchor:placeImage.centerYAnchor],
        [header.leadingAnchor constraintEqualToAnchor:placeImage.trailingAnchor constant:12.0],
        [header.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
    ]];
    
    [header setFont:[UIFont fontWithName:@"Montserrat-Regular" size:16.0]];
    header.attributedText = getAttributedString(@"Места рядом с вами", [Colors get].heavyMetal, 16.0, UIFontWeightRegular);
}

@end
