//
//  StoredPlaceDetails+CoreDataProperties.m
//  
//
//  Created by Alex K on 11/5/20.
//
//

#import "StoredPlaceDetails+CoreDataProperties.h"

@implementation StoredPlaceDetails (CoreDataProperties)

+ (NSFetchRequest<StoredPlaceDetails *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"StoredPlaceDetails"];
}

@dynamic imageURLs;
@dynamic descriptionHTML;
@dynamic address;
@dynamic uuid;

@end
