/*
 * ShopliveFilterSDKProcessingContext.h
 *
 *  Created on: 2015-9-17
 *      Author: Wang Yang
 *        Mail: admin@wysaid.org
 */

#ifndef _ShopliveFilterSDK_PROCESSINGCONTEXT_H_
#define _ShopliveFilterSDK_PROCESSINGCONTEXT_H_

#import <Foundation/Foundation.h>

@interface ShopliveFilterSDKProcessingContext : NSObject
{
    @public void* _contextKey;
}

@property(nonatomic) dispatch_queue_t contextQueue;

- (void)syncProcessingQueue:(void (^)(void))block;
- (void)asyncProcessingQueue:(void (^)(void))block;

/////////////////////////////////////////////


+ (void)mainSyncProcessingQueue:(void (^)(void))block;
+ (void)mainASyncProcessingQueue:(void (^)(void))block;

#if defined(_ShopliveFilterSDK_GENERAL_ERROR_TEST_ ) && _ShopliveFilterSDK_GENERAL_ERROR_TEST_

+ (int)refCount;

#endif

@end

#endif
