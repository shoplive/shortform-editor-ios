/*
 * ShopliveFilterSDKMotionBlurAdjust.h
 *
 *  Created on: 2014-9-25
 */

#ifndef _ShopliveFilterSDKMOTIONBLURADJUST_H
#define _ShopliveFilterSDKMOTIONBLURADJUST_H

#include "ShopliveFilterSDKGLFunctions.h"
#include "ShopliveFilterSDKSharpenBlurAdjust.h"
#include "ShopliveFilterSDKVec.h"

namespace ShopliveFilterSDK
{
	class ShopliveFilterSDKMotionBlurFilter : public ShopliveFilterSDKImageFilterInterface
	{
	public:
		ShopliveFilterSDKMotionBlurFilter(){}
		~ShopliveFilterSDKMotionBlurFilter(){}

		bool init();

		// range: radius >= 0.0
		void setSamplerRadius(float radius);

		void setAngle(float angle);
		void setRadians(float radians);

		void render2Texture(ShopliveFilterSDKImageHandlerInterface* handler, GLuint srcTexture, GLuint vertexBufferID);

	protected:
		static ShopliveFilterSDKConstString paramSamplerRadiusName;
		static ShopliveFilterSDKConstString paramSamplerStepName;
		static ShopliveFilterSDKConstString paramBlurNormName;

		float m_samplerRadius;
		Vec2f m_blurNorm;
	};
    
    class ShopliveFilterSDKMotionBlurCurveFilter : public ShopliveFilterSDKMotionBlurFilter
    {
    public:
        bool init();
    };
}

#endif
