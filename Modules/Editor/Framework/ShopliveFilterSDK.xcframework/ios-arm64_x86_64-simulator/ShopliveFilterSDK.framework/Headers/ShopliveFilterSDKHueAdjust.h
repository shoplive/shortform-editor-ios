/*
 * ShopliveFilterSDKHueAdjust.h
 *
 *  Created on: 2015-1-29
 *      Author: Wang Yang
 */

#ifndef _ShopliveFilterSDKHUEADJUST_H_
#define _ShopliveFilterSDKHUEADJUST_H_

#include "ShopliveFilterSDKGLFunctions.h"

namespace ShopliveFilterSDK
{
	class ShopliveFilterSDKHueAdjustFilter : public ShopliveFilterSDKImageFilterInterface
	{
	public:

		//Range: [0, 2π]
		void setHue(float value);

		bool init();

	protected:
		static ShopliveFilterSDKConstString paramName;
	};

}

#endif
