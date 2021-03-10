//
//  DiscoveryModel.h
//  GreenTravel
//
//  Created by Alex K on 3/7/21.
//  Copyright © 2021 Alex K. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FeedObservable.h"

@class FeedItem;

NS_ASSUME_NONNULL_BEGIN

@interface FeedModel : NSObject<FeedObservable>

@property (strong, nonatomic) NSArray<FeedItem *> *feedItems;

@end

NS_ASSUME_NONNULL_END
