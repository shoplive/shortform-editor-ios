/*
 * ShopliveFilterSDKCrosshatchFilter.h
 *
 *  Created on: 2015-2-1
 *      Author: Wang Yang
 */

#ifndef _ShopliveFilterSDK_CROSSHATCH_H_
#define _ShopliveFilterSDK_CROSSHATCH_H_

#include "ShopliveFilterSDKGLFunctions.h"

namespace ShopliveFilterSDK
{
	class ShopliveFilterSDKCrosshatchFilter : public ShopliveFilterSDKImageFilterInterface
	{
	public:

		//Range: (0, 0.1], default: 0.03
		void setCrosshatchSpacing(float value);
		//Range: (0, 0.01], default: 0.003
		void setLineWidth(float value);

		bool init();

	protected:
		static ShopliveFilterSDKConstString paramCrosshatchSpacing;
		static ShopliveFilterSDKConstString paramLineWidth;
	};

}

#endif
