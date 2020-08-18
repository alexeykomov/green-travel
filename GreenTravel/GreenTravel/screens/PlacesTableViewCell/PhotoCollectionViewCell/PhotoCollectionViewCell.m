//
//  PhotoCollectionViewCell.m
//  GreenTravel
//
//  Created by Alex K on 8/16/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import "PhotoCollectionViewCell.h"
#import "Colors.h"

@implementation PhotoCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;
}

- (void)setUp {
    UIView *placeholder = [[UIView alloc] init];
    [self addSubview:placeholder];
    
    placeholder.translatesAutoresizingMaskIntoConstraints = NO;
    placeholder.backgroundColor = [Colors get].blue;
    
    [NSLayoutConstraint activateConstraints:@[
        [placeholder.topAnchor constraintEqualToAnchor:self.topAnchor],
        [placeholder.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [placeholder.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [placeholder.bottomAnchor constraintEqualToAnchor:self.bottomAnchor]
    ]];
}

@end
