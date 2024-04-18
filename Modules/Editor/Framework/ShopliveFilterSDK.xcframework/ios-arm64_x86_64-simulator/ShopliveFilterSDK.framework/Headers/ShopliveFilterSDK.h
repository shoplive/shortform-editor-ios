/*
 * ShopliveFilterSDK.h
 *
 *  Created on: 2014-10-16
 *      Author: Wang Yang
 *        Mail: admin@wysaid.org
 */

#ifndef _ShopliveFilterSDK_H_
#define _ShopliveFilterSDK_H_

//umbrella header

#ifndef IOS_SDK
#define IOS_SDK 1
#endif

#ifndef ShopliveFilterSDK_TEXTURE_PREMULTIPLIED
#define ShopliveFilterSDK_TEXTURE_PREMULTIPLIED 1
#endif

#ifndef _ShopliveFilterSDK_ONLY_FILTERS_
#define _ShopliveFilterSDK_ONLY_FILTERS_ 1
#endif

#ifndef _ShopliveFilterSDK_USE_GLOBAL_GL_CACHE_
#define _ShopliveFilterSDK_USE_GLOBAL_GL_CACHE_ 0
#endif

#define ShopliveFilterSDK_USING_FRAMEWORK 1

#ifdef __OBJC__

#import <UIKit/UIKit.h>

//! Project version number for ShopliveFilterSDK.
FOUNDATION_EXPORT double ShopliveFilterSDKVersionNumber;

//! Project version string for ShopliveFilterSDK.
FOUNDATION_EXPORT const unsigned char ShopliveFilterSDKVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <ShopliveFilterSDK/PublicHeader.h>

#import <ShopliveFilterSDK/ShopliveFilterSDKCommonDefine.h>
#import <ShopliveFilterSDK/ShopliveFilterSDKGlobal.h>

#import <ShopliveFilterSDK/ShopliveFilterSDKCVUtilTexture.h>
#import <ShopliveFilterSDK/ShopliveFilterSDKCameraDevice.h>
#import <ShopliveFilterSDK/ShopliveFilterSDKCameraFrameRecorder.h>
#import <ShopliveFilterSDK/ShopliveFilterSDKDynamicImageViewHandler.h>
#import <ShopliveFilterSDK/ShopliveFilterSDKFrameRecorder.h>
#import <ShopliveFilterSDK/ShopliveFilterSDKFrameRenderer.h>
#import <ShopliveFilterSDK/ShopliveFilterSDKImageViewHandler.h>
#import <ShopliveFilterSDK/ShopliveFilterSDKProcessingContext.h>
#import <ShopliveFilterSDK/ShopliveFilterSDKSharedGLContext.h>
#import <ShopliveFilterSDK/ShopliveFilterSDKUtilFunctions.h>
#import <ShopliveFilterSDK/ShopliveFilterSDKVideoCameraViewHandler.h>
#import <ShopliveFilterSDK/ShopliveFilterSDKVideoFrameRecorder.h>
#import <ShopliveFilterSDK/ShopliveFilterSDKVideoPlayer.h>
#import <ShopliveFilterSDK/ShopliveFilterSDKVideoPlayerViewHandler.h>
#import <ShopliveFilterSDK/ShopliveFilterSDKVideoWriter.h>

#ifdef __cplusplus

#import <ShopliveFilterSDK/ShopliveFilterSDKVideoHandlerCV.h>
#import <ShopliveFilterSDK/ShopliveFilterSDKImageHandlerIOS.h>

// pure cpp

