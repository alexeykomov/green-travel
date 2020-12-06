//
//  StoredPlaceItem+CoreDataProperties.h
//  
//
//  Created by Alex K on 12/6/20.
//
//

#import "StoredPlaceItem+CoreDataClass.h"

@class StoredPlaceDetails;

NS_ASSUME_NONNULL_BEGIN

@interface StoredPlaceItem (CoreDataProperties)

+ (NSFetchRequest<StoredPlaceItem *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *address;
@property (nonatomic) BOOL bookmarked;
@property (nullable, nonatomic, copy) NSString *categoryUUID;
@property (nullable, nonatomic, retain) NSData *coords;
@property (nullable, nonatomic, copy) NSString *coverURL;
@property (nullable, nonatomic, copy) NSString *imageURLs;
@property (nullable, nonatomic, copy) NSString *sections;
@property (nullable, nonatomic, copy) NSString *title;
@property (nullable, nonatomic, copy) NSString *uuid;
@property (nullable, nonatomic, retain) StoredCategory *parent;
@property (nullable, nonatomic, retain) StoredPlaceDetails *details;

@end

NS_ASSUME_NONNULL_END
