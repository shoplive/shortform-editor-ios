/*
 * ShopliveFilterSDKSaturationAdjust.h
 *
 *  Created on: 2013-12-26
 *      Author: Wang Yang
 */

#ifndef _ShopliveFilterSDKSATURATION_ADJUST_H_
#define _ShopliveFilterSDKSATURATION_ADJUST_H_

#include "ShopliveFilterSDKGLFunctions.h"
#include "ShopliveFilterSDKImageFilter.h"
#include "ShopliveFilterSDKImageHandler.h"
#include "ShopliveFilterSDKCurveAdjust.h"

namespace ShopliveFilterSDK
{
	//This one is based on HSL.
	class ShopliveFilterSDKSaturationHSLFilter : public ShopliveFilterSDKImageFilterInterface
	{
	public:
		ShopliveFilterSDKSaturationHSLFilter(){}
		~ShopliveFilterSDKSaturationHSLFilter(){}

		void setSaturation(float value); // range [-1, 1]

		void setHue(float value); // range [-1, 1]

		void setLum(float lum); // range [-1, 1]

		bool init();

	protected:
		static ShopliveFilterSDKConstString paramSaturationName;
		static ShopliveFilterSDKConstString paramHueName;
		static ShopliveFilterSDKConstString paramLuminanceName;
	};

	// You can use the fast one instead(of the one above). 
	class ShopliveFilterSDKSaturationFilter : public ShopliveFilterSDKImageFilterInterface
	{
	public:
		ShopliveFilterSDKSaturationFilter() {}
		~ShopliveFilterSDKSaturationFilter() {}
		bool init();

		//range: >0, 1 for origin, and saturation would increase if value > 1
		void setIntensity(float value);

	protected:
		static ShopliveFilterSDKConstString paramIntensityName;
	};

	//This one is based on HSV
	class ShopliveFilterSDKSaturationHSVFilter : public ShopliveFilterSDKImageFilterInterface
	{
	public:
		ShopliveFilterSDKSaturationHSVFilter(){}
		~ShopliveFilterSDKSaturationHSVFilter(){}

		bool init();

		//range: [-1, 1]
		void setAdjustColors(float red, float green, float blue,
							float magenta, float yellow, float cyan);

	protected:
		static ShopliveFilterSDKConstString paramColor1;
		static ShopliveFilterSDKConstString paramColor2;
	};
}

#endif
