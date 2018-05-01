//
//  BLLocalizedIndexedCollationDataProvider.m
//  Boilerdata
//
//  Created by Makarov Yury on 01/04/16.
//  Copyright © 2016 Pixty. All rights reserved.
//

#import "BLLocalizedIndexedCollationDataProvider.h"
#import "BLChainDataProvider+Subclassing.h"
#import "BLLocalizedIndexedCollationData.h"
#import "BLDataEvent.h"
#import "NSString+BLDataItem.h"

@implementation BLLocalizedIndexedCollationDataProvider

- (instancetype)initWithDataProvider:(id<BLDataProvider>)dataProvider stringifierBlock:(BLDataItemStringifierBlock)stringifierBlock {
    UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
    
    return [super initWithDataProvider:dataProvider classificationBlock:^id<BLDataItem>(id<BLDataItem> dataItem, NSIndexPath *indexPath) {
        NSString *string = stringifierBlock(dataItem);
        NSUInteger sectionIndex = [collation sectionForObject:string collationStringSelector:@selector(self)];
        return [collation.sectionTitles objectAtIndex:sectionIndex];
        
    } sectionSortingBlock:^NSArray<id<BLDataItem>> *(NSArray<id<BLDataItem>> *sectionItems) {
        NSOrderedSet<NSString *> *collationTitles = [NSOrderedSet orderedSetWithArray:collation.sectionTitles];
        
        return [sectionItems sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
            return [@([collationTitles indexOfObject:obj1]) compare:@([collationTitles indexOfObject:obj2])];
        }];
    }];
}

#pragma mark - BLChainDataProvider

- (id<BLData>)transformInnerDataForEvent:(BLDataEvent *)innerEvent withLastQueuedData:(id<BLData>)lastQueuedData {
    id<BLData> data = [super transformInnerDataForEvent:innerEvent withLastQueuedData:lastQueuedData];
    return [[BLLocalizedIndexedCollationData alloc] initWithOriginalData:data];
}

@end
