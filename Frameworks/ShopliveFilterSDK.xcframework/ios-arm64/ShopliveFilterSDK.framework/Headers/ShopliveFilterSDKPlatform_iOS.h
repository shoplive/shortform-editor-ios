/*
 * ShopliveFilterSDKPlatforms.h
 *
 *  Created on: 2013-12-31
 *      Author: Wang Yang
 *  Description: load some library and do some essential initialization before compiling.
 */

#ifndef ShopliveFilterSDKPLATFORMS_H_
#define ShopliveFilterSDKPLATFORMS_H_

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#ifndef ShopliveFilterSDK_SHADER_CONFIG_PLATFORM
#define ShopliveFilterSDK_SHADER_CONFIG_PLATFORM "\n#ifndef ShopliveFilterSDK_PLATFORM_IOS\n#define ShopliveFilterSDK_PLATFORM_IOS\n#endif\n"
#endif

#if (defined(DEBUG) || defined(_DEBUG) || defined(_ShopliveFilterSDK_USE_LOG_ERR_))
#include <stdio.h>
#endif

#if (defined(DEBUG) || defined(_DEBUG))

#ifndef ShopliveFilterSDK_LOG_INFO
#define ShopliveFilterSDK_LOG_INFO(...) printf(__VA_ARGS__)
#endif

#ifndef ShopliveFilterSDK_LOG_CODE
#define ShopliveFilterSDK_LOG_CODE(...) __VA_ARGS__
#endif

#include <assert.h>
#define ShopliveFilterSDKAssert assert
#else

#ifndef ShopliveFilterSDK_LOG_INFO
#define ShopliveFilterSDK_LOG_INFO(...)
#endif

#ifndef ShopliveFilterSDK_LOG_CODE
#define ShopliveFilterSDK_LOG_CODE(...)

#define ShopliveFilterSDKAssert(...)
#endif

#endif

#if !defined(ShopliveFilterSDK_LOG_ERROR) && (defined(_ShopliveFilterSDK_USE_LOG_ERR_) || defined(DEBUG) || defined(_DEBUG))
#define ShopliveFilterSDK_LOG_ERROR(str, ...) \
do{\
fprintf(stderr, "\n❌❌❌\n" str "\n❌❌❌\n", ##__VA_ARGS__);\
fprintf(stderr, "%s:%d\n", __FILE__, __LINE__);\
}while(0)
#else 
#define ShopliveFilterSDK_LOG_ERROR(str, ...)
#endif

#ifndef ShopliveFilterSDK_UNEXPECTED_ERR_MSG

#define ShopliveFilterSDK_UNEXPECTED_ERR_MSG(...)

#else

//for important log msg
#define ShopliveFilterSDK_LOG_KEEP(...) printf(__VA_ARGS__)

#endif

#endif
