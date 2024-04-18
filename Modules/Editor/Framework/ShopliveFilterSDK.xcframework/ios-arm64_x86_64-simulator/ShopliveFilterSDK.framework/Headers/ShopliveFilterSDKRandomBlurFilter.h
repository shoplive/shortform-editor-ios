/*
 * ShopliveFilterSDKRandomBlurFilter.h
 *
 *  Created on: 2013-12-29
 *      Author: Wang Yang
 */

#ifndef _ShopliveFilterSDKRANDOMBLUR_H_
#define _ShopliveFilterSDKRANDOMBLUR_H_

#include "ShopliveFilterSDKAdvancedEffectsCommon.h"

namespace ShopliveFilterSDK
{
	class ShopliveFilterSDKRandomBlurFilter : public ShopliveFilterSDKAdvancedEffectOneStepFilterHelper
	{
	public:
		ShopliveFilterSDKRandomBlurFilter(){}
		~ShopliveFilterSDKRandomBlurFilter(){}

		void setIntensity(float value);
		void setSamplerScale(float value);

		bool init();

	protected:
		static ShopliveFilterSDKConstString paramIntensity;
		static ShopliveFilterSDKConstString paramSamplerScale;
		static ShopliveFilterSDKConstString paramSamplerRadius;
	};
}

#endif 
