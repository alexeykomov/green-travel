//
//  ParticularPlaceItem.h
//  GreenTravel
//
//  Created by Alex K on 8/17/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ParticularPlaceItem : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *imageURL;
@property (strong, nonatomic) void (^onPlaceCellPress)(ParticularPlaceItem *);

@end 

NS_ASSUME_NONNULL_END
