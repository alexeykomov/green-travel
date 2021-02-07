//
//  StoredSearchItem+CoreDataProperties.m
//  
//
//  Created by Alex K on 2/6/21.
//
//

#import "StoredSearchItem+CoreDataProperties.h"

@implementation StoredSearchItem (CoreDataProperties)

+ (NSFetchRequest<StoredSearchItem *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"StoredSearchItem"];
}

@dynamic order;
@dynamic uuid;
@dynamic correspondingPlaceItem;

@end
