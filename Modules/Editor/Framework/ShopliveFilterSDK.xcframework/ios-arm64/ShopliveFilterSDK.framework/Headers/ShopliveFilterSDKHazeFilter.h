/*
 * ShopliveFilterSDKHazeFilter.h
 *
 *  Created on: 2015-2-1
 *      Author: Wang Yang
 */

#ifndef _ShopliveFilterSDK_HAZEFILTER_H_
#define _ShopliveFilterSDK_HAZEFILTER_H_

#include "ShopliveFilterSDKGLFunctions.h"

namespace ShopliveFilterSDK
{
	class ShopliveFilterSDKHazeFilter : public ShopliveFilterSDKImageFilterInterface
	{
	public:	

		//Range: [-0.5, 0.5], default: 0.2
		void setDistance(float value);
		//Range: [-0.5, 0.5] defualt: 0
		void setSlope(float value);

		//Range: [0, 1], Defualt: all 1
		void setHazeColor(float r, float g, float b);

		bool init();

	protected:
		static ShopliveFilterSDKConstString paramDistance;
		static ShopliveFilterSDKConstString paramSlope;
		static ShopliveFilterSDKConstString paramHazeColor;
	};
}

#endif
