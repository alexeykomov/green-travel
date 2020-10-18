//
//  StoredSearchItem+CoreDataProperties.h
//  GreenTravel
//
//  Created by Alex K on 10/18/20.
//  Copyright © 2020 Alex K. All rights reserved.
//
//

#import "StoredSearchItem+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface StoredSearchItem (CoreDataProperties)

+ (NSFetchRequest<StoredSearchItem *> *)fetchRequest;

@property (nonatomic) int16_t order;
@property (nullable, nonatomic, copy) NSString *uuid;
@property (nullable, nonatomic, retain) StoredPlaceItem *correspondingPlaceItem;

@end

NS_ASSUME_NONNULL_END
