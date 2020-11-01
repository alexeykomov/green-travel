//
//  StoredPlaceDetails+CoreDataProperties.h
//  
//
//  Created by Alex K on 11/1/20.
//
//

#import "StoredPlaceDetails+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface StoredPlaceDetails (CoreDataProperties)

+ (NSFetchRequest<StoredPlaceDetails *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *imageURLs;
@property (nullable, nonatomic, retain) NSData *descriptionText;
@property (nullable, nonatomic, copy) NSString *address;
@property (nullable, nonatomic, copy) NSString *uuid;

@end

NS_ASSUME_NONNULL_END
