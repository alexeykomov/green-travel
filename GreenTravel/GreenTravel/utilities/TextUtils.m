//
//  TextUtils.m
//  TEDPlayer
//
//  Created by Alex K on 7/18/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import "TextUtils.h"
#import <UIKit/UIKit.h>

NSDictionary<NSAttributedStringKey, id>* getTextAttributes(UIColor* color, CGFloat size, UIFontWeight weight) {
    return @{
        NSForegroundColorAttributeName:color,
        NSFontAttributeName:[UIFont systemFontOfSize:size weight:weight]
    };
};

NSAttributedString* getAttributedString(NSString *text, UIColor* color, CGFloat size, UIFontWeight weight) {
    return [[NSAttributedString alloc] initWithString:text attributes:getTextAttributes(color, size, weight)];
}

NSString* getUsefulTimeComponents(NSString *duration) {
    NSArray<NSString*> *components = [duration componentsSeparatedByString:@":"];
    NSMutableArray<NSString*> *usefulComponents = [[NSMutableArray alloc] init];
    unsigned long allowedSkips = [components count] - 2;
    int skips = 0;
    for (NSString *component in components) {
        if ([component isEqualToString:@"00"] && skips < allowedSkips) {
            skips++;
            continue;
        }
        [usefulComponents addObject:component];
    }
    return [usefulComponents componentsJoinedByString:@":"];
}
