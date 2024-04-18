//
//  CGEVignetteBlendParser.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 12/26/23.
//

import Foundation



class CGEVignetteBlendParser : CGEParserProtocol {
    var filterName: String = "vigblend"
    
    
    func parseCommand(command: String, intensity : Float, size : CGSize) -> String? {
        return self.parseVigBlendCommand(command: command, intensity: intensity, size : size)
    }
    
    
    
    
    /**
     option, rgba 및 intensity는 그냥 고정인것으로 간주
     centx, centy= 0.5 고정으로
        두번째옵션은
     */
    private func parseVigBlendCommand(command : String, intensity : Float, size : CGSize) -> String? {
        var keyValue : [String : String] = [:]
        
        var spaceParsed : [String] = command.components(separatedBy: " ")
        for (index, value) in spaceParsed.enumerated() {
            if index == 0 && value.hasPrefix("@") {
                keyValue["filterName"] = value
            }
            else if index == 1 { //이거는 그냥 overlay로 고정
                keyValue["vigBlendOption"] = value
            }
            else if index == 2 {
                keyValue["red"] = value
            }
            else if index == 3 {
                keyValue["green"] = value
            }
            else if index == 4 {
                keyValue["blue"] = value
            }
            else if index == 5 {
                keyValue["alpha"] = value
            }
            else if index == 6 {
                keyValue["intensity"] = value
            }
            else if index == 7 {
                keyValue["low"] = value
            }
            else if index == 8 {
                keyValue["range"] = value
            }
            else if index == 9 {
                keyValue["centerX"] = value
            }
            else if index == 10 {
                keyValue["centerY"] = value
            }
            else if index == 11 { //이거는 안씀
                keyValue["isLinear"] = value
            }
        }
        
        guard let filterName = keyValue["filterName"], filterName == "@vigblend" else {
            return nil
        }
        
        let _ : Double = Double(keyValue["low"] ?? "0") ?? 0.0
        let _ : Double = Double(keyValue["range"] ?? "0") ?? 0.0
        let _ : Double = Double(keyValue["centerX"] ?? "0.5") ?? 0.5 // centery , centerx가 0.5가 아닐 경우 비네티가 이상하게 보이는 현상이 있어서 0.5로 고정하는 것으로 결정
        let _ : Double = Double(keyValue["centerY"] ?? "0.5") ?? 0.5 //
        
        var red : Float = Float(keyValue["red"] ?? "0") ?? 0.0
        red = red > 1 ? red / 255 : red
        var blue : Float = Float(keyValue["blue"] ?? "0") ?? 0.0
        blue = blue > 1 ? blue / 255 : blue
        var green : Float = Float(keyValue["green"] ?? "0") ?? 0.0
        green = green > 1 ? green / 255 : green
        
        let width = Int(ceil(size.width))
        let height = Int(ceil(size.height))
        let hexColor = CGEParserUtil.makeRGB2HexString(r: red, g: green, b: blue, a: 1)
        

        return """
color=color=\(hexColor):s=\(width)x\(height),loop=-1:size=2,setsar=1[plaincolorbg]; \
color=white:s=\(width)x\(height),loop=-1:size=2,setsar=1,vignette=angle=PI/2,negate[alpha]; \
[plaincolorbg][alpha]alphamerge[ov]; \
[0][ov]overlay=shortest=1[fg]; \
[0]colorchannelmixer=aa=\(1 - intensity)[bg]; \
[bg][fg]blend=all_mode=overlay:all_opacity=\(intensity)
"""
      
    }
}
