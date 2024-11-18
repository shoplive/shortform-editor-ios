/*
 * ShopliveFilterSDKFilterBasic.h
 *
 *  Created on: 2013-12-25
 *      Author: Wang Yang
 *        Mail: admin@wysaid.org
 */

#ifndef _ShopliveFilterSDKBASICADJUST_H_
#define _ShopliveFilterSDKBASICADJUST_H_

#include "ShopliveFilterSDKBrightnessAdjust.h"
#include "ShopliveFilterSDKContrastAdjust.h"
#include "ShopliveFilterSDKSharpenBlurAdjust.h"
#include "ShopliveFilterSDKSaturationAdjust.h"
#include "ShopliveFilterSDKShadowHighlightAdjust.h"
#include "ShopliveFilterSDKWhiteBalanceAdjust.h"
#include "ShopliveFilterSDKMonochromeAdjust.h"
#include "ShopliveFilterSDKCurveAdjust.h"
#include "ShopliveFilterSDKColorLevelAdjust.h"
#include "ShopliveFilterSDKVignetteAdjust.h"
#include "ShopliveFilterSDKTiltshiftAdjust.h"
#include "ShopliveFilterSDKSharpenBlurAdjust.h"
#include "ShopliveFilterSDKExposureAdjust.h"
#include "ShopliveFilterSDKHueAdjust.h"
#include "ShopliveFilterSDKColorBalanceAdjust.h"
#include "ShopliveFilterSDKLookupFilter.h"
#include "ShopliveFilterSDKMotionBlurAdjust.h"

namespace ShopliveFilterSDK
{
	ShopliveFilterSDKBrightnessFilter* createBrightnessFilter();
	ShopliveFilterSDKBrightnessFastFilter* createBrightnessFastFilter();
	ShopliveFilterSDKContrastFilter* createContrastFilter();
	ShopliveFilterSDKSharpenBlurFilter* createSharpenBlurFilter();
	ShopliveFilterSDKSharpenBlurFastFilter* createSharpenBlurFastFilter();
	ShopliveFilterSDKSharpenBlurSimpleFilter* createSharpenBlurSimpleFilter();
	ShopliveFilterSDKSharpenBlurSimpleBetterFilter* createSharpenBlurSimpleBetterFilter();
	ShopliveFilterSDKSaturationHSLFilter* createSaturationHSLFilter();
	ShopliveFilterSDKSaturationFilter* createSaturationFilter();
    ShopliveFilterSDKMotionBlurFilter* createMotionBlurFilter();
    ShopliveFilterSDKMotionBlurCurveFilter *createMotionBlurCurveFilter();
	ShopliveFilterSDKShadowHighlightFilter* createShadowHighlightFilter();
	ShopliveFilterSDKShadowHighlightFastFilter* createShadowHighlightFastFilter();
	ShopliveFilterSDKWhiteBalanceFilter* createWhiteBalanceFilter();
	ShopliveFilterSDKWhiteBalanceFastFilter* createWhiteBalanceFastFilter();
	ShopliveFilterSDKMonochromeFilter* createMonochromeFilter(); // 黑白
	ShopliveFilterSDKCurveTexFilter* createCurveTexFilter();
	ShopliveFilterSDKCurveFilter* createCurveFilter();
	ShopliveFilterSDKMoreCurveFilter* createMoreCurveFilter();
	ShopliveFilterSDKMoreCurveTexFilter* createMoreCurveTexFilter();
	ShopliveFilterSDKColorLevelFilter* createColorLevelFilter();
	ShopliveFilterSDKVignetteFilter* createVignetteFilter();
	ShopliveFilterSDKVignetteExtFilter* createVignetteExtFilter();
	ShopliveFilterSDKTiltshiftVectorFilter* createTiltshiftVectorFilter();
	ShopliveFilterSDKTiltshiftEllipseFilter* createTiltshiftEllipseFilter();
    ShopliveFilterSDKTiltshiftVectorWithFixedBlurRadiusFilter* createFixedTiltshiftVectorFilter();
	ShopliveFilterSDKTiltshiftEllipseWithFixedBlurRadiusFilter* createFixedTiltshiftEllipseFilter();
	ShopliveFilterSDKSharpenBlurFastWithFixedBlurRadiusFilter* createSharpenBlurFastWithFixedBlurRadiusFilter();
    
    class ShopliveFilterSDKSelectiveColorFilter;
	ShopliveFilterSDKSelectiveColorFilter* createSelectiveColorFilter();
	ShopliveFilterSDKExposureFilter* createExposureFilter();
	ShopliveFilterSDKHueAdjustFilter* createHueAdjustFilter();
	ShopliveFilterSDKColorBalanceFilter* createColorBalanceFilter();
	ShopliveFilterSDKLookupFilter* createLookupFilter();
}

#endif 
