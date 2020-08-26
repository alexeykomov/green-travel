//
//  SearchItem.h
//  GreenTravel
//
//  Created by Alex K on 8/22/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SearchItem : NSObject

@property (strong, nonatomic) NSString *correspondingUUID;
@property (strong, nonatomic) NSString *title;
@property (assign, nonatomic) CGFloat distance;
- (NSString *)searchableText;

@end

NS_ASSUME_NONNULL_END
