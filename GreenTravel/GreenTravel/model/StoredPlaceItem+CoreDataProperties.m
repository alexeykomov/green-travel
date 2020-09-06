//
//  StoredPlaceItem+CoreDataProperties.m
//  
//
//  Created by Alex K on 9/6/20.
//
//

#import "StoredPlaceItem+CoreDataProperties.h"

@implementation StoredPlaceItem (CoreDataProperties)

+ (NSFetchRequest<StoredPlaceItem *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"StoredPlaceItem"];
}

@dynamic uuid;
@dynamic title;
@dynamic coverURL;
@dynamic coords;
@dynamic bookmarked;
@dynamic imageURLs;
@dynamic address;
@dynamic sections;
@dynamic categoryUUID;

@end
