//
//  Array+extension.swift
//  NewCamera
//
//  Created by James Kim on 2021/05/27.
//

import UIKit

public extension Array {
    
    subscript (safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
    
    subscript(safe range: Range<Index>) -> ArraySlice<Element> {
        return self[Swift.min(range.lowerBound, endIndex)..<Swift.min(range.upperBound, endIndex)]
    }
    
    func chunked_SL(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }

    func chunks_SL(size chunksize: Int) -> Array<Array<Element>> {
        var words = Array<Array<Element>>()
        words.reserveCapacity(self.count / chunksize)
        for idx in stride(from: chunksize, through: self.count, by: chunksize) {
            words.append(Array(self[idx - chunksize..<idx])) // slow for large table
        }
        let reminder = self.suffix(self.count % chunksize)
        if !reminder.isEmpty {
            words.append(Array(reminder))
        }
        return words
    }
}

public extension Array where Element == String {
    func reducedWithComma_SL() -> String {
        var r = ""

        for set in self.enumerated() {
            let el = set.element
            let index = set.offset

            if index != 0 {
                r += ", "
            }
            r += el
        }
        return r
    }
}
