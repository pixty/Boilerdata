//
//  BLArrayData.m
//  Boilerdata
//
//  Created by Nick Tymchenko on 17/02/16.
//  Copyright © 2016 Pixty. All rights reserved.
//

#import "BLArrayData.h"
#import "BLDataItem.h"
#import "BLDataUtils.h"
#import "NSIndexPath+BLUtils.h"

@implementation BLArrayData

#pragma mark - Init

- (instancetype)init {
    return [self initWithItems:nil];
}

- (instancetype)initWithItems:(NSArray<id<BLDataItem>> *)items {
    self = [super init];
    if (!self) return nil;
    
    _items = [items copy] ?: @[];
    
    return self;
}

#pragma mark - BLData

- (NSInteger)numberOfSections {
    return self.items.count > 0 ? 1 : 0;
}

- (NSInteger)numberOfItemsInSection:(NSInteger)section {
    return self.items.count;
}

- (id<BLDataItem>)itemAtIndexPath:(NSIndexPath *)indexPath {
    NSParameterAssert(indexPath.bl_row < self.items.count);    
    return indexPath.bl_row < self.items.count ? self.items[indexPath.bl_row] : nil;
}

- (NSIndexPath *)indexPathForItemWithId:(id<BLDataItemId>)itemId {
    // TODO: improve this
    
    __block NSIndexPath *result = nil;
    
    [self.items enumerateObjectsUsingBlock:^(id<BLDataItem> item, NSUInteger idx, BOOL *stop) {
        if ([item.itemId isEqual:itemId]) {
            result = [NSIndexPath bl_indexPathForRow:idx inSection:0];
            *stop = YES;
        }
    }];
    
    return result;
}

#pragma mark - NSObject

- (NSString *)description {
    return [BLDataUtils(self) description];
}

@end
