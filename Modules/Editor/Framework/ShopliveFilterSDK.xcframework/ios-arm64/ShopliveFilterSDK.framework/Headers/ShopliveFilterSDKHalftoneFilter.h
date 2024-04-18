/*
 * ShopliveFilterSDKHalftoneFilter.h
 *
 *  Created on: 2015-1-29
 *      Author: Wang Yang
 */

#ifndef _ShopliveFilterSDKHALFTONEFILTER_H_
#define _ShopliveFilterSDKHALFTONEFILTER_H_

#include "ShopliveFilterSDKGLFunctions.h"

namespace ShopliveFilterSDK
{
	class ShopliveFilterSDKHalftoneFilter : public ShopliveFilterSDKImageFilterInterface
	{
	public:

		bool init();

		//Range: >= 1.
		void setDotSize(float value);

		void render2Texture(ShopliveFilterSDK::ShopliveFilterSDKImageHandlerInterface* handler, GLuint srcTexture, GLuint vertexBufferID);

	protected:
		static ShopliveFilterSDKConstString paramAspectRatio;
		static ShopliveFilterSDKConstString paramDotPercent;
		float m_dotSize;
	};


}

#endif
