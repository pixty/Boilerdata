//
//  BLUtils.m
//  Boilerdata
//
//  Created by Nick Tymchenko on 07/01/16.
//  Copyright © 2016 Pixty. All rights reserved.
//

#import "BLUtils.h"
#import "BLData.h"
#import "NSIndexPath+BLUtils.h"
#import "BLDataDiff.h"

@implementation BLUtils

#pragma mark - BLData stuff

+ (BOOL)dataIsEmpty:(id<BLData>)data {
    for (NSInteger section = 0; section < [data numberOfSections]; ++section) {
        if ([data numberOfItemsInSection:section] > 0) {
            return NO;
        }
    }
    
    return YES;
}

+ (NSInteger)dataNumberOfItems:(id<BLData>)data {
    NSInteger count = 0;
    
    for (NSInteger section = 0; section < [data numberOfSections]; ++section) {
        count += [data numberOfItemsInSection:section];
    }
    
    return count;
}

+ (NSArray<id<BLDataItem>> *)data:(id<BLData>)data itemsInSection:(NSInteger)section {
    NSInteger numberOfItems = [data numberOfItemsInSection:section];
    NSMutableArray<id<BLDataItem>> *items = [NSMutableArray arrayWithCapacity:numberOfItems];
    
    for (NSInteger row = 0; row < numberOfItems; ++row) {
        [items addObject:[data itemAtIndexPath:[NSIndexPath bl_indexPathForRow:row inSection:section]]];
    }
    
    return items;
}

+ (NSArray<id<BLSectionItem>> *)dataSectionItems:(id<BLData>)data {
    NSInteger numberOfSections = [data numberOfSections];
    NSMutableArray<id<BLSectionItem>> *items = [NSMutableArray arrayWithCapacity:numberOfSections];
    
    for (NSInteger section = 0; section < numberOfSections; ++section) {
        [items addObject:[data itemForSection:section]];
    }
    
    return items;
}

+ (void)data:(id<BLData>)data enumerateItemsWithBlock:(BLDataItemEnumerationBlock)block {
    BOOL stop = NO;
    
    for (NSInteger section = 0; section < [data numberOfSections]; ++section) {
        for (NSInteger row = 0; row < [data numberOfItemsInSection:section]; ++row) {
            NSIndexPath *indexPath = [NSIndexPath bl_indexPathForRow:row inSection:section];
            id<BLDataItem> item = [data itemAtIndexPath:indexPath];
            
            block(item, indexPath, &stop);
            
            if (stop) {
                return;
            }
        }
    }
}

#pragma mark - BLDataDiff stuff

+ (BOOL)dataDiffIsEmpty:(id<BLDataDiff>)dataDiff {
    return (dataDiff.insertedIndexPaths.count == 0 &&
            dataDiff.deletedIndexPaths.count == 0 &&
            dataDiff.changedIndexPaths.count == 0 &&
            dataDiff.insertedSections.count == 0 &&
            dataDiff.deletedSections.count == 0 &&
            dataDiff.changedSections.count == 0);
}

@end
