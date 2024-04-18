//
//  CGEPixelBlendParser.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 12/26/23.
//

import Foundation


class CGEPixelBlendParser : CGEParserProtocol {
    var filterName: String = "pixblend"
    
    
    func parseCommand(command: String, intensity : Float, size : CGSize) -> String? {
        guard let option = self.getPixBlendOption(command: command) else { return nil }
        
        switch option {
        case "mix":
            return parsePixelBlendMixCommand(command: command, videoSize: size, intensity: intensity)
        case "exclude":
            return parsePixelBlendExcludeCommand(command: command, intensity: intensity)
        default:
            break
        }
        
        return nil
    }
    
    private func getPixBlendOption(command : String) -> String? {
        let seperated = command.components(separatedBy: " ")
        guard seperated.count >= 2 else { return nil }
        return seperated[1]
    }
    
    
    private func parsePixelBlendMixCommand(command : String, videoSize : CGSize, intensity : Float) -> String? {
        var keyValue : [String : String] = [:]
        var spaceParsed : [String] = command.components(separatedBy: " ")
        for (index, value) in spaceParsed.enumerated() {
            if index == 0 && value.hasPrefix("@") {
                keyValue["filterName"] = value
            }
            else if index == 1 {
                keyValue["pixBlendOption"] = value
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
            else if index == 6 { // cgeCommand intensity is all_opacity in ffmpeg
                keyValue["intensity"] = value
            }
        }
        
        guard let option = keyValue["pixBlendOption"], option == "mix" else {
            return nil
        }
        
        guard let pixBlendIntensity = Float(keyValue["intensity"] ?? ""),
              let red = Float(keyValue["red"] ?? ""),
              let green = Float(keyValue["green"] ?? ""),
              let blue = Float(keyValue["blue"] ?? ""),
              let alpha = Float(keyValue["alpha"] ?? "") else {
            return nil
        }
        
        return """
lutrgb="r=\(red):g=\(green):b=\(blue):a=\(alpha)"[lut]; \
[lut]curves=preset=darker[fg]; \
[0:v]colorchannelmixer=aa=\(1 - intensity)[bg]; \
[bg][fg]blend=all_mode=average:all_opacity=\(intensity)
"""
    }
    
    private func parsePixelBlendExcludeCommand(command : String, intensity : Float) -> String? {
        var seperated = command.components(separatedBy: " ")
        seperated.removeAll(where: { $0.isEmpty })
        guard seperated.count >= 7, seperated[1] == "exclude" else { return nil }
        
        return """
lutrgb=r=negval:g=negval:b=negval[fg]; \
[0][fg]blend=all_mode=overlay:all_expr='A*\(1 - intensity)+B*\(intensity)'
"""
    }
    
}
