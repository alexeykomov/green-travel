//
//  DetailsModel.h
//  GreenTravel
//
//  Created by Alex K on 9/5/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DetailsObservable.h"
#import "CategoriesObserver.h"

NS_ASSUME_NONNULL_BEGIN

@class PlaceDetails;
@class PlaceItem;
@class IndexModel;
@protocol DetailsObserver;

@interface DetailsModel : NSObject<CategoriesObserver, DetailsObservable> 

- (instancetype)initWithIndexModel:(IndexModel *)model;
@property (strong, nonatomic) NSMutableDictionary<NSString*, PlaceDetails*> *itemUUIDToDetails;
@property (strong, nonatomic) NSMutableDictionary<NSString*, PlaceItem*> *itemUUIDToItem;
@property (strong, nonatomic) NSMutableArray<id<DetailsObserver>> *detailsObservers;

- (void)updateDetails:(PlaceDetails *)details forUUID:(NSString *)uuid;

@end

NS_ASSUME_NONNULL_END
