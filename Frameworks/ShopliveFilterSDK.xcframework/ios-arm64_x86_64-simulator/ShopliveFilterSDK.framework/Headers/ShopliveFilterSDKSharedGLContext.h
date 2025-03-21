/*
 * ShopliveFilterSDKSharedGLContext.h
 *
 *  Created on: 2015-7-11
 *      Author: Wang Yang
 *        Mail: admin@wysaid.org
 */

#ifndef _ShopliveFilterSDK_SHAREDGLCONTEXT_H_
#define _ShopliveFilterSDK_SHAREDGLCONTEXT_H_

#import <Foundation/Foundation.h>
#import <OpenGLES/EAGL.h>
#import "ShopliveFilterSDKProcessingContext.h"

@interface ShopliveFilterSDKSharedGLContext : ShopliveFilterSDKProcessingContext

@property(nonatomic,strong) EAGLContext *context;

- (id)initWithShareGroup:(EAGLSharegroup*)shareGroup;

- (void)makeCurrent;

/////////////////////////////////////////////

+ (instancetype)globalGLContext;

+ (BOOL)isGlobalGLContextExist;
//Attention: the pre-created context will be desctroyed after this function.
//So you can use "isGlobalGLContextExist" to see if the context is created.
+ (instancetype)bindGlobalGLContext:(EAGLContext*)context;

+ (void)useGlobalGLContext;
+ (void)clearGlobalGLContext;

+ (void)globalSyncProcessingQueue:(void (^)(void))block;
+ (void)globalAsyncProcessingQueue:(void (^)(void))block;

+(instancetype)createSharedContext:(ShopliveFilterSDKSharedGLContext*)sharedContext;
+(instancetype)createGlobalSharedContext;


@end

#endif
