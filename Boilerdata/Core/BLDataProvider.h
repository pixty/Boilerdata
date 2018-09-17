//
//  BLDataProvider.h
//  Boilerdata
//
//  Created by Nick Tymchenko on 05/01/16.
//  Copyright © 2016 Pixty. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BLDataEvent;
@protocol BLData;
@protocol BLDataObserver;

NS_ASSUME_NONNULL_BEGIN


typedef void (^BLDataProviderListenerBlock)(BLDataEvent *event);

@protocol BLDataProvider <NSObject>

@property (nonatomic, strong, readonly) id<BLData> data;

@property (nonatomic, weak) id<BLDataObserver> observer;

@property (nonatomic, assign, getter = isLocked) BOOL locked;

- (id)addWillUpdateListener:(BLDataProviderListenerBlock)listener;
- (id)addDidUpdateListener:(BLDataProviderListenerBlock)listener;
- (void)removeListenerWithToken:(id)token;

@end


NS_ASSUME_NONNULL_END
