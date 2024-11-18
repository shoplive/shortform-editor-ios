/*
* ShopliveFilterSDKEmbossFilter.h
*
*  Created on: 2013-12-27
*      Author: Wang Yang
*/

#ifndef _ShopliveFilterSDKEMBOSS_H_
#define _ShopliveFilterSDKEMBOSS_H_

#include "ShopliveFilterSDKAdvancedEffectsCommon.h"

namespace ShopliveFilterSDK
{
	class ShopliveFilterSDKEmbossFilter : public ShopliveFilterSDKAdvancedEffectOneStepFilterHelper
	{
	public:
		ShopliveFilterSDKEmbossFilter(){}
		~ShopliveFilterSDKEmbossFilter(){}

		//Range: [0, 1], and 0 for the origin, 1 for the best effect.
		void setIntensity(float value);

		//Range: [1, 5], default: 2.0. The 'stride' would never affect the speed.
		//You should set this when you want to keep the effects
		//     between two image with the same content but different sizes.
		void setStride(float value);

		void setAngle(float value);

		bool init();

	protected:
		static ShopliveFilterSDKConstString paramIntensity;
		static ShopliveFilterSDKConstString paramStride;
		static ShopliveFilterSDKConstString paramNorm;
	};

}

#endif
