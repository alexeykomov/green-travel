//
//  WeRecommendCell.m
//  GreenTravel
//
//  Created by Alex K on 8/22/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import "WeRecommendCell.h"
#import "Colors.h"
#import "TextUtils.h"

@implementation WeRecommendCell

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
    UILabel *header = [[UILabel alloc] init];
    [self addSubview:header];
    
    header.translatesAutoresizingMaskIntoConstraints = NO;
    
    [NSLayoutConstraint activateConstraints:@[
        [header.topAnchor constraintEqualToAnchor:self.topAnchor],
        [header.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:16.0],
        [header.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
    ]];
    
    [header setFont:[UIFont fontWithName:@"Montserrat-Bold" size:16.0]];
    header.attributedText = getAttributedString(@"История поиска", [Colors get].black, 16.0, UIFontWeightBold);
}

@end
