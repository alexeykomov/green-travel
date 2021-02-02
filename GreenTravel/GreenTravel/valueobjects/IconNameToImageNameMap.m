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
        self.map = [[NSDictionary alloc] init];
        [self.map setValue:@"hiking" forKey:@"walking-routes"];
        [self.map setValue:@"historical-place" forKey:@"walking-routes"];
        [self.map setValue:@"bicycle-route" forKey:@"walking-routes"];
        [self.map setValue:@"exсursion" forKey:@"excursion-pin"];
    }
    return self;
}

- (UIImage *)iconForName:(NSString *)name {
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
