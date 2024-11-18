/*
 * ShopliveFilterSDKBrightnessAdjust.h
 *
 *  Created on: 2013-12-26
 *      Author: Wang Yang
 */

#ifndef _ShopliveFilterSDKBRIGHTNESSADJUST_H_
#define _ShopliveFilterSDKBRIGHTNESSADJUST_H_

#include "ShopliveFilterSDKGLFunctions.h"

namespace ShopliveFilterSDK
{
	class ShopliveFilterSDKBrightnessFilter : public ShopliveFilterSDKImageFilterInterface
	{
	public:

		void setIntensity(float value); // range: [-1, 1]

		bool init();
        
        void render2Texture(ShopliveFilterSDKImageHandlerInterface* handler, GLuint srcTexture, GLuint vertexBufferID);

	protected:
		static ShopliveFilterSDKConstString paramName;
        
    private:
        float m_intensity;
	};

	class ShopliveFilterSDKBrightnessFastFilter : public ShopliveFilterSDKFastAdjustRGBFilter
	{
	public:

		void setIntensity(float value);
		bool init();
	};

}

#endif
