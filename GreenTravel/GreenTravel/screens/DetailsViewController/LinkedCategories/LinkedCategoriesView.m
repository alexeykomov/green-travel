//
//  LinkedCategoriesView.m
//  GreenTravel
//
//  Created by Alex K on 11/6/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import "LinkedCategoriesView.h"
#import "IndexModel.h"
#import "CategoryUtils.h"
#import "PlaceItem.h"
#import "Category.h"

@interface LinkedCategoriesView()

@property (strong, nonatomic) NSArray<NSArray *> *linkIds;
@property (strong, nonatomic) IndexModel *indexModel;

@end

@implementation LinkedCategoriesView

- (instancetype)initWithLinkIds:(NSOrderedSet<NSOrderedSet<NSString *>*>*)itemIds
                     indexModel:(IndexModel *)indexModel
{
    self = [super init];
    if (self) {
        NSMutableArray<PlaceItem *> *dataSource = [[NSMutableArray alloc] init];
        traverseCategories(indexModel.categories, ^(Category *category, PlaceItem *item) {
            if ([itemIds containsObject:item.uuid]) {
                [dataSource addObject:item];
            }
        });
        self.dataSource = ;
    }
    return self;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    <#code#>
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    <#code#>
}

@end
