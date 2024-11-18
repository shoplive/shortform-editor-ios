/*
* ShopliveFilterSDKLookupFilter.h
*
*  Created on: 2016-7-4
*      Author: Wang Yang
* Description: 全图LUT滤镜
*/

#ifndef _ShopliveFilterSDK_LOOKUPFILTER_H_
#define _ShopliveFilterSDK_LOOKUPFILTER_H_

#include "ShopliveFilterSDKGLFunctions.h"

namespace ShopliveFilterSDK
{
	class ShopliveFilterSDKLookupFilter : public ShopliveFilterSDKImageFilterInterface
	{
	public:
		ShopliveFilterSDKLookupFilter();
		~ShopliveFilterSDKLookupFilter();

		bool init();

		inline void setLookupTexture(GLuint tex) { m_lookupTexture = tex; };

		void render2Texture(ShopliveFilterSDKImageHandlerInterface* handler, GLuint srcTexture, GLuint vertexBufferID);

		inline GLuint& lookupTexture() { return m_lookupTexture; }

	protected: 
		GLuint m_lookupTexture;
	};

}

#endif