#import <ShopliveFilterSDK/ShopliveFilterSDKFilters.h>
#import <ShopliveFilterSDK/ShopliveFilterSDKGLFunctions.h>
#import <ShopliveFilterSDK/ShopliveFilterSDKImageFilter.h>
#import <ShopliveFilterSDK/ShopliveFilterSDKImageHandler.h>
#import <ShopliveFilterSDK/ShopliveFilterSDKMat.h>
#import <ShopliveFilterSDK/ShopliveFilterSDKScene.h>
#import <ShopliveFilterSDK/ShopliveFilterSDKShaderFunctions.h>
#import <ShopliveFilterSDK/ShopliveFilterSDKStaticAssert.h>
#import <ShopliveFilterSDK/ShopliveFilterSDKTextureUtils.h>
#import <ShopliveFilterSDK/ShopliveFilterSDKThread.h>
#import <ShopliveFilterSDK/ShopliveFilterSDKVec.h>
#import <ShopliveFilterSDK/ShopliveFilterSDKAdvancedEffects.h>
#import <ShopliveFilterSDK/ShopliveFilterSDKAdvancedEffectsCommon.h>
#import <ShopliveFilterSDK/ShopliveFilterSDKBeautifyFilter.h>
#import <ShopliveFilterSDK/ShopliveFilterSDKBilateralBlurFilter.h>
#import <ShopliveFilterSDK/ShopliveFilterSDKBlendFilter.h>
#import <ShopliveFilterSDK/ShopliveFilterSDKBrightnessAdjust.h>
#import <ShopliveFilterSDK/ShopliveFilterSDKColorBalanceAdjust.h>
#import <ShopliveFilterSDK/ShopliveFilterSDKColorLevelAdjust.h>
#import <ShopliveFilterSDK/ShopliveFilterSDKContrastAdjust.h>
#import <ShopliveFilterSDK/ShopliveFilterSDKCrosshatchFilter.h>
#import <ShopliveFilterSDK/ShopliveFilterSDKCurveAdjust.h>
#import <ShopliveFilterSDK/ShopliveFilterSDKDataParsingEngine.h>
#import <ShopliveFilterSDK/ShopliveFilterSDKDynamicFilters.h>
#import <ShopliveFilterSDK/ShopliveFilterSDKDynamicWaveFilter.h>
#import <ShopliveFilterSDK/ShopliveFilterSDKEdgeFilter.h>
#import <ShopliveFilterSDK/ShopliveFilterSDKEmbossFilter.h>
#import <ShopliveFilterSDK/ShopliveFilterSDKExposureAdjust.h>
#import <ShopliveFilterSDK/ShopliveFilterSDKFilterBasic.h>
#import <ShopliveFilterSDK/ShopliveFilterSDKHalftoneFilter.h>
#import <ShopliveFilterSDK/ShopliveFilterSDKHazeFilter.h>
#import <ShopliveFilterSDK/ShopliveFilterSDKHueAdjust.h>
#import <ShopliveFilterSDK/ShopliveFilterSDKLerpblurFilter.h>
#import <ShopliveFilterSDK/ShopliveFilterSDKLiquidationFilter.h>
#import <ShopliveFilterSDK/ShopliveFilterSDKLookupFilter.h>
#import <ShopliveFilterSDK/ShopliveFilterSDKMaxValueFilter.h>
#import <ShopliveFilterSDK/ShopliveFilterSDKMidValueFilter.h>
#import <ShopliveFilterSDK/ShopliveFilterSDKMinValueFilter.h>
#import <ShopliveFilterSDK/ShopliveFilterSDKMonochromeAdjust.h>
#import <ShopliveFilterSDK/ShopliveFilterSDKMosaicBlurFilter.h>
#import <ShopliveFilterSDK/ShopliveFilterSDKMultipleEffects.h>
#import <ShopliveFilterSDK/ShopliveFilterSDKMultipleEffectsCommon.h>
#import <ShopliveFilterSDK/ShopliveFilterSDKPolarPixellateFilter.h>
#import <ShopliveFilterSDK/ShopliveFilterSDKPolkaDotFilter.h>
#import <ShopliveFilterSDK/ShopliveFilterSDKRandomBlurFilter.h>
#import <ShopliveFilterSDK/ShopliveFilterSDKSaturationAdjust.h>
#import <ShopliveFilterSDK/ShopliveFilterSDKShadowHighlightAdjust.h>
#import <ShopliveFilterSDK/ShopliveFilterSDKSharpenBlurAdjust.h>
#import <ShopliveFilterSDK/ShopliveFilterSDKSketchFilter.h>
#import <ShopliveFilterSDK/ShopliveFilterSDKTiltshiftAdjust.h>
#import <ShopliveFilterSDK/ShopliveFilterSDKVignetteAdjust.h>
#import <ShopliveFilterSDK/ShopliveFilterSDKWhiteBalanceAdjust.h>

#import <ShopliveFilterSDK/ShopliveFilterSDKSprite2d.h>

#endif

#endif

#endif
