//
//  PlaceDetails.h
//  GreenTravel
//
//  Created by Alex K on 8/27/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PlaceDetails : NSObject

@property (strong, nonatomic) NSArray<NSString *> *images;
@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) NSArray<NSString *> *sections;

@end 

NS_ASSUME_NONNULL_END
