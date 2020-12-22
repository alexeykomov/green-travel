//
//  DotsIndexes.m
//  GreenTravel
//
//  Created by Alex K on 12/22/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import "DotsIndexes.h"

@implementation DotsIndexes

- (instancetype)init
{
    self = [super init];
    if (self) {
        _smallestDotIndexesInitial = [[NSMutableIndexSet alloc] init];
        _smallDotIndexesInitial = [[NSMutableIndexSet alloc] init];
        _mediumDotIndexesInitial = [[NSMutableIndexSet alloc] init];
        _smallestDotIndexesFinal = [[NSMutableIndexSet alloc] init];
        _smallDotIndexesFinal = [[NSMutableIndexSet alloc] init];
        _mediumDotIndexesFinal = [[NSMutableIndexSet alloc] init];
    }
    return self;
}

@end
