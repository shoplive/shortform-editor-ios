//
//  CGEStyleParser.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 12/26/23.
//

import Foundation
import ShopliveSDKCommon



class CGEStyleParser : CGEParserProtocol {
    
    var filterName: String = "style"
    
    
    func parseCommand(command: String,intensity : Float, size : CGSize) -> String? {
        guard let option = self.getStyleOption(command: command) else { return nil }
        
        switch option {
        case "max":
            return self.parseMaxOption(command: command,intensity: intensity)
        case "min":
            return self.parseMinOption(command: command,intensity: intensity)
        case "edge":
            return self.parseEdgeOption(command: command,intensity: intensity)
        default:
            break
        }
        
        return nil
    }
    
    private func getStyleOption(command : String) -> String? {
        var seperated = command.components(separatedBy: " ")
        seperated.removeAll(where: { $0.isEmpty })
        guard seperated.count >= 2 else { return nil }
        return seperated[1]
    }
    
    
    private func parseMaxOption(command : String, intensity : Float) -> String? {
        var seperated = command.components(separatedBy: " ")
        seperated.removeAll(where: { $0.isEmpty })
        guard seperated.count >= 2, seperated[1] == "max" else { return nil }
        
        return """
[0:v]geq=lum=max(p(X\\,Y-1)\\,max(p(X\\,Y+1)\\,max(p(X\\,Y)\\,max(p(X-1\\,Y)\\,p(X+1\\,Y)))))[fg]; \
[0][fg]blend=all_mode=overlay:all_expr='A*\(1 - intensity)+B*\(intensity)'
"""
    
//        return """
//[0:v]geq=lum=max(p(X\\,Y-1)\\,max(p(X\\,Y+1)\\,max(p(X\\,Y)\\,max(p(X-1\\,Y)\\,p(X+1\\,Y)))))[fg]; \
//[0][fg]blend=all_mode=hardoverlay:all_expr='(A*\(1 - intensity))+(B*\(intensity))'
//"""
    }
    
    
    private func parseMinOption(command : String,intensity : Float) -> String? {
        var seperated = command.components(separatedBy: " ")
        seperated.removeAll(where: { $0.isEmpty })
        guard seperated.count >= 2, seperated[1] == "min" else { return nil }
        
        return """
[0:v]geq=lum=min(p(X\\,Y-1)\\,min(p(X\\,Y+1)\\,min(p(X\\,Y)\\,min(p(X-1\\,Y)\\,p(X+1\\,Y)))))[fg]; \
[0][fg]blend=all_mode=overlay:all_expr='A*\(1 - intensity)+B*\(intensity)'
"""
    }
    
    private func parseEdgeOption(command : String,intensity : Float) -> String? {
        var seperated = command.components(separatedBy: " ")
        seperated.removeAll(where: { $0.isEmpty })
        guard seperated.count == 4, seperated[1] == "edge" else { return nil }
        
        var scale  = (Double(seperated[3]) ?? 0) * 2
        
        
        return """
lutrgb=r=val:g=val:b=val,prewitt=planes=7:scale=\(scale):delta=0[fg]; \
[0][fg]blend=all_mode=overlay:all_expr='A*\(1 - intensity)+B*\(intensity)'
"""
    }
    
    
    
}
