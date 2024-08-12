//
//  Array.swift
//  Lemon
//
//  Created by Andre Pham on 7/7/2023.
//

import Foundation

extension Array where Element: Hashable {
    
    func filterDuplicates() -> [Element] {
        var uniqueElements = Set<Element>()
        return filter { uniqueElements.insert($0).inserted }
    }
    
    func mostCommonElement() -> Element? {
        let counts = reduce(into: [:]) { counts, element in
            counts[element, default: 0] += 1
        }
        return counts.max(by: { $0.value < $1.value })?.key
    }
    
}

extension Array where Element == Int {
    
    /// Groups an array of integers into subarrays based on the value of the integers and sorts the subarrays.
    /// O(n log n), where n is the length of the array.
    /// Example: `[0, 3, 2, 2, 4, 1, 1, 0].groupAndSort(reverseOrder: false) -> [[0, 0], [1, 1], [2, 2], [3], [4]]`
    /// - Parameters:
    ///   - reverseOrder: A boolean that when set to true, sorts the array in descending order. Defaults to false.
    /// - Returns: A sorted 2D array where each subarray contains all occurrences of a particular integer from the original array.
    func groupAndSort(reverseOrder: Bool = false) -> [[Int]] {
        var dict = [Int: [Int]]()
        for num in self {
            if dict[num] != nil {
                dict[num]?.append(num)
            } else {
                dict[num] = [num]
            }
        }
        let sortedKeys = Array(dict.keys).sorted(by: reverseOrder ? (>):(<))
        var result = [[Int]]()
        for key in sortedKeys {
            if let val = dict[key] {
                result.append(val)
            }
        }
        return result
    }
    
}

