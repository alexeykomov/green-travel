//
//  StoredSearchItem+CoreDataProperties.h
//  
//
//  Created by Alex K on 2/6/21.
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
