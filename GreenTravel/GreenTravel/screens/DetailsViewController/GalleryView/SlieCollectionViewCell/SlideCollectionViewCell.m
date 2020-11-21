//
//  SlideCollectionViewCell.m
//  GreenTravel
//
//  Created by Alex K on 11/21/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import "SlideCollectionViewCell.h"
#import "ImageUtils.h"

@interface SlideCollectionViewCell ()

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) SDWebImageCombinedOperation *loadImageOperation;

@end

@implementation SlideCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc] init];
        [self addSubview:self.imageView];
        self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        [NSLayoutConstraint activateConstraints:@[
            [self.imageView.topAnchor constraintEqualToAnchor:self.topAnchor],
            [self.imageView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
            [self.imageView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
            [self.imageView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
        ]];
    }
    return self;
}

- (void)setUpWithImageURL:(NSString *)imageURL {
    __weak typeof(self) weakSelf = self;
    loadImage(imageURL, ^(UIImage *image) {
        [weakSelf.imageView setImage:image];
    });
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.loadImageOperation cancel];
}

@end
