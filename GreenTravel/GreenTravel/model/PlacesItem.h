//
//  PlacesItem.h
//  GreenTravel
//
//  Created by Alex K on 8/16/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class ParticularPlaceItem;

@interface PlacesItem : NSObject

@property (strong, nonatomic) NSString *header;
@property (strong, nonatomic) NSArray<ParticularPlaceItem *> *items;
@property (strong, nonatomic) void (^onAllButtonPress)(PlacesItem *);

@end

NS_ASSUME_NONNULL_END
