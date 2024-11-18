/*
* ShopliveFilterSDKMinValueFilter.h
*
*  Created on: 2015-3-20
*      Author: Wang Yang
* Description: 最小值滤波
*/

#ifndef _ShopliveFilterSDK_MINVALUE_FILTER_H_
#define _ShopliveFilterSDK_MINVALUE_FILTER_H_

#include "ShopliveFilterSDKGLFunctions.h"

namespace ShopliveFilterSDK
{
	class ShopliveFilterSDKMinValueFilter3x3: public ShopliveFilterSDKImageFilterInterface
	{
	public:

		bool init();

		void render2Texture(ShopliveFilterSDKImageHandlerInterface* handler, GLuint srcTexture, GLuint vertexBufferID);

		GLint getStepsLocation() { return m_samplerStepsLoc; }

	protected:

		static ShopliveFilterSDKConstString paramSamplerStepsName;
		
		virtual const char* getShaderCompFunc();

		void initLocations();

	private:
		GLint m_samplerStepsLoc;
	};

	class ShopliveFilterSDKMinValueFilter3x3Plus: public ShopliveFilterSDKMinValueFilter3x3
	{
	public:

		bool init();
	};

}

#endif
