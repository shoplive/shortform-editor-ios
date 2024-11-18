/*
 * ShopliveFilterSDKAdvancedEffects.h
 *
 *  Created on: 2013-12-13
 *      Author: Wang Yang
 */

#ifndef _ShopliveFilterSDKADVANCEDEFFECTS_H_
#define _ShopliveFilterSDKADVANCEDEFFECTS_H_

#include "ShopliveFilterSDKEmbossFilter.h"
#include "ShopliveFilterSDKEdgeFilter.h"
#include "ShopliveFilterSDKRandomBlurFilter.h"
#include "ShopliveFilterSDKBilateralBlurFilter.h"
#include "ShopliveFilterSDKMosaicBlurFilter.h"
#include "ShopliveFilterSDKLiquidationFilter.h"
#include "ShopliveFilterSDKHalftoneFilter.h"
#include "ShopliveFilterSDKPolarPixellateFilter.h"
#include "ShopliveFilterSDKPolkaDotFilter.h"
#include "ShopliveFilterSDKCrosshatchFilter.h"
#include "ShopliveFilterSDKHazeFilter.h"
#include "ShopliveFilterSDKLerpblurFilter.h"

#include "ShopliveFilterSDKSketchFilter.h"
#include "ShopliveFilterSDKBeautifyFilter.h"

namespace ShopliveFilterSDK
{
	ShopliveFilterSDKEmbossFilter* createEmbossFilter();
	ShopliveFilterSDKEdgeFilter* createEdgeFilter();
	ShopliveFilterSDKEdgeSobelFilter* createEdgeSobelFilter();
	ShopliveFilterSDKRandomBlurFilter* createRandomBlurFilter();
	ShopliveFilterSDKBilateralBlurFilter* createBilateralBlurFilter();
    ShopliveFilterSDKBilateralBlurBetterFilter* createBilateralBlurBetterFilter();
	ShopliveFilterSDKMosaicBlurFilter* createMosaicBlurFilter();
	ShopliveFilterSDKLiquidationFilter* getLiquidationFilter(float ratio, float stride);
	ShopliveFilterSDKLiquidationFilter* getLiquidationFilter(float width, float height , float stride);

	ShopliveFilterSDKLiquidationNicerFilter* getLiquidationNicerFilter(float ratio, float stride);
	ShopliveFilterSDKLiquidationNicerFilter* getLiquidationNicerFilter(float width, float height , float stride);

	ShopliveFilterSDKHalftoneFilter* createHalftoneFilter();
	ShopliveFilterSDKPolarPixellateFilter* createPolarPixellateFilter();
	ShopliveFilterSDKPolkaDotFilter* createPolkaDotFilter();
	ShopliveFilterSDKCrosshatchFilter* createCrosshatchFilter();
	ShopliveFilterSDKHazeFilter* createHazeFilter();
	ShopliveFilterSDKLerpblurFilter* createLerpblurFilter();

	ShopliveFilterSDKSketchFilter* createSketchFilter();
    
    ShopliveFilterSDKBeautifyFilter* createBeautifyFilter();
}

#endif 
