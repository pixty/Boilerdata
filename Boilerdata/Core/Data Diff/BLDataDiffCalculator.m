//
//  BLDataDiffCalculator.m
//  Boilerdata
//
//  Created by Nick Tymchenko on 07/01/16.
//  Copyright © 2016 Pixty. All rights reserved.
//

#import "BLDataDiffCalculator.h"
#import "BLDataItem.h"
#import "BLDataSection.h"

#import <NNArrayDiff/ArrayDiff.h>
#import "NNSectionsDiff+BLDataDiff.h"


@implementation BLDataDiffCalculator

+ (id<BLDataDiff>)diffForItemsBefore:(NSArray<id<BLDataItem>> *)itemsBefore
                          itemsAfter:(NSArray<id<BLDataItem>> *)itemsAfter
{
    return [self diffForItemsBefore:itemsBefore itemsAfter:itemsAfter updatedBlock:nil];
}

+ (id<BLDataDiff>)diffForItemsBefore:(NSArray<id<BLDataItem>> *)itemsBefore
                          itemsAfter:(NSArray<id<BLDataItem>> *)itemsAfter
                        updatedBlock:(BLDataItemUpdatedBlock)updatedBlock
{
    NNSectionsDiffCalculator *calculator = [self calculatorWithUpdatedBlock:updatedBlock];
    return [calculator calculateDiffForSingleSectionObjectsBefore:itemsBefore andAfter:itemsAfter];
}

+ (id<BLDataDiff>)diffForSectionsBefore:(NSArray<id<BLDataSection>> *)sectionsBefore
                          sectionsAfter:(NSArray<id<BLDataSection>> *)sectionsAfter
{
    return [self diffForSectionsBefore:sectionsBefore sectionsAfter:sectionsAfter updatedBlock:nil];
}

+ (id<BLDataDiff>)diffForSectionsBefore:(NSArray<id<BLDataSection>> *)sectionsBefore
                          sectionsAfter:(NSArray<id<BLDataSection>> *)sectionsAfter
                           updatedBlock:(BLDataItemUpdatedBlock)updatedBlock
{
    NNSectionsDiffCalculator *calculator = [self calculatorWithUpdatedBlock:updatedBlock];
    return [calculator calculateDiffForSectionsBefore:[self convertSections:sectionsBefore]
                                             andAfter:[self convertSections:sectionsAfter]];
}

#pragma mark - Private

+ (NNSectionsDiffCalculator *)calculatorWithUpdatedBlock:(BLDataItemUpdatedBlock)updatedBlock {
    NNSectionsDiffCalculator *calculator = [[NNSectionsDiffCalculator alloc] init];
    
    calculator.objectIdBlock = ^(id<BLDataItem> item) {
        return item.itemId;
    };
    
    if (updatedBlock) {
        calculator.objectUpdatedBlock = updatedBlock;
    }
    
    return calculator;
}

+ (NSArray<NNSection *> *)convertSections:(NSArray<id<BLDataSection>> *)sections {
    NSMutableArray *convertedSections = [NSMutableArray arrayWithCapacity:sections.count];
    
    for (id<BLDataSection> section in sections) {
        [convertedSections addObject:[[NNSection alloc] initWithKey:section.headerItem.itemId objects:section.items]];
    }
    
    return convertedSections;
}

@end
