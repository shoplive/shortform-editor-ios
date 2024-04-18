/*
 * ShopliveFilterSDKAdvancedEffectsCommon.h
 *
 *  Created on: 2013-12-13
 *      Author: Wang Yang
 */

#ifndef _ShopliveFilterSDKADVANCEDEFFECTSCOMMON_H_
#define _ShopliveFilterSDKADVANCEDEFFECTSCOMMON_H_

#include "ShopliveFilterSDKGLFunctions.h"
#include "ShopliveFilterSDKImageFilter.h"
#include "ShopliveFilterSDKImageHandler.h"

namespace ShopliveFilterSDK
{
	class ShopliveFilterSDKAdvancedEffectOneStepFilterHelper : public ShopliveFilterSDKImageFilterInterface
	{
	public:
		ShopliveFilterSDKAdvancedEffectOneStepFilterHelper(){}
		~ShopliveFilterSDKAdvancedEffectOneStepFilterHelper(){}
		virtual void render2Texture(ShopliveFilterSDKImageHandlerInterface* handler, GLuint srcTexture, GLuint vertexBufferID);

	protected:
		static ShopliveFilterSDKConstString paramStepsName;
	};

	class ShopliveFilterSDKAdvancedEffectTwoStepFilterHelper : public ShopliveFilterSDKImageFilterInterface
	{
	public:
		ShopliveFilterSDKAdvancedEffectTwoStepFilterHelper() {}
		~ShopliveFilterSDKAdvancedEffectTwoStepFilterHelper() {}

		virtual void render2Texture(ShopliveFilterSDKImageHandlerInterface* handler, GLuint srcTexture, GLuint vertexBufferID);

	protected:
		static ShopliveFilterSDKConstString paramStepsName;
	};

}

#endif
