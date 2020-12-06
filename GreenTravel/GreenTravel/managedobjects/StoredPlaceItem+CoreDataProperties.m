//
//  StoredPlaceItem+CoreDataProperties.m
//  
//
//  Created by Alex K on 12/6/20.
//
//

#import "StoredPlaceItem+CoreDataProperties.h"

@implementation StoredPlaceItem (CoreDataProperties)

+ (NSFetchRequest<StoredPlaceItem *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"StoredPlaceItem"];
}

@dynamic address;
@dynamic bookmarked;
@dynamic categoryUUID;
@dynamic coords;
@dynamic coverURL;
@dynamic imageURLs;
@dynamic sections;
@dynamic title;
@dynamic uuid;
@dynamic parent;
@dynamic details;

@end
