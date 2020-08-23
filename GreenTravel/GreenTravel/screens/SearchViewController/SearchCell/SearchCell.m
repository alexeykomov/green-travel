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

@interface SearchCell ()

@property (strong, nonatomic) UILabel *header;

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
    self.header = [[UILabel alloc] init];
    [self addSubview:self.header];
    
    self.header.translatesAutoresizingMaskIntoConstraints = NO;
    
    [NSLayoutConstraint activateConstraints:@[
        [self.header.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
        [self.header.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:16.0],
        [self.header.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
    ]];
    
    [self.header setFont:[UIFont fontWithName:@"OpenSans-Regular" size:16.0]];
}

- (void)update:(SearchItem *)item {
    self.header.attributedText = getAttributedString([item searchableText], [Colors get].black, 16.0, UIFontWeightRegular);
}

@end
