//
//  CGEParserUtil.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 12/26/23.
//

import Foundation


class CGEParserUtil {
    
    class func makeRGB2HexString(r : Float, g : Float, b : Float, a : Float) -> String {
        let rgb : Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return NSString(format:"#%06x", rgb) as String
    }
    
    
//    class func makeSingleColorVideoCommand(r : Float, g : Float, b : Float, a : Float, videoSize : CGSize) -> String {
//        let hexColorString = CGEParserUtil.makeRGB2HexString(r: r, g: g, b: b, a: a)
//        return """
//color=color=\(hexColorString):s=\(Int(videoSize.width))x\(Int(videoSize.height))[color];[0][color]overlay=format=auto:shortest=1[plainColor]
//"""
//    }
}
