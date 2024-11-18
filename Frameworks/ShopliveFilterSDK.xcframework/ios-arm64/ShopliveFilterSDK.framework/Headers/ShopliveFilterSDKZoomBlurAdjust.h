/*
 * ShopliveFilterSDKZoomBlurAdjust.h
 *
 *  Created on: 2014-9-17
 */

#ifndef _ShopliveFilterSDKZOOMBLURADJUST_H
#define _ShopliveFilterSDKZOOMBLURADJUST_H

#include "ShopliveFilterSDKGLFunctions.h"

namespace ShopliveFilterSDK
{
	//适合向外扩散的情况
	class ShopliveFilterSDKZoomBlurFilter : public ShopliveFilterSDKImageFilterInterface
	{
	public:
		ShopliveFilterSDKZoomBlurFilter(){}
		~ShopliveFilterSDKZoomBlurFilter(){}

		void setCenter(float x, float y); // texture coordinate
		void setIntensity(float strength); // range: [0, 1]

		bool init();

	protected:
		static ShopliveFilterSDKConstString paramCenterName;
		static ShopliveFilterSDKConstString paramIntensityName;
	};

	//折中方案， 兼顾向外与向内
	class ShopliveFilterSDKZoomBlur2Filter : public ShopliveFilterSDKZoomBlurFilter
	{
	public:
		ShopliveFilterSDKZoomBlur2Filter() {}
		~ShopliveFilterSDKZoomBlur2Filter() {}

		bool init();

	protected:
		static ShopliveFilterSDKConstString paramStepsName;

	};

}

#endif
