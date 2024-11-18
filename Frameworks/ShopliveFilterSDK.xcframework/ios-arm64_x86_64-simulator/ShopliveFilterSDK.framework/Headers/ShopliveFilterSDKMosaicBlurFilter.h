/*
* ShopliveFilterSDKMosaicBlur.h
*
*  Created on: 2014-4-10
*      Author: Wang Yang
*  Description: 马赛克
*/

#ifndef _ShopliveFilterSDK_MOSAICBLUR_H_
#define _ShopliveFilterSDK_MOSAICBLUR_H_

#include "ShopliveFilterSDKAdvancedEffectsCommon.h"

namespace ShopliveFilterSDK
{
	class ShopliveFilterSDKMosaicBlurFilter : public ShopliveFilterSDKAdvancedEffectOneStepFilterHelper
	{
	public:
		
		bool init();

		//Range: value >= 1.0, and 1.0(Default) for the origin. Value is better with integer.
		void setBlurPixels(float value);

	protected:
		static ShopliveFilterSDKConstString paramBlurPixelsName;
	};
}

#endif
