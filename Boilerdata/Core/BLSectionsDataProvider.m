//
//  BLSectionsDataProvider.m
//  Boilerdata
//
//  Created by Makarov Yury on 21/03/16.
//  Copyright © 2016 Pixty. All rights reserved.
//

#import "BLSectionsDataProvider.h"
#import "BLBasicDataProvider+Subclassing.h"
#import "BLSectionsData.h"

@implementation BLSectionsDataProvider

- (void)updateWithSections:(nullable NSArray<id<BLDataSection>> *)sections {
    [self updateWithSections:sections updatedItemIds:nil context:nil];
}

- (void)updateWithSections:(nullable NSArray<id<BLDataSection>> *)sections updatedItemIds:(nullable NSSet<id<BLDataItemId>> *)updatedItemIds {
    [self updateWithSections:sections updatedItemIds:nil context:nil];
}

- (void)updateWithSections:(nullable NSArray<id<BLDataSection>> *)sections
            updatedItemIds:(nullable NSSet<id<BLDataItemId>> *)precalculatedUpdatedItemIds
                   context:(nullable NSDictionary *)context {
    BLSectionsData *newData = [[BLSectionsData alloc] initWithSections:sections];
    [self updateWithData:newData updatedItemIds:precalculatedUpdatedItemIds context:context];
}

@end
