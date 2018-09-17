//
//  BLAbstractDataProvider.m
//  Boilerdata
//
//  Created by Nick Tymchenko on 06/01/16.
//  Copyright © 2016 Pixty. All rights reserved.
//

#import "BLAbstractDataProvider.h"
#import "BLAbstractDataProvider+Subclassing.h"
#import "BLEmptyData.h"
#import "BLDataEventCallbacks.h"
#import "BLDataEvent.h"
#import "BLDataEventProcessor.h"
#import "BLDataObserver.h"
#import "BLNilDataEventProcessor.h"

@interface BLAbstractDataProvider ()

@property (nonatomic, strong) id<BLData> data;

@property (nonatomic, strong, readonly) NSMutableArray<BLDataEvent *> *eventQueue;
@property (nonatomic, strong, readonly) NSMutableArray<BLDataEventCallbacks *> *eventCallbacksQueue;

@property (nonatomic, copy, readonly) NSMutableDictionary<id, BLDataProviderListenerBlock> *willUpdateListeners;
@property (nonatomic, copy, readonly) NSMutableDictionary<id, BLDataProviderListenerBlock> *didUpdateListeners;

@property (nonatomic, strong) id<BLDataEventProcessor> eventProcessorInProgress;

@end


@implementation BLAbstractDataProvider

#pragma mark - Init

- (instancetype)init {
    self = [super init];
    if (!self) return nil;

    _eventQueue = [NSMutableArray array];
    _eventCallbacksQueue = [NSMutableArray array];
    
    _willUpdateListeners = [NSMutableDictionary dictionary];
    _didUpdateListeners = [NSMutableDictionary dictionary];
    
    [self enqueueDataEventWithInitialData];
    
    return self;
}

#pragma mark - BLDataProvider

@synthesize data = _data;
@synthesize observer = _observer;
@synthesize locked = _locked;

- (void)setLocked:(BOOL)locked {
    if (_locked == locked) {
        return;
    }
    _locked = locked;

    if (!locked) {
        [self dequeueEventIfPossible];
    }
}

static NSUInteger counter = 0;

- (id)addWillUpdateListener:(BLDataProviderListenerBlock)listener {
    NSNumber *token = @(++counter);
    self.willUpdateListeners[token] = listener;
    return token;
}

- (id)addDidUpdateListener:(BLDataProviderListenerBlock)listener {
    NSNumber *token = @(++counter);
    self.didUpdateListeners[token] = listener;
    return token;
}

- (void)removeListenerWithToken:(id)token {
    self.willUpdateListeners[token] = nil;
    self.didUpdateListeners[token] = nil;
}

#pragma mark - Protected

- (void)updateWithBlock:(void (^)(__kindof id<BLData> lastQueuedData))block {
    block(self.eventQueue.lastObject.newData ?: self.data);
}

- (void)enqueueDataEvent:(BLDataEvent *)event {
    [self enqueueDataEvent:event callbacks:nil];
}

- (void)enqueueDataEvent:(BLDataEvent *)event callbacks:(BLDataEventCallbacks *)callbacks {
    [self.eventQueue addObject:event];
    [self.eventCallbacksQueue addObject:callbacks ?: [[BLDataEventCallbacks alloc] init]];
    
    [self dequeueEventIfPossible];
}

#pragma mark - Private

- (void)enqueueDataEventWithInitialData {
    id<BLData> initialData = [self createInitialData];
    
    BLDataEvent *event = [[BLDataEvent alloc] initWithOldData:[BLEmptyData data] newData:initialData];
    
    [self enqueueDataEvent:event];
}

- (void)dequeueEventIfPossible {
    if (self.eventQueue.count == 0 || self.locked || self.eventProcessorInProgress) {
        return;
    }
    
    BLDataEvent *event = self.eventQueue.firstObject;
    BLDataEventCallbacks *callbacks = self.eventCallbacksQueue.firstObject;
    [self.eventQueue removeObjectAtIndex:0];
    [self.eventCallbacksQueue removeObjectAtIndex:0];
    
    self.eventProcessorInProgress = [self getProcessorForEvent:event];
    
    if (callbacks.willProcessBlock) {
        callbacks.willProcessBlock(self.eventProcessorInProgress);
    }
    
    [self.eventProcessorInProgress applyEvent:event withDataUpdateBlock:^{
        if (callbacks.willUpdateDataBlock) {
            callbacks.willUpdateDataBlock();
        }
        
        self.data = event.newData;
        
        if (callbacks.didUpdateDataBlock) {
            callbacks.didUpdateDataBlock();
        }
        
        [self callListenersWithEvent:event willUpdate:YES];
        
    } completion:^(_Nullable id<BLDataDiff> diff) {
        if ([self.observer respondsToSelector:@selector(dataProvider:didUpdateWithEvent:)]) {
            [self.observer dataProvider:self didUpdateWithEvent:event];
        }
        
        self.eventProcessorInProgress = nil;
        
        if (callbacks.completionBlock) {
            callbacks.completionBlock();
        }
        
        [self callListenersWithEvent:event willUpdate:NO];
        
        [self dequeueEventIfPossible];
    }];
    
    // TODO: post notifications?
}

- (id<BLDataEventProcessor>)getProcessorForEvent:(BLDataEvent *)event {
    id<BLDataEventProcessor> processor = [self.observer dataProvider:self willUpdateWithEvent:event];
    
    if (!processor) {
        processor = [BLNilDataEventProcessor processor];
    }
    
    return processor;
}

- (void)callListenersWithEvent:(BLDataEvent *)event willUpdate:(BOOL)willUpdate {
    if (willUpdate) {
        for (BLDataProviderListenerBlock listener in self.willUpdateListeners.allValues) {
            listener(event);
        }
    } else {
        for (BLDataProviderListenerBlock listener in self.didUpdateListeners.allValues) {
            listener(event);
        }
    }
}

@end


@implementation BLAbstractDataProvider (Overridable)

- (id<BLData>)createInitialData {
    return [BLEmptyData data];
}

@end
