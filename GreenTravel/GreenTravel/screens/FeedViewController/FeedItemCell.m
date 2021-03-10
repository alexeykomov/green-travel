//
//  FeedItemTableViewCell.m
//  GreenTravel
//
//  Created by Alex K on 3/7/21.
//  Copyright © 2021 Alex K. All rights reserved.
//

#import "FeedItemCell.h"
#import "DetailsView.h"
#import "Category.h"
#import "FeedItem.h"

@interface FeedItemCell()

@property (strong, nonatomic) DetailsView *detailsView;

@end

@implementation FeedItemCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setUp];
    }
    return self;
}

- (void)setUp {
    
}
 
- (void)update:(PlaceItem *)item
onBookmarkButtonPress:(void(^)(void))onBookmarkButtonPress
onLocationButtonPress:(void(^)(void))onLocationButtonPress
onMapButtonPress:(void(^)(void))onMapButtonPress
onCategoriesLinkPress:(void(^)(NSOrderedSet<NSString *> *, Category *))onCategoriesLinkPress {
    if (self.detailsView != nil) {
        return;
    }
    self.detailsView = [[DetailsView alloc] initWithItem:item onBookmarkButtonPress:onBookmarkButtonPress onLocationButtonPress:onLocationButtonPress onMapButtonPress:onMapButtonPress onCategoriesLinkPress:onCategoriesLinkPress];
    [self.contentView addSubview:self.detailsView];
    self.detailsView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.detailsView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor],
        [self.detailsView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor],
        [self.detailsView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor],
        [self.detailsView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor],
    ]];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse {
    [self.detailsView removeFromSuperview];
    self.detailsView = nil;
}

@end
