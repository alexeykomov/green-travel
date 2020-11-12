//
//  NSAttributedString+ChageableFont.m
//  GreenTravel
//
//  Created by Alex K on 11/11/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import "NSMutableAttributedString+ChangeableFont.h"

@implementation NSMutableAttributedString (ChangeableFont)

- (void)setFont:(UIFont *)aFont {
    [self beginEditing];
    [self enumerateAttribute:NSFontAttributeName inRange:NSMakeRange(0, [self length]) options:nil
    usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
        if ([value isKindOfClass:UIFont.class]) {
            UIFont *font = (UIFont *)value;
            UIFontDescriptor *newFontDescriptor = [[[font fontDescriptor] fontDescriptorWithFamily:aFont.familyName] fontDescriptorWithSymbolicTraits:font.fontDescriptor.symbolicTraits];
            
            UIFont *newFont = [UIFont fontWithDescriptor:newFontDescriptor size:font.pointSize];
            [self removeAttribute:NSFontAttributeName range:range];
            [self addAttribute:NSFontAttributeName value:newFont range:range];
        }
    }];
    [self endEditing];
}

@end
