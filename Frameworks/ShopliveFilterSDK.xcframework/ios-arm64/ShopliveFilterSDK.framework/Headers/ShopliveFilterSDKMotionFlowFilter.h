/*
 * ShopliveFilterSDKDynamicWaveFilter.h
 *
 *  Created on: 2016-8-12
 *      Author: Wang Yang
 */

#ifndef ShopliveFilterSDKMotionFlowFilter_h
#define ShopliveFilterSDKMotionFlowFilter_h

#include "ShopliveFilterSDKGLFunctions.h"
#include <list>

namespace ShopliveFilterSDK
{
    class TextureDrawer;
    
    class ShopliveFilterSDKMotionFlowFilter : public ShopliveFilterSDKImageFilterInterface
    {
    public:
        ShopliveFilterSDKMotionFlowFilter();
        ~ShopliveFilterSDKMotionFlowFilter();
        
        bool init();
        
        void setTotalFrames(int frames);
        void setFrameDelay(int delayFrame);
        
        void render2Texture(ShopliveFilterSDKImageHandlerInterface* handler, GLuint srcTexture, GLuint vertexBufferID);
        
    protected:
        
        virtual void pushFrame(GLuint texture);
        void clear();
        
    protected:
        
        static ShopliveFilterSDKConstString paramAlphaName;
        
        std::list<GLuint> m_frameTextures;
        std::vector<GLuint> m_totalFrameTextures;
        FrameBuffer m_framebuffer;
        TextureDrawer* m_drawer;
        int m_width, m_height;
        int m_totalFrames, m_delayFrames;
        int m_delayedFrames;
        
        float m_dAlpha;
        GLint m_alphaLoc;
    };
    
    class ShopliveFilterSDKMotionFlow2Filter : public ShopliveFilterSDKMotionFlowFilter
    {
    public:
        ShopliveFilterSDKMotionFlow2Filter();
        
//        void render2Texture(ShopliveFilterSDKImageHandlerInterface* handler, GLuint srcTexture, GLuint vertexBufferID);
        
    protected:
        void pushFrame(GLuint texture);
        
        float m_sizeScaling, m_dSizeScaling;
        float m_dsMost;
        
        bool m_continuouslyTrigger;
    };
    
    
    
    
}


#endif /* ShopliveFilterSDKMotionFlowFilter_h */
