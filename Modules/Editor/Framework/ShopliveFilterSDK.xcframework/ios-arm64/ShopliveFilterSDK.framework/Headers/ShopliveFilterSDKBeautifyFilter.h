/*
* ShopliveFilterSDKBeautifyFilter.h
*
*  Created on: 2016-3-22
*      Author: Wang Yang
*/

#ifndef _ShopliveFilterSDK_BEAUTIFYFILTER_H_
#define _ShopliveFilterSDK_BEAUTIFYFILTER_H_

#include "ShopliveFilterSDKImageFilter.h"

namespace ShopliveFilterSDK
{
    class ShopliveFilterSDKBeautifyFilter : public ShopliveFilterSDKImageFilterInterface
    {
    public:
        
        bool init();
        
        void setIntensity(float intensity);
        
        void setImageSize(float width, float height, float mul = 1.5f);
        
        void render2Texture(ShopliveFilterSDKImageHandlerInterface* handler, GLuint srcTexture, GLuint vertexBufferID);
        
    protected:
        float m_intensity;
    };
}

#endif
