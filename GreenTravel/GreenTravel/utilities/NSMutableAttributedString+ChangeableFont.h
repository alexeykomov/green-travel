//
//  NSAttributedString+ChageableFont.h
//  GreenTravel
//
//  Created by Alex K on 11/11/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableAttributedString (ChangeableFont)

- (void)setFont:(UIFont *)font;

@end

NS_ASSUME_NONNULL_END
