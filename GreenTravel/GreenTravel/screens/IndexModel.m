//
//  IndexModel.m
//  GreenTravel
//
//  Created by Alex K on 8/27/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import "IndexModel.h"

@implementation IndexModel

static IndexModel *instance;

+ (instancetype)get {
    if (instance) {
        return instance;
    }
    instance = [[IndexModel alloc] init];
    return instance;
}

@end
