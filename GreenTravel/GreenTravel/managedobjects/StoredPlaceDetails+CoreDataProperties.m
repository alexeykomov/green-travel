//
//  StoredPlaceDetails+CoreDataProperties.m
//  
//
//  Created by Alex K on 11/1/20.
//
//

#import "StoredPlaceDetails+CoreDataProperties.h"

@implementation StoredPlaceDetails (CoreDataProperties)

+ (NSFetchRequest<StoredPlaceDetails *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"StoredPlaceDetails"];
}

@dynamic imageURLs;
@dynamic descriptionText;
@dynamic address;
@dynamic uuid;

@end
