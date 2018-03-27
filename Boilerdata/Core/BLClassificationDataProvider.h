//
//  BLClassificationDataProvider.h
//  Boilerdata
//
//  Created by Nick Tymchenko on 18/02/16.
//  Copyright © 2016 Pixty. All rights reserved.
//

#import "BLChainDataProvider.h"

@protocol BLDataItem;

NS_ASSUME_NONNULL_BEGIN


typedef id<BLDataItem> _Nonnull (^BLDataItemClassificationBlock)(id<BLDataItem> dataItem);

typedef NSArray<id<BLDataItem>> * _Nonnull (^BLSectionItemSortingBlock)(NSArray<id<BLDataItem>> *sectionItems);


@interface BLClassificationDataProvider : BLChainDataProvider

- (instancetype)initWithDataProvider:(id<BLDataProvider>)dataProvider
                 classificationBlock:(BLDataItemClassificationBlock)classificationBlock
                 sectionSortingBlock:(nullable BLSectionItemSortingBlock)sectionSortingBlock NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

@end


NS_ASSUME_NONNULL_END
