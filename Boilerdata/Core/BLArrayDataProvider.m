//
//  BLArrayDataProvider.m
//  Boilerdata
//
//  Created by Nick Tymchenko on 06/01/16.
//  Copyright © 2016 Pixty. All rights reserved.
//

#import "BLArrayDataProvider.h"
#import "BLBasicDataProvider+Subclassing.h"
#import "BLArrayData.h"

@implementation BLArrayDataProvider

- (void)updateWithItems:(nullable NSArray<id<BLDataItem>> *)items {
    [self updateWithItems:items updatedItemIds:nil context:nil];
}

- (void)updateWithItems:(nullable NSArray<id<BLDataItem>> *)items updatedItemIds:(nullable NSSet<id<BLDataItemId>> *)updatedItemIds {
    [self updateWithItems:items updatedItemIds:updatedItemIds context:nil];
}

- (void)updateWithItems:(nullable NSArray<id<BLDataItem>> *)items
         updatedItemIds:(nullable NSSet<id<BLDataItemId>> *)precalculatedUpdatedItemIds
                context:(nullable NSDictionary *)context {
    BLArrayData *newData = [[BLArrayData alloc] initWithItems:items];
    [self updateWithData:newData updatedItemIds:precalculatedUpdatedItemIds context:context];
}

@end
