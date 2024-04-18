/*
 * ShopliveFilterSDKAnimationParser.h
 *
 *  Created on: 2016-5-16
 *      Author: Wang Yang
 *        Mail: admin@wysaid.org
 */

#if !defined(ShopliveFilterSDKAnimationParser_h) && !defined(_ShopliveFilterSDK_ONLY_FILTERS_)
#define ShopliveFilterSDKAnimationParser_h

#import <GLKit/GLKit.h>

namespace ShopliveFilterSDK
{
    //返回值类型为 TimeLine. 避免头文件混乱， 这里使用 void* 作为返回值
    void* createSlideshowByConfig(id config, float totalTime);
}


#endif /* ShopliveFilterSDKAnimationParser_h */
