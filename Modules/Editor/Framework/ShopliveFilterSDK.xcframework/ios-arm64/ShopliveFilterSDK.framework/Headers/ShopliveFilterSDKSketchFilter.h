/*
* ShopliveFilterSDKSketchFilter.h
*
*  Created on: 2015-3-20
*      Author: Wang Yang
*/

#ifndef _ShopliveFilterSDK_SKETCHFILTER_H_
#define _ShopliveFilterSDK_SKETCHFILTER_H_

#include "ShopliveFilterSDKMaxValueFilter.h"
#include "ShopliveFilterSDKMultipleEffects.h"

namespace ShopliveFilterSDK
{
	class ShopliveFilterSDKSketchFilter : public ShopliveFilterSDKImageFilterInterface
	{
	public:

		ShopliveFilterSDKSketchFilter();
		~ShopliveFilterSDKSketchFilter();

		bool init();

		void setIntensity(float intensity);

		void render2Texture(ShopliveFilterSDK::ShopliveFilterSDKImageHandlerInterface* handler, GLuint srcTexture, GLuint vertexBufferID);

		void flush();

	protected:

		static ShopliveFilterSDKConstString paramCacheTextureName;
		static ShopliveFilterSDKConstString paramIntensityName;
		
		ShopliveFilterSDKMaxValueFilter3x3 m_maxValueFilter;
		GLuint m_textureCache;
		ShopliveFilterSDKSizei m_cacheSize;
	};
}

#endif
