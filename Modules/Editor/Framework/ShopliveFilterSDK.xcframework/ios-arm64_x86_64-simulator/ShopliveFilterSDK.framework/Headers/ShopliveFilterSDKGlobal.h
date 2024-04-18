/*
* ShopliveFilterSDKGlobal.h
*
*  Created on: 2014-9-9
*      Author: Wang Yang
*        Mail: admin@wysaid.org
*/

#ifndef _ShopliveFilterSDKGLOBAL_H_
#define _ShopliveFilterSDKGLOBAL_H_

#if defined(__APPLE__)
#include <TargetConditionals.h>
#endif

#ifdef GLEW_USED
#include "ShopliveFilterSDKPlatform_GLEW.h"
#elif defined(ANDROID_NDK)
#include "ShopliveFilterSDKPlatform_ANDROID.h"
#elif defined(IOS_SDK) || (defined(TARGET_OS_IOS) && TARGET_OS_IOS) || (defined(TARGET_OS_IPHONE) && TARGET_OS_IPHONE)
#include "ShopliveFilterSDKPlatform_iOS.h"
#elif defined(LIBShopliveFilterSDK4QT_LIB)
#include "ShopliveFilterSDKPlatform_QT.h"
#endif


#ifdef __cplusplus

namespace ShopliveFilterSDK
{
	//辅助类，全局可用。
	class ShopliveFilterSDKGlobalConfig
	{
	public:
		static int viewWidth, viewHeight;

#if _ShopliveFilterSDK_USE_GLOBAL_GL_CACHE_
		static GLuint sVertexBufferCommon;
#endif
		static float sVertexDataCommon[8];

		enum InitArguments
		{
			ShopliveFilterSDK_INIT_LEAST = 0,
			ShopliveFilterSDK_INIT_COMMONVERTEXBUFFER = 0x1,
			ShopliveFilterSDK_INIT_SPRITEBUILTIN = 0x3,
			ShopliveFilterSDK_INIT_DEFAULT = 0xffffffff,
		};

		static InitArguments sInitArugment;
	};
    
	//ShopliveFilterSDK 全局初始化函数。
	bool ShopliveFilterSDKInitialize(int w = ShopliveFilterSDKGlobalConfig::viewWidth, int h = ShopliveFilterSDKGlobalConfig::viewHeight, ShopliveFilterSDKGlobalConfig::InitArguments arg = ShopliveFilterSDKGlobalConfig::ShopliveFilterSDK_INIT_DEFAULT);

	inline bool ShopliveFilterSDKInitialize(int w, int h, GLenum arg)
	{
		return ShopliveFilterSDKInitialize(w, h, ShopliveFilterSDKGlobalConfig::InitArguments(arg));
	}

	void ShopliveFilterSDKInitFilterStatus();

	//ShopliveFilterSDK 全局清除函数
	void ShopliveFilterSDKCleanup();

	//设置画面显示尺寸
	void ShopliveFilterSDKSetGlobalViewSize(int width, int height);

}

#endif

#ifdef __cplusplus
extern "C" {
#endif
    
    void ShopliveFilterSDKPrintGLInfo(void);
    const char* ShopliveFilterSDKQueryGLExtensions(void);
    bool ShopliveFilterSDKCheckGLExtension(const char* ext);

	GLuint ShopliveFilterSDKGenCommonQuadArrayBuffer(void);
    
#ifdef __cplusplus
}
#endif

#endif
