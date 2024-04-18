//
//  CGECurveParser.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 12/26/23.
//

import Foundation





class CGECurveParser : CGEParserProtocol {
    
    var filterName: String = "curve"
    
    func parseCommand(command : String, intensity : Float, size : CGSize) -> String? {
        var keyValue : [String : String] = [:]
        let spaceParsed = command.components(separatedBy: " ")
        for (index,value) in spaceParsed.enumerated() {
            if index == 0 && value.hasPrefix("@") {
                keyValue["filterName"] = value
            }
            else {
                keyValue["value"] = (keyValue["value"] ?? "") + value.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        
        guard let value = keyValue["value"] else { return nil }
        let arrValue = Array(value)
        var red : [(Double,Double)] = []
        var green : [(Double,Double)] = []
        var blue : [(Double,Double)] = []
        var all : [(Double,Double)] = []
        
        var currentRGB : String = ""
        var i : Int = 0
        
        while i < arrValue.count {
            if  ["R","G","B","RGB"].contains(where: { $0 == String(arrValue[i]) }) {
                currentRGB = String(arrValue[i])
                var points : [(Double,Double)] = []
                
                var temp : [String] = []
                i += 1
                while ((["R","G","B","RGB"].contains(where: { $0 == String(arrValue[i]) })) == false)  {
                    temp.append(String(arrValue[i]))
                    i += 1
                    if i >= value.count {
                        break
                    }
                }
                
                var subString = temp.joined(separator: "")
                subString = subString.replacingOccurrences(of: ")(", with: " ")
                subString = String(subString.dropFirst())
                subString = String(subString.dropLast())
                let parsed = subString.components(separatedBy: " ")
                for item in parsed {
                    let numbers = item.components(separatedBy: ",")
                    if numbers.count == 2 {
                        points.append(((Double(numbers[0]) ?? 0) , (Double(numbers[1]) ?? 0)))
                    }
                }
                
                switch currentRGB {
                case "R":
                    red = points
                case "G":
                    green = points
                case "B":
                    blue = points
                case "RBG":
                    all = points
                default:
                    break
                }
            }
        }
        
        return getCurvesCommand(r: red, g: green, b: blue, all: all) + "[fg];" + "[0][fg]blend=all_mode=overlay:all_expr='A*\(1 - intensity)+B*\(intensity)'"
        
//        return getCurvesCommand(r: red, g: green, b: blue,all: all) + "[fg];" + "[0][fg]blend=all_mode=hardoverlay:all_expr='(A*\(1 - intensity))+(B*\(intensity))'"
    }
    
    private func getCurvesCommand(r :[(Double,Double)], g : [(Double,Double)] , b : [(Double,Double)],all : [(Double,Double)] ) -> String {
        
        var rCurves = r.count != 0 ? "r='" : ""
        for value in r {
            let lhs = min(Double(Int((value.0 / 255 ) * 100)) / 100,1.0)
            let rhs = min(Double(Int((value.1 / 255 ) * 100)) / 100,1.0)
            rCurves += "\(lhs)/\(rhs) "
        }
        rCurves = String(rCurves.dropLast()) + "'"
        
        var bCurves = b.count != 0 ? "b='" : ""
        for value in b {
            let lhs = min(Double(Int((value.0 / 255 ) * 100)) / 100,1.0)
            let rhs = min(Double(Int((value.1 / 255 ) * 100)) / 100,1.0)
            bCurves += "\(lhs)/\(rhs) "
        }
        bCurves = String(bCurves.dropLast()) + "'"
        
        var gCurves = g.count != 0 ? "g='" : ""
        for value in g {
            let lhs = min(Double(Int((value.0 / 255 ) * 100)) / 100,1.0)
            let rhs = min(Double(Int((value.1 / 255 ) * 100)) / 100,1.0)
            gCurves += "\(lhs)/\(rhs) "
        }
        gCurves = String(gCurves.dropLast()) + "'"
        
        var allCurves = all.count != 0 ? "all=" : ""
        for  value in all {
            let lhs = min(Double(Int((value.0 / 255 ) * 100)) / 100,1.0)
            let rhs = min(Double(Int((value.1 / 255 ) * 100)) / 100,1.0)
            allCurves += "\(lhs)/\(rhs) "
        }
        
        let combined = [rCurves,bCurves,gCurves,allCurves].filter({ $0.isEmpty == false }).joined(separator: ":")
        
        return "curves=\(combined)"
    }
}
