/*
 * ShopliveFilterSDKPolarPixellateFilter.h
 *
 *  Created on: 2015-2-1
 *      Author: Wang Yang
 */

#ifndef _ShopliveFilterSDK_POLARPIXELLATEFILTER_H_
#define _ShopliveFilterSDK_POLARPIXELLATEFILTER_H_

#include "ShopliveFilterSDKGLFunctions.h"

namespace ShopliveFilterSDK
{
	class ShopliveFilterSDKPolarPixellateFilter : public ShopliveFilterSDKImageFilterInterface
	{
	public:

		//Range: [0, 1]
		void setCenter(float x, float y);
		//Range: [0, 0.2]
		void setPixelSize(float x, float y);

		bool init();

	protected:
		static ShopliveFilterSDKConstString paramCenter;
		static ShopliveFilterSDKConstString paramPixelSize;
	};
}

#endif
