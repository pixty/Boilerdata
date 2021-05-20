//
//  BLUIKitViewReloader.m
//  Boilerdata
//
//  Created by Nick Tymchenko on 10/01/16.
//  Copyright © 2016 Pixty. All rights reserved.
//

#import "BLUIKitViewReloader.h"
#import "BLUITableViewReloaderEngine.h"
#import "BLUITableViewAnimations.h"
#import "BLUICollectionViewReloaderEngine.h"
#import "BLDataEvent.h"
#import "BLDataItem.h"
#import "BLDataDiff.h"
#import "BLDataDiffChange.h"
#import "BLDataDiffCalculator.h"

@interface BLUIKitViewReloader ()

@property (nonatomic, strong, readonly) id<BLUIKitViewReloaderEngine> engine;

@end


@implementation BLUIKitViewReloader

#pragma mark - Init

- (instancetype)initWithTableView:(UITableView *)tableView {
    return [self initWithTableView:tableView animations:[[BLUITableViewAnimations alloc] init]];
}

- (instancetype)initWithTableView:(UITableView *)tableView animations:(BLUITableViewAnimations *)animations {
    return [self initWithEngine:[[BLUITableViewReloaderEngine alloc] initWithTableView:tableView animations:animations]];
}

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView {
    return [self initWithCollectionView:collectionView shouldAnimate:YES];
}

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView shouldAnimate:(BOOL)shouldAnimate {
    return [self initWithEngine:[[BLUICollectionViewReloaderEngine alloc] initWithCollectionView:collectionView shouldAnimate:shouldAnimate]];
}

- (instancetype)initWithEngine:(id<BLUIKitViewReloaderEngine>)engine {
    self = [super init];
    if (!self) return nil;
    
    _engine = engine;
    
    return self;
}

#pragma mark - Config

- (BLCellUpdateBlock)cellUpdateBlock {
    return self.engine.cellUpdateBlock;
}

- (void)setCellUpdateBlock:(BLCellUpdateBlock)cellUpdateBlock {
    self.engine.cellUpdateBlock = cellUpdateBlock;
}

#pragma mark - BLDataEventProcessor

- (void)applyEvent:(BLDataEvent *)event withDataUpdateBlock:(void (^)(void))dataUpdateBlock completion:(BLDataEventProcessorCompletion)completion {
    if ([self shouldUseReloadDataForEvent:event]) {
        dataUpdateBlock();

        // TODO: we need a callback here
        [self.engine reloadData];

        if (self.didReloadDataBlock != nil) {
            self.didReloadDataBlock([self.engine shouldForceReloadData]);
        }

        completion(nil);

        return;
    }
    
    id<BLDataDiff> dataDiff = [BLDataDiffCalculator diffForDataBefore:event.oldData
                                                            dataAfter:event.newData
                                                         updatedBlock:^BOOL(id<BLDataItem> itemBefore, id<BLDataItem> itemAfter) {
                                                             return [event.updatedItemIds containsObject:itemAfter.itemId];
                                                         }];
    
    if ([self isDataDiffEmpty:dataDiff]) {
        dataUpdateBlock();
        completion(nil);
        return;
    }
    
    [self.engine performUpdates:^{
        dataUpdateBlock();
        
        [self.engine deleteSections:dataDiff.deletedSections];
        [self.engine insertSections:dataDiff.insertedSections];
        
        [self.engine deleteItemsAtIndexPaths:dataDiff.deletedIndexPaths.allObjects];
        [self.engine insertItemsAtIndexPaths:dataDiff.insertedIndexPaths.allObjects];
        
        for (id<BLDataDiffSectionChange> change in dataDiff.changedSections) {
            if (change.updated) {
                [self.engine reloadSections:[NSIndexSet indexSetWithIndex:change.before]];
            }
            
            if (change.moved) {
                [self.engine moveSection:change.before toSection:change.after];
            }
        }
        
        for (id<BLDataDiffIndexPathChange> change in dataDiff.changedIndexPaths) {
            if (change.updated) {
                if (self.useCellUpdateBlockForReload) {
                    [self.engine customReloadItemsAtIndexPaths:@[ change.before ]];
                } else {
                    [self.engine reloadItemsAtIndexPaths:@[ change.before ]];
                }
            }
            
            if (change.moved) {
                if (self.useMoveWhenPossible) {
                    [self.engine moveItemAtIndexPath:change.before toIndexPath:change.after];
                } else {
                    [self.engine deleteItemsAtIndexPaths:@[ change.before ]];
                    [self.engine insertItemsAtIndexPaths:@[ change.after ]];
                }
            }
        }
    } completion:^{
        if (self.waitForAnimationCompletion) {
            completion(dataDiff);
        }
    }];
        
    if (!self.waitForAnimationCompletion) {
        completion(dataDiff);
    }
}

#pragma mark - Private

- (BOOL)shouldUseReloadDataForEvent:(BLDataEvent *)event {
    if (self.forceReloadData) {
        return YES;
    }
    
    if ([self.engine shouldForceReloadData]) {
        return YES;
    }
    
    // TODO: need more sophisticated stuff here?
    
    return NO;
}

- (BOOL)isDataDiffEmpty:(id<BLDataDiff>)dataDiff {
    return (dataDiff.insertedIndexPaths.count == 0 &&
            dataDiff.deletedIndexPaths.count == 0 &&
            dataDiff.changedIndexPaths.count == 0 &&
            dataDiff.insertedSections.count == 0 &&
            dataDiff.deletedSections.count == 0 &&
            dataDiff.changedSections.count == 0);
}

@end
