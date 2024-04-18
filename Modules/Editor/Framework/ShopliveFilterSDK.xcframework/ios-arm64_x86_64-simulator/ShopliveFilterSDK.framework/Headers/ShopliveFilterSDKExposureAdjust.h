/*
 * ShopliveFilterSDKExposureAdjust.h
 *
 *  Created on: 2015-1-29
 *      Author: Wang Yang
 */

#ifndef _ShopliveFilterSDKEXPOSUREADJUST_H_
#define _ShopliveFilterSDKEXPOSUREADJUST_H_

#include "ShopliveFilterSDKGLFunctions.h"

namespace ShopliveFilterSDK
{
	class ShopliveFilterSDKExposureFilter : public ShopliveFilterSDKImageFilterInterface
	{
	public:

		//Range: [-10, 10]
		void setIntensity(float value);

		bool init();

	protected:
		static ShopliveFilterSDKConstString paramName;

	};
}

#endif
