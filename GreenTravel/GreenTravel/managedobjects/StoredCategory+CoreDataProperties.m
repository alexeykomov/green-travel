//
//  StoredCategory+CoreDataProperties.m
//  
//
//  Created by Alex K on 9/20/20.
//
//

#import "StoredCategory+CoreDataProperties.h"

@implementation StoredCategory (CoreDataProperties)

+ (NSFetchRequest<StoredCategory *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"StoredCategory"];
}

@dynamic uuid;
@dynamic title;
@dynamic coverURL;
@dynamic items;
@dynamic categories;
@dynamic parent;

@end
