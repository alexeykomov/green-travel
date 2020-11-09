//
//  StoredPlaceDetails+CoreDataProperties.m
//  
//
//  Created by Alex K on 11/9/20.
//
//

#import "StoredPlaceDetails+CoreDataProperties.h"

@implementation StoredPlaceDetails (CoreDataProperties)

+ (NSFetchRequest<StoredPlaceDetails *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"StoredPlaceDetails"];
}

@dynamic address;
@dynamic descriptionHTML;
@dynamic imageURLs;
@dynamic uuid;
@dynamic linkedCategories;

@end
