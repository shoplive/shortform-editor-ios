/*
 * ShopliveFilterSDKContrastAdjust.h
 *
 *  Created on: 2013-12-26
 *      Author: Wang Yang
 */

#ifndef _ShopliveFilterSDKCONTRAST_ADJUST_H_
#define _ShopliveFilterSDKCONTRAST_ADJUST_H_

#include "ShopliveFilterSDKGLFunctions.h"
#include "ShopliveFilterSDKImageFilter.h"
#include "ShopliveFilterSDKImageHandler.h"

namespace ShopliveFilterSDK
{
	class ShopliveFilterSDKContrastFilter : public ShopliveFilterSDKImageFilterInterface
	{
	public:
		ShopliveFilterSDKContrastFilter(){}
		~ShopliveFilterSDKContrastFilter(){}

		void setIntensity(float value); //range > 0, and 1 for origin

		bool init();

	protected:
		static ShopliveFilterSDKConstString paramName;
	};
}

#endif
