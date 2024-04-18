/*
 * ShopliveFilterSDKColorLevelAdjust.h
 *
 *  Created on: 2014-1-20
 *      Author: Wang Yang
 */

#ifndef _ShopliveFilterSDKCOLORLEVELADJUST_H_
#define _ShopliveFilterSDKCOLORLEVELADJUST_H_

#include "ShopliveFilterSDKGLFunctions.h"

namespace ShopliveFilterSDK
{
	class ShopliveFilterSDKColorLevelFilter : public ShopliveFilterSDKImageFilterInterface
	{
	public:
		ShopliveFilterSDKColorLevelFilter() {}
		~ShopliveFilterSDKColorLevelFilter() {}

		bool init();

		void setLevel(float dark, float light); // range [0, 1], dark < light
		void setGamma(float value); // range [0, 3], default: 1 (origin)

	protected: 
		static ShopliveFilterSDKConstString paramLevelName;
		static ShopliveFilterSDKConstString paramGammaName;
	};
}

#endif
