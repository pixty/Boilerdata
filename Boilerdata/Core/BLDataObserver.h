//
//  BLDataObserver.h
//  Boilerdata
//
//  Created by Nick Tymchenko on 05/01/16.
//  Copyright © 2016 Pixty. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BLDataProvider;
@protocol BLDataEventProcessor;
@class BLDataEvent;

NS_ASSUME_NONNULL_BEGIN


@protocol BLDataObserver <NSObject>

- (nullable id<BLDataEventProcessor>)dataProvider:(id<BLDataProvider>)dataProvider willUpdateWithEvent:(BLDataEvent *)event;

@optional

- (void)dataProvider:(id<BLDataProvider>)dataProvider didUpdateWithEvent:(BLDataEvent *)event;

@end


NS_ASSUME_NONNULL_END