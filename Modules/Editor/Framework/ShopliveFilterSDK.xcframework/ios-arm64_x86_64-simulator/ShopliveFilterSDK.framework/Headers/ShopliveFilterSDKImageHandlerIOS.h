/*
 * ShopliveFilterSDKImageHandlerIOS.h
 *
 *  Created on: 2015-8-23
 *      Author: Wang Yang
 *        Mail: admin@wysaid.org
 */

#ifndef __ShopliveFilterSDK__ShopliveFilterSDKImageHandlerIOS__
#define __ShopliveFilterSDK__ShopliveFilterSDKImageHandlerIOS__

#import <UIKit/UIKit.h>
#include "ShopliveFilterSDKImageHandler.h"

namespace ShopliveFilterSDK
{
    class ShopliveFilterSDKImageHandlerIOS : public ShopliveFilterSDK::ShopliveFilterSDKImageHandler
    {
    public:
        
        ShopliveFilterSDKImageHandlerIOS();
        ~ShopliveFilterSDKImageHandlerIOS();
        
        bool initWithUIImage(UIImage* uiimage, bool useImageBuffer = true, bool enableRevision = false);
        
        UIImage* getResultUIImage();
        
        void processingFilters();
        
        void swapBufferFBO();
        
        void enableImageBuffer(bool useBuffer);
        bool isImageBufferEnabled() { return m_imageBuffer != nullptr;}
        
    protected:
        
        unsigned char* m_imageBuffer;
        int m_imageBufferLen;
        CGFloat m_imageScale;
    };

}


#endif /* defined(__ShopliveFilterSDK__ShopliveFilterSDKImageHandlerIOS__) */
