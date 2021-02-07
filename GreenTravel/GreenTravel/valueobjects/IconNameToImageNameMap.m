//
//  IconNameToImageNameMap.m
//  GreenTravel
//
//  Created by Alex K on 2/2/21.
//  Copyright © 2021 Alex K. All rights reserved.
//

#import "IconNameToImageNameMap.h"
#import <UIKit/UIKit.h>

@interface IconNameToImageNameMap()

@property (strong, nonatomic) NSDictionary<NSString *, NSString *> *map;

@end

@implementation IconNameToImageNameMap

static IconNameToImageNameMap *instance;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _map = @{
            @"object": @"conserv.area",
            @"hiking": @"walking-routes",
            @"historical-place": @"historical-place",
            @"bicycle-route": @"bicycle-route",
            @"excursion-pin": @"excursion",
        };
    }
    return self;
}

- (UIImage *)iconForName:(NSString *)name {
    if (!self.map[name]) {
        return nil;
    }
    NSString *fileName = self.map[name];
    return [UIImage imageNamed:fileName];
}

+ (instancetype)get {
    if (instance) {
        return instance;
    }
    instance = [[IconNameToImageNameMap alloc] init];
    return instance;
}

@end
