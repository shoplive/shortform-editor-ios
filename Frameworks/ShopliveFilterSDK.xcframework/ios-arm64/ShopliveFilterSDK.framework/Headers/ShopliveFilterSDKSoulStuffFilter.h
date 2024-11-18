//
//  ShopliveFilterSDKSoulStuffFilter.h
//  ShopliveFilterSDKStatic
//
//  Created by Yang Wang on 2017/3/27.
//  Mail: admin@wysaid.org
//  Copyright © 2017年 wysaid. All rights reserved.
//

#ifndef ShopliveFilterSDKSoulStuffFilter_h
#define ShopliveFilterSDKSoulStuffFilter_h

#include "ShopliveFilterSDKGLFunctions.h"
#include "ShopliveFilterSDKVec.h"

namespace ShopliveFilterSDK
{
    class ShopliveFilterSDKSoulStuffFilter : public ShopliveFilterSDKImageFilterInterface
    {
    public:
        ShopliveFilterSDKSoulStuffFilter();
        ~ShopliveFilterSDKSoulStuffFilter();
        
        bool init();
        
        void render2Texture(ShopliveFilterSDKImageHandlerInterface* handler, GLuint srcTexture, GLuint vertexBufferID);
        
        void trigger(float ds, float most);
        
        void setSoulStuffPos(float x, float y);
        
        inline void enableContinuouslyTrigger(bool continuouslyTrigger) { m_continuouslyTrigger = continuouslyTrigger; }
        
    protected:
        static ShopliveFilterSDKConstString paramSoulStuffPos;
        static ShopliveFilterSDKConstString paramSoulStuffScaling;
        
        GLint m_soulStuffPosLoc, m_soulStuffScalingLoc;
        float m_sizeScaling;
        float m_dSizeScaling;
        float m_dsMost;
        
        Vec2f m_pos;
        
        bool m_continuouslyTrigger;
    };
}

#endif /* ShopliveFilterSDKSoulStuffFilter_h */
