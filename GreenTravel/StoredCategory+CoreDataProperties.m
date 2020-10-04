//
//  StoredCategory+CoreDataProperties.m
//  
//
//  Created by Alex K on 10/4/20.
//
//

#import "StoredCategory+CoreDataProperties.h"

@implementation StoredCategory (CoreDataProperties)

+ (NSFetchRequest<StoredCategory *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"StoredCategory"];
}

@dynamic coverURL;
@dynamic title;
@dynamic uuid;
@dynamic categories;
@dynamic items;
@dynamic parent;

@end
