//
//  CGEBeautifyParser.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 12/28/23.
//

import Foundation

class CGEBeautifyParser : CGEParserProtocol {
    var filterName: String = "beautify"
    
    
    func parseCommand(command: String, intensity : Float, size: CGSize) -> String? {
        guard let option = self.getBeautifyOption(command: command)  else { return nil }
        
        switch option {
        case "bilateral":
            return parseBilateralOption(command: command)
        default:
            break
        }
                
        return nil
    }
    
    
    private func getBeautifyOption(command : String) -> String? {
        var seperated = command.components(separatedBy: " ")
        seperated.removeAll(where: { $0.isEmpty })
        guard seperated.count >= 2 else { return nil }
        return seperated[1]
    }
    
    
    private func parseBilateralOption(command : String) -> String? {
        var seperated = command.components(separatedBy: " ")
        seperated.removeAll(where: { $0.isEmpty })
        guard seperated.count <= 5, seperated[1] == "bilateral" else { return nil }
        
        let sigmaS = ((Double(seperated[2]) ?? 0.0) + 100.0) / 200 * 25.6
        let sigmaR = (Double(seperated[3]) ?? 0.0) / 100.0
        let repeats = Int(seperated[4]) ?? 0
        
        
        let commandText = "bilateral=sigmaS=\(sigmaS):sigmaR=\(sigmaR)"
        var result : String = ""
        for _ in 0...repeats {
            result += commandText + ","
        }
        if result.hasSuffix(",") {
            result = String(result.dropLast(1))
        }
        return result
    }
    
}
