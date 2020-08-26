//
//  Category.h
//  GreenTravel
//
//  Created by Alex K on 8/26/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class ParticularPlaceItem;

@interface Category : NSObject

@property (strong, nonatomic) NSString *uuid;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) Category *categories;
@property (strong, nonatomic) ParticularPlaceItem *items;
@property (strong, nonatomic) NSString *cover;


@end

NS_ASSUME_NONNULL_END
