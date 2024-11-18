/*
* ShopliveFilterSDKMaxValueFilter.h
*
*  Created on: 2015-3-20
*      Author: Wang Yang
* Description: 最大值滤波
*/

#ifndef _ShopliveFilterSDK_MAXVALUE_FILTER_H_
#define _ShopliveFilterSDK_MAXVALUE_FILTER_H_

#include "ShopliveFilterSDKMinValueFilter.h"

namespace ShopliveFilterSDK
{
	class ShopliveFilterSDKMaxValueFilter3x3 : public ShopliveFilterSDKMinValueFilter3x3
	{
	public:
		const char* getShaderCompFunc();

	};

	class ShopliveFilterSDKMaxValueFilter3x3Plus : public ShopliveFilterSDKMinValueFilter3x3Plus
	{
	public:
		const char* getShaderCompFunc();
	};
}

#endif
