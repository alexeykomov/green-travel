//
//  StoredSearchItem+CoreDataProperties.m
//  GreenTravel
//
//  Created by Alex K on 10/18/20.
//  Copyright © 2020 Alex K. All rights reserved.
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
