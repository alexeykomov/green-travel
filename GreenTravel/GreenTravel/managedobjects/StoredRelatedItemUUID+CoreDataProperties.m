//
//  StoredRelatedItemUUID+CoreDataProperties.m
//  
//
//  Created by Alex K on 11/9/20.
//
//

#import "StoredRelatedItemUUID+CoreDataProperties.h"

@implementation StoredRelatedItemUUID (CoreDataProperties)

+ (NSFetchRequest<StoredRelatedItemUUID *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"StoredRelatedItemUUID"];
}

@dynamic uuid;

@end
