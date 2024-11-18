/*
* ShopliveFilterSDKSpriteCommon.h
*
*  Created on: 2014-9-25
*      Author: Wang Yang
*        Mail: admin@wysaid.org
*/

#if !defined(_ShopliveFilterSDKSPRITECOMMON_H_) && !defined(_ShopliveFilterSDK_ONLY_FILTERS_)
#define _ShopliveFilterSDKSPRITECOMMON_H_

#include "ShopliveFilterSDKMat.h"
#include "ShopliveFilterSDKGLFunctions.h"
#include "ShopliveFilterSDKShaderFunctions.h"

//简介： 本文件中包含一些sprite需要使用到的辅助类和函数

namespace ShopliveFilterSDK
{
//	void ShopliveFilterSDKSpritesInitBuiltin();
//	void ShopliveFilterSDKSpritesCleanupBuiltin();

	class SpriteCommonSettings
	{
	public:
		SpriteCommonSettings();
		virtual ~SpriteCommonSettings();

		static ShopliveFilterSDKSizei sCanvasSize; //Sprite2d 被绘制的画布大小（全局, 必须提前设置）

		inline static void sSetCanvasSize(int w, int h)
		{
			sCanvasSize.set(w, h);
			sOrthoProjectionMatrix = Mat4::makeOrtho(0.0f, (float)w, 0.0f, (float)h, -1e3f, 1e3f);
		}

		//仅对后面将要创建的 sprite 进行全局默认设置。 对于已经创建好的sprite，可以通过 set*Flip 函数进行单独处理
		static void sFlipCanvas(bool x, bool y); 
		static void sFlipSprite(bool x, bool y); 

        ShopliveFilterSDK_LOG_CODE
        (
         static std::vector<SpriteCommonSettings*>& getDebugManager();
        )
        
	protected:

		static Mat4 sOrthoProjectionMatrix;
		static bool sCanvasFlipX, sCanvasFlipY;
		static bool sSpriteFlipX, sSpriteFlipY;

	};

}

#endif
