/*
 * ShopliveFilterSDKDynamicFilters.h
 *
 *  Created on: 2015-11-18
 *      Author: Wang Yang
 */

#ifndef _ShopliveFilterSDKDYNAMICFILTERS_H_
#define _ShopliveFilterSDKDYNAMICFILTERS_H_

#include "ShopliveFilterSDKDynamicWaveFilter.h"
#include "ShopliveFilterSDKMotionFlowFilter.h"
#include "ShopliveFilterSDKSoulStuffFilter.h"

namespace ShopliveFilterSDK
{
	ShopliveFilterSDKDynamicWaveFilter* createDynamicWaveFilter();
    ShopliveFilterSDKMotionFlowFilter* createMotionFlowFilter();
    ShopliveFilterSDKMotionFlow2Filter* createMotionFlow2Filter();
    ShopliveFilterSDKSoulStuffFilter* createSoulStuffFilter();
}

#endif
