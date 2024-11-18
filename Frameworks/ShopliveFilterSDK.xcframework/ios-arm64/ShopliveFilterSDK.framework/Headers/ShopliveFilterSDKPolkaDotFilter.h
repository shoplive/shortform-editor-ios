/*
 * ShopliveFilterSDKPolkaDotFilter.h
 *
 *  Created on: 2015-2-1
 *      Author: Wang Yang
 */

#ifndef _ShopliveFilterSDK_POLKADOTFILTER_H_
#define _ShopliveFilterSDK_POLKADOTFILTER_H_

#include "ShopliveFilterSDKHalftoneFilter.h"

namespace ShopliveFilterSDK
{
	class ShopliveFilterSDKPolkaDotFilter : public ShopliveFilterSDKHalftoneFilter
	{
	public:
		bool init();

		//Range: (0, 1]
		void setDotScaling(float value);

	protected:
		static ShopliveFilterSDKConstString paramDotScaling;
	};
}

#endif
