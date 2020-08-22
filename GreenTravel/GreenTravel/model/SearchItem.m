//
//  SearchItem.m
//  GreenTravel
//
//  Created by Alex K on 8/22/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import "SearchItem.h"

@implementation SearchItem

- (NSString *)searchableText {
    NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
    fmt.numberStyle = NSNumberFormatterDecimalStyle;
    fmt.maximumFractionDigits = 1;
    
    NSString *kilometers = [fmt stringFromNumber:@(self.distance)];
    return [NSString stringWithFormat:@"%@, %@ км", self.header, kilometers];
}

@end
