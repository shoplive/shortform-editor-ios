//
//  CGEAdjustParser.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 12/26/23.
//

import Foundation



class CGEAdjustParser : CGEParserProtocol {
    
    var filterName: String = "adjust"
    
    
    func parseCommand(command: String, intensity : Float, size : CGSize) -> String? {
        guard let option = self.getAdjustOption(command: command) else { return nil }
        
        switch option {
        case "colorbalance":
            return parseColorBalanceOption(command: command)
        case "sharpen":
            return parseSharpenOption(command: command, intensity: intensity)
        case "shadowhighlight":
            return parseShadowHightlight(command: command,intensity: intensity)
        case "exposure":
            return parseExposureOption(command: command,intensity: intensity)
        case "saturation":
            return parseSaturation(command: command,intensity : intensity)
        case "whitebalance":
            return parseWhiteBalance(command: command, intensity: intensity)
        default:
            break
        }
        
        return nil
    }
    
    private func getAdjustOption(command : String) -> String? {
        var seperated = command.components(separatedBy: " ")
        seperated.removeAll(where: { $0.isEmpty })
        guard seperated.count >= 2 else { return nil }
        return seperated[1]
    }
    
    /**
     내부 규약?
     colorbalance의 경우  red,green,blue shift, range[al']로 총 5개 혹은 3개 인데 그냥 all은 안쓰는 것으로 합의?
     */
    private func parseColorBalanceOption(command : String) -> String? {
        var seperated = command.components(separatedBy: " ")
        seperated.removeAll(where: { $0.isEmpty })
        guard seperated.count == 5, seperated[1] == "colorbalance" else { return nil }
        
        let redShift = seperated[2]
        let greenShift = seperated[3]
        let blueShift = seperated[4]
        
        return """
colorbalance=rm=\(redShift):gm=\(greenShift):bm=\(blueShift)
"""
    }
    
    
    /**
     Param num: 1 (intensity), range: [0, 10].

       If intensity = 0, the result is the same to the origin.
       If intensity > 0, the result is more sharp than the origin.

       e.g. "@adjust sharpen 4.33 2 "
     0 -1 0 -1 5 -1 0 -1 0
     0 -1 0 -1 5 -1 0 -1 0
     0 -1 0 -1 5 -1 0 -1 0
     0 -1 0 -1 5 -1 0 -1 0
     */
    private func parseSharpenOption(command : String, intensity : Float) -> String? {
        var seperated = command.components(separatedBy: " ")
        seperated.removeAll(where: { $0.isEmpty })
        guard seperated.count >= 4, seperated[1] == "sharpen" else { return nil }
        
        let sharpenIntensity = Double(seperated[2]) ?? 0
        let reducer = -(sharpenIntensity / 4)
        
        
        
//        return "[0:v]convolution='0 -1 0 -1 5 -1 0 -1 0:0 -1 0 -1 5 -1 0 -1 0:0 -1 0 -1 5 -1 0 -1 0:0 -1 0 -1 5 -1 0 -1 0'"
        
        let filterCommand = """
convolution='0 \(reducer) 0 \(reducer) \(sharpenIntensity) \(reducer) 0 \(reducer) 0:0 \(reducer) 0 \(reducer) \(sharpenIntensity) \(reducer) 0 \(reducer) 0:0 \(reducer) 0 \(reducer) \(sharpenIntensity) \(reducer) 0 \(reducer) 0:0 \(reducer) 0 \(reducer) \(sharpenIntensity) \(reducer) 0 \(reducer) 0'
"""
        
        
        return """
[0:v]\(filterCommand)[fg]; \
[0:v]colorchannelmixer=aa=\(1 - intensity)[bg]; \
[bg][fg]blend=all_mode=hardoverlay:all_opacity=\(intensity)
"""
        
//        return """
// [0:v]\(filterCommand)[fg]; \
// [0][fg]blend=all_mode=hardoverlay:all_expr='(A*\(1 - intensity))+(B*\(intensity))'
// """
    }
    
    private func parseShadowHightlight(command : String,intensity : Float) -> String? {
        var seperated = command.components(separatedBy: " ")
        seperated.removeAll(where: { $0.isEmpty })
        guard seperated.count >= 4, seperated[1] == "shadowhighlight" else { return nil }
        
        let shadow = (Double(seperated[2]) ?? 0) / 500
        let highlight = (Double(seperated[3]) ?? 0) / 500
        
        return """
colorbalance=rs=\(shadow):gs=\(shadow):bs=\(shadow):rh=\(highlight):gh=\(highlight):bh=\(highlight)[fg]; \
[0][fg]blend=all_mode=overlay:all_expr='A*\(1 - intensity)+B*\(intensity)'
"""
        
//        return """
//colorbalance=rs=\(shadow):gs=\(shadow):bs=\(shadow):rh=\(highlight):gh=\(highlight):bh=\(highlight)[fg]; \
//[0][fg]blend=all_mode=hardoverlay:all_expr='(A*\(1 - intensity))+(B*\(intensity))'
//"""
    }
    
    
    private func parseExposureOption(command : String,intensity : Float) -> String? {
        var seperated = command.components(separatedBy: " ")
        seperated.removeAll(where: { $0.isEmpty })
        guard seperated.count >= 3, seperated[1] == "exposure" else { return nil }
        
        
        return """
exposure=\(intensity)[fg]; \
[0][fg]blend=all_mode=overlay:all_expr='A*\(1 - intensity)+B*\(intensity)'
"""
    }
    
    
    private func parseSaturation(command : String,intensity : Float) -> String? {
        var seperated = command.components(separatedBy: " ")
        seperated.removeAll(where: { $0.isEmpty })
        guard seperated.count >= 3, seperated[1] == "saturation" else { return nil }
        
//        let saturationIntensity = Double(seperated[2]) ?? 1.0 //cge는 range가 0 ~ 2 ffmpeg은 range가 -10 ~ 10
        
//        return """
//lutyuv="u=128:v=128"
//"""
        return """
hue=s=0[fg]; \
[0][fg]blend=all_mode=overlay:all_expr='A*\(1 - intensity)+B*\(intensity)'
"""
    }
    
    
    private func parseWhiteBalance(command : String, intensity : Float) -> String? {
        var seperated = command.components(separatedBy: " ")
        seperated.removeAll(where: { $0.isEmpty })
        guard seperated.count >= 3, seperated[1] == "whitebalance" else { return nil }
        
        let temperature = Double(seperated[2]) ?? 0
        
        var ffmpegColorTemperature : Double = 6500 //일반
        if temperature < 0 {
            ffmpegColorTemperature = 5200 // 웜톤
        }
        else {
            ffmpegColorTemperature = 11000 //쿨톤
        }
        
        return """
colortemperature=temperature=\(ffmpegColorTemperature)[fg]; \
[0][fg]blend=all_mode=overlay:all_expr='A*\(1 - intensity)+B*\(intensity)'
"""
    }
    
}

