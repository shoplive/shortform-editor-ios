//
//  CGERootParser.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 12/26/23.
//

import Foundation
import ShopliveSDKCommon

protocol CGEParserProtocol {
    var filterName : String { get }
    func parseCommand(command : String, intensity : Float, size : CGSize) -> String?
}


class CGERootParser {
    
    
    private var parsers : [CGEParserProtocol] = [CGECurveParser(),CGEPixelBlendParser(),CGEVignetteBlendParser(),CGEAdjustParser(),CGEStyleParser(),CGEBeautifyParser()]
    
    
    func parseCommand(cgeCommand : String, intensity : Float, size : CGSize) -> String? {
        let filters : [ String : String ] = splitFilters(command: cgeCommand)
        var result : String = ""
        for (key,value) in filters {
            if let parser = self.parsers.first(where: { $0.filterName == key }), let command = parser.parseCommand(command: value, intensity: intensity, size: size) {
                if command.hasPrefix("color") {
                    result = command + "," + result
                }
                else {
                    result += command + ","
                }
                ShopLiveLogger.debugLog("[HASSAN LOG] filter \(value)\n result \(result) \nd\nd\nd\nd\n")
            }
        }
        
        if result.hasSuffix(",") {
            result = String(result.dropLast(1))
        }
        
       
        
        return result
    }
    
    private func splitFilters(command : String) -> [String : String] {
        let seperated = command.components(separatedBy: "@")
        var results : [String : String] = [:]
        
        for filter in seperated {
            let spaceSeperated = filter.components(separatedBy: " ")
            if spaceSeperated.count >= 2 {
                results[spaceSeperated[0]] = "@" + filter
            }
        }
        
        return results
    }
    
}
