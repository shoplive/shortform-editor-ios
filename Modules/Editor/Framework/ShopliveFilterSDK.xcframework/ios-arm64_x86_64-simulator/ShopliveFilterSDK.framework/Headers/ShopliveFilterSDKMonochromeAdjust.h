/*
 * ShopliveFilterSDKMonochromeAdjust.h
 *
 *  Created on: 2013-12-29
 *      Author: Wang Yang
 */

#ifndef _ShopliveFilterSDKMONOCHROME_ADJUST_H_
#define _ShopliveFilterSDKMONOCHROME_ADJUST_H_

#include "ShopliveFilterSDKGLFunctions.h"
#include "ShopliveFilterSDKImageFilter.h"
#include "ShopliveFilterSDKImageHandler.h"

namespace ShopliveFilterSDK
{
	class ShopliveFilterSDKMonochromeFilter : public ShopliveFilterSDKImageFilterInterface
	{
	public:
		ShopliveFilterSDKMonochromeFilter(){}
		~ShopliveFilterSDKMonochromeFilter(){}

		bool init();

		void setRed(float value);
		void setGreen(float value);
		void setBlue(float value);
		void setCyan(float value);
		void setMagenta(float value);
		void setYellow(float value);

	protected:
		static ShopliveFilterSDKConstString paramRed;
		static ShopliveFilterSDKConstString paramGreen;
		static ShopliveFilterSDKConstString paramBlue;
		static ShopliveFilterSDKConstString paramCyan;
		static ShopliveFilterSDKConstString paramMagenta;
		static ShopliveFilterSDKConstString paramYellow;
	};
}

#endif 
