//
//  CGETestCommands.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 12/26/23.
//

import Foundation



struct CGECommands {
    static let blackColorVigBlend = "@vigblend overlay 0 0 0 255 100 0.12 0.54 0.5 0.5 3"
    static let orangeColorVigBlend = "@vigblend overlay 245 135 66 255 100 0.12 0.54 0.5 0.5 3"
    static let whiteColorVigBlend = "@vigblend overlay 255 255 255 255 100 0.12 0.54 0.5 0.5 3"
    static let warmToneWhiteBalance = "@adjust whitebalance 0.20 1" // 따뜻한 필터
    static let coolToneWhiteBalance = "@adjust whitebalance -0.20 1" // 차가운 필터
    static let grayScaleSaturation = "@adjust saturation 0"
    static let exposure = "@adjust exposure 0.98"
    static let colorInversion = "@pixblend exclude 255 255 255 255 100"
    static let edgeDetection = "@style edge 1 2"
    
}

struct CGETestCommands {
    static let adjustColorBalanceTestCommand = "@adjust colorbalance 0.99 0.52 -0.31"
    static let adjustSharpenTestCommand = "@adjust sharpen 5 1.5"
    static let adjustShadownHighlightTestCommand = "@adjust shadowhighlight -200 -100"
    static let adjustExposureTestCommand = "@adjust exposure 0.98"
    static let adjustSaturationCommand = "@adjust saturation 0"
    static let adjustWarmWhiteBalanceCommand = "@adjust whitebalance 0.20 1"
    static let adjustCoolWhiteBalanceCommand = "@adjust whitebalance -0.20 1"
    
    
    
    
    static let styleEdgeTestCommand = "@style edge 1 2 "
    static let styleMaxTestCommand = "@style max"
    static let styleMinTestCommand = "@style min"
    
    
    static let vigblendTestCommand = "@vigblend overlay 255 0 0 255 100 0.12 0.54 0.5 0.5 3"
    static let pixblendMixTestCommand = "@pixblend mix 230 150 100 128 100"
    
    
    static let curveTestCommand = "@curve R(0, 0)(117, 95)(155, 255)(179, 225)(255, 255)G(0, 0)(94, 66)(155, 176)(255, 255)B(0, 0)(48, 59)(141, 130)(255, 224)"
    
    
    static let redOnlyCurveTestCommand = "@curve R(0, 0)(17, 119)(255, 255)"
    
    static let beautifyBilateralTestCommand = "@beautify bilateral 10 4 1"

    
    
    static let combineCurveAndColorBalance = curveTestCommand + " " + adjustColorBalanceTestCommand
    static let combineVigBlendAndCurveTestCommand =  vigblendTestCommand + " " + curveTestCommand
    static let combineCurveAndPixBlendTestCommand = curveTestCommand + " " + pixblendMixTestCommand
    static let combineCurveAndExposureTestCommand = curveTestCommand + " " + adjustExposureTestCommand
    static let combineRedOnlyCurveAndExposureTestCommand = redOnlyCurveTestCommand + " " + adjustExposureTestCommand // -> 되긴 하는 것 같음
    static let combineRedOnlyCurveAndSharpenTestCommand = redOnlyCurveTestCommand + " " + adjustSharpenTestCommand // -> 잘되는 것 같음
    
    static let combineRedOnlyCurveAndShadowHightLightTestCommand = redOnlyCurveTestCommand + " " + adjustShadownHighlightTestCommand // 잘 모르겠음
    static let combineRedOnlyCurveAndStyleEdgeTestCommand = redOnlyCurveTestCommand + " " + styleEdgeTestCommand // 조합이 되기는 하나, cge랑 ffmpeg이랑 결과가 너무 다름
    
    static let combineRedOnlyCurveAndPixblendMixTestCommand = redOnlyCurveTestCommand + " " + pixblendMixTestCommand // 비슷하게 나오는 것 같기는 함
    
    static let combineSharpenAndShadowHighLightTestCommand = adjustSharpenTestCommand + " " + adjustShadownHighlightTestCommand // 잘되는 것 같음
    static let combineSharpenAndExposureTestCommand = adjustSharpenTestCommand + " " + adjustExposureTestCommand //잘 되는 것 같음
    static let combineSharpenAndMaxTestCommand = adjustSharpenTestCommand + " " + styleMaxTestCommand // 조합이 잘 되지 않음
    static let combineSharpenAndMinTestCommand = adjustSharpenTestCommand + " " + styleMinTestCommand // 조합이 안됨
    static let combineSharpenAndVigBlendTestCommand = adjustSharpenTestCommand + " " + vigblendTestCommand // 되는것 같기는 함
    static let combineSharpenAndpixBlendTestCommand = adjustSharpenTestCommand + " " + pixblendMixTestCommand // 되는것 같음

    static let combineShadowHighLightAndExposureTestCommand = adjustShadownHighlightTestCommand + " " + adjustExposureTestCommand // 잘 됨
    static let combinShadowHightLightAndMaxTestCommand = adjustShadownHighlightTestCommand + " " + styleMaxTestCommand // 결과가 너무 다름
    static let combineShadowHighLightAndMinTestCommand = adjustShadownHighlightTestCommand + " " + styleMinTestCommand // 안됨
    static let combineShadowHighLightAndVigBlendTestCommand = adjustShadownHighlightTestCommand + " " + vigblendTestCommand //아예 안됨
    static let combineShadowHighLightAndPixBlendTestCommand = adjustShadownHighlightTestCommand + " " + pixblendMixTestCommand //아예 안됨
    
    static let combineExposureAndMaxTestCommand = adjustExposureTestCommand + " " + styleMaxTestCommand // 잘됨
    static let combineExposureAndMinTestCommand = adjustExposureTestCommand + " " + styleMinTestCommand // 효과가 매우 미미함
    
}
