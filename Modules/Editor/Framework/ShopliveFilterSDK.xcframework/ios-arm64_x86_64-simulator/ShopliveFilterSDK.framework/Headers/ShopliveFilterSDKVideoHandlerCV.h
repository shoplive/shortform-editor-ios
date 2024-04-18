/*
 * ShopliveFilterSDKVideoHandlerCV.h
 *
 *  Created on: 2015-9-8
 *      Author: Wang Yang
 *        Mail: admin@wysaid.org
 */

#ifndef _ShopliveFilterSDKVIDEOHANLERCV_H_
#define _ShopliveFilterSDKVIDEOHANLERCV_H_

#import <Foundation/Foundation.h>
#import <CoreVideo/CoreVideo.h>
#import <UIKit/UIKit.h>
#import "ShopliveFilterSDKImageHandler.h"
#import "ShopliveFilterSDKTextureUtils.h"

namespace ShopliveFilterSDK
{
    class ShopliveFilterSDKVideoHandlerCV : public ShopliveFilterSDKImageHandler
    {
    public:
        ShopliveFilterSDKVideoHandlerCV();
        ~ShopliveFilterSDKVideoHandlerCV();
        
        bool initHandler();
        
        bool updateFrameWithCVImageBuffer(CVImageBufferRef);
        
        void cleanupYUVTextures();
        
        void processingFilters();
        
        inline TextureDrawerYUV* getYUVDrawer() { return m_yuvDrawer; }
        
        inline void replaceYUVDrawer(TextureDrawerYUV* drawer, bool shouldDelete = true)
        {
            if(shouldDelete)
                delete m_yuvDrawer;
            m_yuvDrawer = drawer;
        }

        bool reverseTargetSize() { return m_reverseTargetSize; }

        void setReverseTargetSize(bool rev) { m_reverseTargetSize = rev; }
        
        void swapBufferFBO();
        
    private:
        
        CVOpenGLESTextureCacheRef m_videoTextureCacheRef;
        CVOpenGLESTextureRef m_lumaTextureRef;
        CVOpenGLESTextureRef m_chromaTextureRef;
        
        TextureDrawerYUV* m_yuvDrawer;
        bool m_reverseTargetSize;
    };
}


#endif
