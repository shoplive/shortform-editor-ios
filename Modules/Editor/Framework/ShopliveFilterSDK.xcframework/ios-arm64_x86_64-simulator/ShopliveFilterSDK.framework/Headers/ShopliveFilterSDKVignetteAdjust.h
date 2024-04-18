/*
 * ShopliveFilterSDKVignetteAdjust.h
 *
 *  Created on: 2014-1-22
 *      Author: Wang Yang
 */

#ifndef _ShopliveFilterSDKVIGNETTEADJUST_H_
#define _ShopliveFilterSDKVIGNETTEADJUST_H_

#include "ShopliveFilterSDKGLFunctions.h"

namespace ShopliveFilterSDK
{

	class ShopliveFilterSDKVignetteFilter : public ShopliveFilterSDKImageFilterInterface
	{
	public:

		virtual bool init();

		void setVignetteCenter(float x, float y); //Range: [0, 1], and 0.5 for the center.
		void setVignette(float start, float range); //Range: [0, 1]

	protected:
		static ShopliveFilterSDKConstString paramVignetteCenterName;
		static ShopliveFilterSDKConstString paramVignetteName;
	};

	class ShopliveFilterSDKVignetteExtFilter : public ShopliveFilterSDKVignetteFilter
	{
	public:	
		bool init();

		void setVignetteColor(float r, float g, float b);

	protected:
		static ShopliveFilterSDKConstString paramVignetteColor;
	};

}

#endif
