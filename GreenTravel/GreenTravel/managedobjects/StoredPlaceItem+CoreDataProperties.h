//
//  StoredPlaceItem+CoreDataProperties.h
//  
//
//  Created by Alex K on 9/6/20.
//
//

#import "StoredPlaceItem+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface StoredPlaceItem (CoreDataProperties)

+ (NSFetchRequest<StoredPlaceItem *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *uuid;
@property (nullable, nonatomic, copy) NSString *title;
@property (nullable, nonatomic, copy) NSString *coverURL;
@property (nullable, nonatomic, retain) NSData *coords;
@property (nonatomic) BOOL bookmarked;
@property (nullable, nonatomic, copy) NSString *imageURLs;
@property (nullable, nonatomic, copy) NSString *address;
@property (nullable, nonatomic, copy) NSString *sections;
@property (nullable, nonatomic, copy) NSString *categoryUUID;

@end

NS_ASSUME_NONNULL_END
