//
//  BLDataEventProcessor.h
//  Boilerdata
//
//  Created by Nick Tymchenko on 05/01/16.
//  Copyright © 2016 Pixty. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BLDataEvent;
@protocol BLDataDiff;

NS_ASSUME_NONNULL_BEGIN


typedef void (^BLDataEventProcessorCompletion)(_Nullable id<BLDataDiff> diff) ;

@protocol BLDataEventProcessor <NSObject>

- (void)applyEvent:(BLDataEvent *)event withDataUpdateBlock:(void (^)(void))dataUpdateBlock completion:(BLDataEventProcessorCompletion)completion;

@end


NS_ASSUME_NONNULL_END
