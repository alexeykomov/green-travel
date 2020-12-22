//
//  DotsIndexes.h
//  GreenTravel
//
//  Created by Alex K on 12/22/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DotsIndexes : NSObject

@property(strong, nonatomic) NSMutableIndexSet *smallestDotIndexesInitial;
@property(strong, nonatomic) NSMutableIndexSet *smallDotIndexesInitial;
@property(strong, nonatomic) NSMutableIndexSet *mediumDotIndexesInitial;
@property(strong, nonatomic) NSMutableIndexSet *smallestDotIndexesFinal;
@property(strong, nonatomic) NSMutableIndexSet *smallDotIndexesFinal;
@property(strong, nonatomic) NSMutableIndexSet *mediumDotIndexesFinal;

@end

NS_ASSUME_NONNULL_END
