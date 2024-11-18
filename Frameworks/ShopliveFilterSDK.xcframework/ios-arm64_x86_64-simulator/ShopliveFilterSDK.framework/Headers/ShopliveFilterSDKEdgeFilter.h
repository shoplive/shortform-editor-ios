/*
* ShopliveFilterSDKEdgeFilter.h
*
*  Created on: 2013-12-29
*      Author: Wang Yang
*/

#ifndef _ShopliveFilterSDKEDGE_H_
#define _ShopliveFilterSDKEDGE_H_

#include "ShopliveFilterSDKEmbossFilter.h"

namespace ShopliveFilterSDK
{
	class ShopliveFilterSDKEdgeFilter : public ShopliveFilterSDKEmbossFilter
	{
	public:
		bool init();

		//Intensity Range:[0, 1], 0 for origin, and 1 for the best effect
		//Stride: [0, 5]. Default: 2
	};

	class ShopliveFilterSDKEdgeSobelFilter : public ShopliveFilterSDKEmbossFilter
	{
	public:
		
		bool init();

	protected:
		//hide
		void setAngle(float value) {}
	};
}

#endif 
