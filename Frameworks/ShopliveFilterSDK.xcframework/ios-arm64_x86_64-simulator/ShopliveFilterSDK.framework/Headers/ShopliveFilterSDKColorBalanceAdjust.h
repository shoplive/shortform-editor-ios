/*
 * ShopliveFilterSDKColorBalanceAdjust.h
 *
 *  Created on: 2015-3-30
 *      Author: Wang Yang
 */

#ifndef _ShopliveFilterSDKCOLORBALANCEADJUST_H_
#define _ShopliveFilterSDKCOLORBALANCEADJUST_H_

#include "ShopliveFilterSDKGLFunctions.h"

namespace ShopliveFilterSDK
{
	class ShopliveFilterSDKColorBalanceFilter : public ShopliveFilterSDKImageFilterInterface
	{
	public:

		bool init();

		//Range[-1, 1], cyan to red
		void setRedShift(float value);

		//Range[-1, 1], magenta to green
		void setGreenShift(float value);

		//Range[-1, 1], yellow to blue
		void setBlueShift(float value);

	protected:
		static ShopliveFilterSDKConstString paramRedShiftName;
		static ShopliveFilterSDKConstString paramGreenShiftName;
		static ShopliveFilterSDKConstString paramBlueShiftName;

	};



}

#endif
